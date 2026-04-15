# Git AI 代码统计工具性能优化报告

## 1. 文档目的

本文用于分析当前 Git AI 代码统计任务在本地环境与虚拟机环境之间存在的显著性能差异，并给出可执行的性能优化建议。

已观察到的现象是：

- 本地电脑执行约 1 秒即可完成。
- 虚拟机环境经常需要 30 秒以上。

从代码实现看，这类差距主要不是 Python 计算本身造成的，而是：

> 大量 Git 子进程 + 慢磁盘 I/O + 串行遍历 + 高频数据库小事务

共同叠加的结果。

## 2. 性能问题总体结论

当前实现中，最影响速度的几个点依次是：

1. 每次任务都重新 clone 仓库，而且实际上是全量 clone。
2. 默认会统计所有远程分支，而不是只统计主分支。
3. 每个文件都单独执行一次 `git blame`，且整体是串行执行。
4. 默认 `code_only` 文件扩展名过宽，把大量文档/配置/静态资源也纳入 blame。
5. 文件级统计与贡献者统计采用大量小事务逐条写库，在 SQLite 慢盘环境中代价很高。

这几项叠加后，足以解释“本地约 1 秒、虚拟机 30 秒以上”的差距。

## 3. 关键性能热点位置

### 3.1 仓库 clone 与分支遍历

- `core/scheduler/tasks/git_blame_stats_task.py:143-153`
- `core/scheduler/tasks/git_blame_stats_task.py:157-204`
- `core/services/git_clone_service.py:68-82`

### 3.2 文件过滤与 blame 执行

- `core/services/blame_stats_service.py:57-97`
- `core/services/blame_stats_service.py:385-421`
- `core/services/blame_stats_service.py:442-526`
- `core/services/blame_stats_service.py:528-544`

### 3.3 数据库存储路径

- `core/scheduler/tasks/git_blame_stats_task.py:276-315`
- `core/database/blame_stats_db.py:369-418`
- `core/database/blame_stats_db.py:577-626`
- `core/database/base.py:78-83`

## 4. 主要性能瓶颈分析

## 4.1 每次任务都重新 clone 仓库，且实际上是全量 clone

### 现状

任务执行时会创建临时目录并调用 clone：

- `git_blame_stats_task.py` 中通过 `mkdtemp()` 创建临时目录
- `git_clone_service.py` 中调用：

```bash
git clone <repo_url> <target_dir>
```

虽然接口传了 `shallow_since`，但实际 clone 命令并未使用浅克隆参数。

### 性能影响

这意味着每次任务都要：

- 重新拉取整个仓库历史
- 写入 `.git` 对象和 pack 文件
- 在慢磁盘环境下承受较高随机读写成本

虚拟机环境下，这一步的代价通常远高于本地 SSD。

### 结论

这是最高优先级性能瓶颈之一。

## 4.2 默认统计所有分支

### 现状

当没有分支配置时，逻辑是：

- 取出所有远程分支
- 默认全部纳入统计

### 性能影响

每个分支都会重复执行：

1. checkout
2. 列文件
3. 对文件逐个执行 blame
4. 保存一轮数据库结果

如果仓库有多个分支，总耗时会近似线性增长。

例如：

- 单分支耗时 3 秒
- 10 个分支则可能接近 30 秒

### 结论

这是导致运行时间暴涨的核心设计问题之一。

## 4.3 每个文件都单独执行一次 `git blame`

### 现状

当前仓库分析会遍历所有过滤后的文件，并对每个文件单独调用：

```bash
git blame --line-porcelain <file>
```

而且当前实现整体是串行的。

### 性能影响

这会导致：

- 每个文件一次独立 Git 子进程启动成本
- 每次都要访问仓库对象、索引和文件内容
- 在虚拟机上进程创建与 I/O 更慢
- 当文件数量较多时，总耗时线性增长

如果仓库存在几百到上千个文件，这类“很多小型外部命令”的模式在虚拟机里非常吃亏。

### 结论

这是最能解释“本地快、虚拟机慢”的直接原因之一。

## 4.4 默认文件扩展名集合过宽

### 现状

`CODE_EXTENSIONS` 不仅包含常规源代码，还默认包含大量非核心代码文件：

- `.md`
- `.txt`
- `.rst`
- `.json`
- `.yaml/.yml`
- `.toml`
- `.xml`
- `.html`
- `.css/.scss/.less`

### 性能影响

这会使得很多文档、配置、前端资源、说明文件都进入 blame 分析范围。后果是：

- 待分析文件数显著增加
- `git blame` 次数显著增加
- 文档型仓库、配置型仓库、前后端混合仓库的耗时被放大

### 结论

这是一个低成本但高收益的优化点。

## 4.5 文件级统计逐条写库，事务过碎

### 现状

在 `_save_branch_stats()` 中，当前代码对每个文件单独调用 `save_file_blame_stats()`。

而 `save_file_blame_stats()` 内部又会：

1. 打开一个 session
2. 删除旧数据
3. 插入新数据
4. `flush()`
5. commit

### 性能影响

这意味着每个文件都是一笔独立事务。

在 SQLite + 慢磁盘环境中，这类模式特别昂贵，因为：

- 事务频繁提交
- fsync 成本高
- delete + insert 代替批量 upsert
- 文件数越多放大越明显

### 结论

这是数据库层最主要的性能瓶颈之一。

## 4.6 贡献者获取/创建逻辑造成额外数据库往返

### 现状

当前逻辑对每个贡献者调用 `get_or_create_contributor()`，而该函数内部会分多次 session：

- 先按 email 查
- 再按 `contributor_uid` 查
- 不存在再 insert

同时，当前调用处还存在明显不合理写法：

```python
get_or_create_contributor('Unknown', None)
```

这既可能带来逻辑错误，也会造成额外数据库查询。

### 性能影响

- 贡献者数量较多时，数据库往返次数增加
- 在虚拟机慢盘环境中更明显

### 结论

不是最大的性能瓶颈，但属于应该一并修正的问题。

## 4.7 写完文件统计后又整表回查一次

### 现状

保存完文件统计后，又调用 `get_file_blame_stats(repo_id, stat_date)` 把整批数据查回来，用于构建 `file_id_map`。

### 性能影响

这会引入一次额外的数据库读取，尤其在文件统计量较大时会形成额外成本。

### 结论

单独看影响有限，但在整体慢场景中会增加不必要的 I/O。

## 4.8 SQLite 引擎未针对慢盘场景做优化

### 现状

数据库引擎创建比较基础，未看到明显的 SQLite 慢盘优化配置。

### 潜在影响

在虚拟机环境下，可能放大：

- 锁等待
- 小事务提交成本
- 并发读写阻塞
- 读写延迟

### 结论

它更多是放大器，不一定是单独主因，但应该配合事务优化一起处理。

## 5. 为什么虚拟机环境会慢很多

虚拟机环境比本地环境更容易出现以下特征：

- 磁盘随机读写更慢
- overlayfs / 虚拟磁盘层更厚
- 宿主机资源争用更明显
- 文件系统缓存命中率更差
- 子进程启动更慢
- SQLite 提交与锁等待更明显

而当前统计任务又恰好非常依赖：

- Git 仓库对象读取
- 每文件一次外部命令执行
- 大量小事务写库
- 临时目录创建与删除

因此虚拟机中的性能损耗会被明显放大。

## 6. 优化建议（按优先级）

## 6.1 第一优先级：优化仓库获取策略

### 建议 1：真正使用浅克隆

将当前 clone 命令改为支持浅克隆，例如：

```bash
git clone --depth 1 --single-branch --branch <branch> --filter=blob:none <repo> <dir>
```

如果必须保留较近历史，可考虑：

- `--depth N`
- `--shallow-since=<date>`

### 建议 2：改为长期复用 bare mirror + fetch

若任务频繁执行，建议不要每次从零 clone，而采用：

1. 维护一个本地 bare mirror
2. 每次执行前 `git fetch`
3. 用 `worktree` 或 checkout 复用已有对象库

这是比单纯浅克隆更有长期收益的方案。

## 6.2 第二优先级：不要默认全分支统计

建议策略：

- 默认只统计主分支（`main/master`）
- 仅在配置里显式声明需要统计的分支
- 对 release/hotfix/feature 分支提供白名单机制

这项改动收益通常非常大，而且实现成本较低。

## 6.3 第三优先级：收紧默认文件类型

建议把默认统计范围缩小为“真正的源代码文件”，例如：

- 保留：`.py .js .ts .tsx .java .go .rs .c .cpp .h .hpp .cs .php .rb .kt .scala .sh .sql .vue`
- 默认移出：`.md .txt .rst .json .yaml .yml .toml .xml .html .css .scss .less`

对文档、配置、静态资源可通过自定义配置再开启，而不是默认纳入。

## 6.4 第四优先级：数据库写入改为批量事务

### 当前问题

文件级统计逐条写入，每个文件单独 delete + insert + commit。

### 建议改法

改成：

1. 先一次性删除该 `repo_id + branch + stat_date` 对应旧数据
2. 将所有文件结果组装成批量记录
3. 用同一个 session 批量插入
4. 一次 commit

贡献者统计和文件贡献者统计也应尽量采用批量写入。

这项改动在 SQLite 慢盘环境中通常收益非常明显。

## 6.5 第五优先级：对 blame 执行进行并发化

当前是串行逐文件执行 `git blame`。建议：

- 使用线程池或进程池并发跑 blame
- 并发数先从 4~8 试起
- 对大文件设置单独限流
- 总并发数做成配置项

需要注意：

- 并发过高会增加磁盘争用
- 在虚拟机里不宜盲目拉满并发
- 建议结合文件大小、历史复杂度做分层调度

## 6.6 第六优先级：减少数据库重复查询

建议：

- 写入文件统计时直接保留 `file_id` 映射
- 不要写完后再整表查询 `get_file_blame_stats()`
- contributor 预先缓存，批量查找、批量创建

## 6.7 第七优先级：优化 SQLite 参数

若短期仍使用 SQLite，建议至少加：

- `connect_args={"timeout": 30}`
- `PRAGMA journal_mode=WAL`
- `PRAGMA synchronous=NORMAL`
- `PRAGMA busy_timeout=30000`

注意：

> 这些参数只能缓解慢盘问题，不能替代“减少事务次数”这一根本优化。

## 7. 推荐实施路线

## 第一阶段：立刻可做、收益最大

1. clone 改为真正浅克隆或镜像复用
2. 默认只统计主分支
3. 收紧默认文件扩展名
4. 文件级写库改为批量事务

这四项通常能显著缩短总耗时。

## 第二阶段：进一步压缩耗时

5. blame 并发化
6. contributor 批量缓存
7. 去掉写后回表查

## 第三阶段：环境级优化

8. SQLite 参数调优
9. 临时目录与仓库目录复用
10. 为超时和大文件增加专门策略

## 8. 监控与度量建议

为避免“优化后没有数据支撑”，建议增加以下耗时指标：

- `clone_duration_ms`
- `branch_checkout_duration_ms`
- `list_files_duration_ms`
- `blame_total_duration_ms`
- `blame_avg_per_file_ms`
- `db_write_duration_ms`
- `files_count`
- `branches_count`
- `skipped_files_count`
- `timeout_files_count`

同时对以下维度做日志：

- 每个分支耗时
- blame 最慢前 20 个文件
- 最大文件数目录分布
- 数据库批量写入耗时

这样可以快速判断主要瓶颈究竟在：

- clone
- blame
- DB
- 分支数量
- 文件过滤范围

## 9. 最终结论

当前性能问题的根源，不在于单个函数执行慢，而在于整体执行模型偏重：

- 每次从零 clone
- 默认全分支
- 每文件单独 blame
- 文件类型范围过宽
- 文件级统计逐条写库

这些设计在本地高性能磁盘环境中可能还能接受，但在虚拟机慢盘环境中会被显著放大，最终形成数量级差距。

如果只优先做最关键的四项：

- 真正浅克隆或镜像复用
- 默认主分支
- 收紧文件范围
- 批量写库

通常就能显著缩短执行时间，并降低虚拟机环境下的波动。
