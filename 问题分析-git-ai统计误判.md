# Git AI 代码统计工具问题分析报告

## 1. 文档目的

本文用于分析当前 Git AI 代码统计工具中“AI 生成代码被统计为人工代码”的问题，梳理可能原因、触发条件、影响范围与修复建议，供研发团队定位与整改。

## 2. 问题现象

当前工具在统计仓库代码归属时，偶发出现以下情况：

- 本应归属于 AI 的代码，被统计为人工代码。
- 在虚拟机或慢磁盘环境中，误判概率更高。
- 同一仓库在本地环境结果较稳定，在虚拟机环境中更容易出现偏差。

这说明问题不只是单一的算法错误，还可能与 I/O 性能、超时、缓存策略、数据库读取时序等因素有关。

## 3. 核心结论

从现有实现看，误判问题最核心的原因是：

> 当前统计逻辑在将 `git blame` 结果与 AI authorship note 做匹配时，使用了“当前文件视角”的行号与路径，而不是“被 blame 到的提交视角”的原始行号与原始路径。

同时，系统还存在多个会放大误判的次级问题：

- `git blame` 参数过于朴素，导致移动/复制/格式化后的代码更容易被 blame 给人工提交。
- note 解析不够鲁棒，解析失败后会退化为“没有 AI note”。
- 查不到 note 时，当前实现会把结果缓存为空，后续整轮分析都不再重试。
- 数据库查询未按 `repo_url` 过滤，存在串仓库风险。
- 慢磁盘环境下，`git blame`、数据库查询、note 入库时序问题更容易触发上述降级路径。

## 4. 关键代码位置

### 4.1 核心误判逻辑

- `core/services/blame_stats_service.py:329-354`
  - `_notes_cache()`
- `core/services/blame_stats_service.py:357-383`
  - `_is_ai_line()`
- `core/services/blame_stats_service.py:442-526`
  - `analyze_file_blame()`
- `core/services/blame_stats_service.py:528-544`
  - `_run_git_blame()`
- `core/services/blame_stats_service.py:546-582`
  - `_parse_blame_porcelain()`

### 4.2 数据库与缓存相关

- `core/database/blame_stats_db.py:723-736`
  - `get_git_notes_batch()`
- `core/database/base.py:78-83`
  - 数据库引擎初始化较朴素，未见 SQLite 慢盘场景优化参数

### 4.3 任务调度与仓库统计相关

- `core/scheduler/tasks/git_blame_stats_task.py:148-153`
  - clone 调用传入 `shallow_since`，但 clone 实现未真正使用
- `core/scheduler/tasks/git_blame_stats_task.py:163-166`
  - 未配置分支时默认统计所有分支
- `core/scheduler/tasks/git_blame_stats_task.py:276-315`
  - 文件级与贡献者统计写库方式较重

## 5. 主因分析

## 5.1 使用了 `final_line`，没有使用 `orig_line`

### 现状

在 `_parse_blame_porcelain()` 中，当前逻辑只解析并保存了：

- `commit_sha`
- `final_line`
- `author`
- `author_mail`

而 `git blame --line-porcelain` 的首行格式实际是：

```text
<commit_sha> <orig_line> <final_line> [num_lines]
```

当前实现只取了 `parts[2]` 作为行号。

### 问题

AI authorship note 记录的通常是“该提交生成代码时的原始行号范围”，而当前统计逻辑使用的是“当前文件最终形态下的行号”。

如果后续发生：

- 在文件前部插入新行
- 删除中间行
- 重排代码位置

则同一段 AI 代码的当前行号会发生漂移，但其被 blame 到的提交仍然是原提交。此时 note 中的范围与当前行号不再一致，结果就是：

- commit 对了
- file 也可能对了
- line range 对不上
- 最终被统计成人工代码

### 结论

这是当前误判问题中**最高概率主因**。

## 5.2 使用当前 `rel_path`，没有使用 blame 输出中的 `filename`

### 现状

`analyze_file_blame()` 在逐行判定时调用：

```python
_is_ai_line(line_num, rel_path, line_info["commit"], new_notes_cache)
```

也就是说，文件路径使用的是当前仓库中的相对路径 `rel_path`。

但 `git blame --line-porcelain` 会输出 `filename`，该字段反映的是该行在被 blame 到的提交中的文件路径。

### 问题

如果文件经历过：

- rename
- move
- 路径调整

则当前路径与原始路径可能不同。此时：

- note 里记录的是旧路径
- 统计时拿当前新路径去匹配
- 匹配失败
- AI 行被当成人工

### 结论

这是另一个高概率主因，尤其在仓库历史较长、重构频繁时更容易触发。

## 6. 次要但重要的误判原因

## 6.1 `git blame` 参数过于保守

### 现状

当前执行命令为：

```bash
git blame --line-porcelain <file>
```

### 问题

没有启用：

- `-w`：忽略空白差异
- `-M`：跟踪文件内移动
- `-C -C`：跟踪跨文件复制/移动

这会导致如下场景更容易把 AI 代码 blame 给后续人工提交：

- 人工移动了一段 AI 代码
- 人工复制 AI 代码到新文件
- 人工做大规模格式化、缩进调整、换行调整

当 blame 指向人工提交，而该人工提交没有 AI note 时，这些行就会被统计成人工代码。

### 结论

这是高概率放大因子，尤其会在代码被整理、格式化、迁移后显著增加误判。

## 6.2 note 解析过于脆弱

### 现状

`_parse_git_note_content()` 依赖固定分隔线 `---`，解析失败时 `_notes_cache()` 仅记录 warning。

### 问题

若 note 内容存在以下情况：

- `\r\n` 换行差异
- 分隔线前后有空格
- range 文本稍有异常
- JSON metadata 存在轻微格式问题

则 note 解析可能失败。

当前失败后的处理不够严格，常见结果是：

- 当前 commit 没有正常进入 `notes_cache`
- 或被当作“没有 AI note”
- 后续 `_is_ai_line()` 返回 `False`
- AI 行被当成人工

### 结论

这是“偶发误判”的典型来源之一。

## 6.3 路径规范化不足

### 现状

`_is_ai_line()` 只对路径做了：

```python
file_path.replace('\\', '/')
```

### 问题

这不足以覆盖以下差异：

- `src/a.py` vs `./src/a.py`
- `src//a.py`
- Windows 路径分隔符差异
- 路径大小写差异
- 引号包裹路径

### 结论

commit 和 line 都正确时，仍可能因路径 key 不一致而漏匹配。

## 6.4 数据库批量取 note 未按 `repo_url` 过滤

### 现状

`get_git_notes_batch()` 当前只按 `commit_sha` 查询：

```python
.filter(AuthorshipNotes.commit_sha.in_(commit_shas))
```

### 问题

在以下场景中存在串仓库风险：

- fork 仓库
- mirror 仓库
- 多仓库存储在同一数据库中
- 同源代码库使用相同历史

虽然不是最高频原因，但会导致结果不稳定、偶发且难复现。

## 6.5 commit 发生 rebase/cherry-pick/squash 后，note 未同步

### 现状

系统判定 AI 归属依赖数据库表中的 `authorship_notes`，而不是直接读取仓库中的实时 git notes。

### 问题

如果 commit 历史被重写：

- rebase
- cherry-pick
- squash
- rewrite history

则 blame 指向的新 SHA 可能没有对应 note，旧 SHA 才有 note。此时会表现为：

- blame 成功
- note 查询不到
- AI 行被当成人工

### 结论

这是中概率问题，尤其在多人协作、频繁整理历史的仓库中应重点关注。

## 6.6 旧逻辑仍然残留，后续容易误用

项目中仍保留旧格式解析路径，例如旧式 `file_path,line_num,is_ai` 风格逻辑。如果未来某条调用链误走旧逻辑，可能再次造成误判或统计不一致。

### 结论

虽然不是当前主因，但属于维护风险，应尽快统一到单一格式。

## 7. 为什么虚拟机/慢磁盘环境误判概率更高

这条现象非常关键。慢磁盘本身通常不会改变归因算法，但会放大以下问题：

- git 子进程执行更慢
- 数据库查询和写入更慢
- note 写入与统计读取之间的时间窗口更长
- 超时、锁等待、读取为空、部分失败更容易发生

从现有逻辑看，最危险的链路是：

1. 仓库分析开始。
2. 某些 commit 的 note 尚未查到，或数据库读取临时失败。
3. `_notes_cache()` 将这些 commit 缓存为“空结果”或未正确缓存。
4. 本轮统计后续不再重试。
5. `_is_ai_line()` 看到该 commit 无 note，直接返回 `False`。
6. 这些本应属于 AI 的行被整轮统计成人工。

也就是说：

> 慢磁盘不是唯一根因，但很可能是把“短暂查不到 note / 临时失败”放大为“整轮统计误判”的关键放大器。

## 8. 与慢 I/O 高相关的具体风险点

## 8.1 `git blame` 固定 60 秒超时

位置：`core/services/blame_stats_service.py:528-536`

大文件、历史复杂文件在虚拟机慢盘环境中更容易超时。当前超时后直接返回 `None`，文件会被跳过，最终导致结果失真。

## 8.2 查不到 note 时直接缓存为空

位置：`core/services/blame_stats_service.py:339-343`

如果批量查询某轮没拿到 note，当前实现会把这些 commit 记成空 `{}`。这会把“暂时查不到”放大成“本轮永久判定无 AI note”。

## 8.3 SQLite 默认参数较朴素

位置：`core/database/base.py:78-83`

未见以下优化：

- `busy_timeout`
- WAL 模式
- `synchronous=NORMAL`
- SQLite connect timeout

在慢盘和多进程场景下，更容易出现锁等待、读取慢、提交慢、部分查询为空等问题。

## 9. 修复建议（按优先级）

## 9.1 第一优先级：修正归因匹配维度

### 建议 1：在 blame 解析中保留 `orig_line`

应将 `_parse_blame_porcelain()` 从只记录 `final_line` 改为同时记录：

- `orig_line`
- `final_line`
- `source_file`（来自 `filename`）

### 建议 2：匹配 note 时改用 `orig_line + source_file`

在 `analyze_file_blame()` 中，不再直接使用：

- 当前循环的 `line_num`
- 当前文件路径 `rel_path`

而是改用：

- `line_info["orig_line"]`
- `line_info["source_file"] or rel_path`

这是修复误判最关键的一步。

## 9.2 第二优先级：增强 blame 追踪能力

建议将 `git blame` 改为可配置模式，优先支持：

```bash
git blame -w -M -C -C --line-porcelain -- <file>
```

这样可以减少移动、复制、格式化导致的归因漂移。

## 9.3 第三优先级：修正 note 缓存策略

不要把“当前批次没查到 note”直接缓存为空并永久当作 human。建议改成三态：

- `FOUND`
- `MISSING_RETRYABLE`
- `PARSE_FAILED`

对 `missing` 的 commit 可以：

- 记录为 unknown
- 本轮后续重试一次
- 或在仓库级预取阶段做一次完整补查

## 9.4 第四优先级：路径标准化统一

新增统一的路径标准化函数，建议至少覆盖：

- 斜杠统一
- 去除 `./`
- 压缩多余斜杠
- 必要时统一大小写
- 处理 git quoted path / escaped path

特别是若后续开始使用 blame 的 `filename`，要注意中文、emoji、特殊字符路径的解码问题。

## 9.5 第五优先级：数据库查询加 `repo_url`

建议把 `get_git_notes_batch()` 改成按 `repo_url + commit_sha` 查询，避免串仓库拿错 note。

## 9.6 第六优先级：提升错误可观测性

建议增加以下计数与日志：

- `commits_note_missing`
- `commits_note_parse_failed`
- `lines_file_path_miss`
- `lines_range_miss`
- `files_timeout`
- `files_blame_failed`
- `lines_unknown_due_to_missing_note`

这样才能快速区分：

- 真正的人类代码
- note 缺失导致的人类代码
- 解析失败导致的人类代码
- 超时跳过导致的数据偏差

## 10. 推荐测试补充

## 10.1 行号漂移测试

构造：

- note 记录 `src/test.py` 第 1-2 行为 AI
- blame 输出指向同一 commit，但 `orig_line=1/2`，`final_line=3/4`

预期：

- 仍判定为 AI

## 10.2 rename 测试

构造：

- 当前路径为 `src/new_name.py`
- blame 输出 `filename old_name.py`
- note 中记录 `old_name.py`

预期：

- 仍判定为 AI

## 10.3 note 解析失败测试

构造轻微格式异常 note，验证系统不会直接静默降级为 human，而是明确标记 parse failed。

## 10.4 repo 隔离测试

构造两个 repo 共用相同 commit SHA 的场景，验证只会命中当前仓库 note。

## 11. 实施建议

建议分三轮落地：

### 第一轮：先修正确性

- `orig_line` 替代 `final_line` 做 note 匹配
- 使用 blame `filename`
- 增加路径 normalize
- `get_git_notes_batch()` 增加 `repo_url`

### 第二轮：修慢环境稳定性

- note miss 不再永久缓存为空
- `git blame` timeout 配置化并重试
- SQLite 增加 WAL / busy timeout / connect timeout

### 第三轮：补运维与质量保障

- 增加日志和指标
- 新增漂移/rename/rewrite 历史用例
- 清理旧解析逻辑

## 12. 最终结论

当前工具“AI 代码被统计为人工代码”的问题并非单点缺陷，而是一个由以下因素叠加形成的综合问题：

- 核心匹配维度错误：用了当前最终行号和当前路径
- blame 跟踪能力不足：未跟踪移动/复制/空白调整
- note 解析和缓存策略不够健壮
- 数据库查询边界不严
- 慢磁盘环境放大了时序与超时问题

其中，**最先必须修复的，是基于 `orig_line + source_file` 的匹配逻辑**。如果这一点不改，其它优化只能缓解，不能从根上消除误判。
