# Claude Code CLI 使用 OpenTelemetry（OTel）协议收集 AI 编程数据的企业解决方案

> 适用场景：企业内部大规模使用 Claude Code CLI / Claude AI 进行代码开发、重构、测试生成、文档生成、代码审查，希望统一采集 AI 编程行为、成本、代码贡献、风险事件和审计数据。  
> 核心目标：建立一套可统计、可审计、可治理、可扩展的 AI 编程可观测体系。

---

## 1. 建设目标

企业部署 Claude Code OTel 采集体系后，应能回答以下问题：

### 1.1 使用规模

- 每天 / 每周 / 每月有多少开发者使用 Claude Code？
- 每个部门、团队、项目、仓库的使用频率如何？
- 哪些语言、哪些项目使用 AI 编程最多？
- Claude Code 的日活、周活、月活趋势如何？

### 1.2 AI 编程贡献

- Claude Code 修改了多少代码行？
- 新增多少行、删除多少行？
- Edit / Write / NotebookEdit 被接受或拒绝的比例是多少？
- AI 生成代码主要集中在哪些语言和项目？
- AI 创建了多少 commit、PR？

### 1.3 成本与效率

- 每个用户、团队、项目消耗多少 token？
- 每个模型、每类任务成本是多少？
- 单位代码行成本、单位活跃时间成本是多少？
- Prompt cache 命中率如何？
- 是否存在异常 token 消耗或成本突增？

### 1.4 质量与风险

- 哪些工具调用失败率高？
- 哪些用户、项目或模型出现异常错误率？
- 是否频繁出现 API error、retry exhausted？
- Claude 是否频繁执行 Bash、MCP、Git commit、PR 等高风险操作？
- AI 代码是否经过人工 Review？
- 是否存在绕过权限、未授权插件、异常 MCP 连接等风险事件？

### 1.5 治理与合规

- 是否采集了敏感 prompt、代码内容、API body？
- 哪些项目启用了高风险采集开关？
- 企业是否具备 AI 编程审计证据链？
- 是否能按部门、团队、项目、成本中心做 AI 编程统计？
- 是否能支撑 AI 编程 ROI、质量评估和风险治理？

---

## 2. 总体架构

推荐采用三层采集架构：

```text
开发者电脑 / CI / 远程开发环境
        │
        │  Claude Code CLI
        │  - Metrics
        │  - Logs / Events
        │  - Traces
        │
        ▼
本地或团队级 OpenTelemetry Collector
        │
        │  清洗、脱敏、聚合、批量发送
        │
        ▼
企业级 OTel Gateway Collector
        │
        ├── Metrics Backend
        │      Prometheus / Thanos / Mimir / ClickHouse / Datadog
        │
        ├── Logs & Events Backend
        │      Loki / Elasticsearch / ClickHouse / Splunk
        │
        ├── Trace Backend
        │      Tempo / Jaeger / Zipkin / Honeycomb / Datadog
        │
        └── BI / Governance DB
               PostgreSQL / ClickHouse / Data Warehouse
```

推荐原则：

1. **开发者端只负责产生遥测数据。**
2. **本地或团队 Collector 负责初步批处理与缓冲。**
3. **企业级 Gateway Collector 负责统一脱敏、鉴权、路由和合规策略。**
4. **后端根据数据类型分别进入 metrics、logs、traces、BI 系统。**
5. **AI 代码行级归因不要只依赖 OTel，应结合 Hooks、Git diff、PR 流水线和 line provenance 数据库。**

---

## 3. Claude Code 可采集数据类型

Claude Code 使用 OTel 后，主要可以采集三类数据：

| 类型 | 主要用途 | 企业价值 |
|---|---|---|
| Metrics | 聚合统计 | 用量、成本、代码行、token、活跃时间 |
| Logs / Events | 审计明细 | 工具调用、权限决策、API 错误、Hook 执行 |
| Traces | 链路分析 | 一次 prompt 到工具调用、模型请求、Hook 的完整链路 |

---

## 4. Metrics 指标体系

Claude Code 可导出的核心 metrics 建议纳入企业统一指标体系。

| Metric | 含义 | 企业用途 |
|---|---|---|
| `claude_code.session.count` | CLI 会话数 | 使用频率、活跃用户统计 |
| `claude_code.lines_of_code.count` | 修改代码行数 | AI 编程贡献统计 |
| `claude_code.pull_request.count` | Claude 创建 PR 数量 | AI 驱动 PR 统计 |
| `claude_code.commit.count` | Claude 创建 commit 数量 | AI 提交行为统计 |
| `claude_code.cost.usage` | 成本 | 团队 / 项目成本核算 |
| `claude_code.token.usage` | token 消耗 | 模型使用和成本分析 |
| `claude_code.code_edit_tool.decision` | Edit / Write / NotebookEdit 接受或拒绝 | AI 建议采纳率 |
| `claude_code.active_time.total` | 活跃使用时间 | 人机协作时间分析 |

### 4.1 使用规模指标

| 指标 | 计算方式 |
|---|---|
| 日活开发者 DAU | distinct(`user.account_uuid`) by day |
| 周活开发者 WAU | distinct(`user.account_uuid`) by week |
| 月活开发者 MAU | distinct(`user.account_uuid`) by month |
| 会话数 | sum(`claude_code.session.count`) |
| 人均会话数 | session_count / active_users |
| 活跃时间 | sum(`claude_code.active_time.total`) |
| 团队活跃度 | group by `department`, `team.id`, `cost_center` |

### 4.2 AI 编程贡献指标

| 指标 | 计算方式 |
|---|---|
| AI 新增代码行 | sum(`claude_code.lines_of_code.count{type="added"}`) |
| AI 删除代码行 | sum(`claude_code.lines_of_code.count{type="removed"}`) |
| AI 净增代码行 | added - removed |
| AI 创建 commit 数 | sum(`claude_code.commit.count`) |
| AI 创建 PR 数 | sum(`claude_code.pull_request.count`) |
| Edit 接受率 | accept / (accept + reject) |
| Write 接受率 | accept / (accept + reject) |
| 按语言 AI 修改量 | group by `language` |

注意：`claude_code.lines_of_code.count` 只能说明 Claude Code 修改了多少行，不能单独证明这些代码在最终仓库中仍然保留，也不能区分后续人工修改。若要做“当前代码库中 AI 代码存量”或“行级 AI/人工归因”，需要结合 Git diff、Claude Code Hooks、PR 数据库和 line provenance 表。

### 4.3 成本指标

| 指标 | 计算方式 |
|---|---|
| 总成本 | sum(`claude_code.cost.usage`) |
| 用户成本 | group by `user.account_uuid` |
| 团队成本 | group by `team.id`, `cost_center` |
| 项目成本 | group by `project.name`, `repo.name` |
| 模型成本 | group by `model` |
| 单会话成本 | total_cost / session_count |
| 单 AI 代码行成本 | total_cost / AI_added_LOC |
| 输入 token | sum token where `type=input` |
| 输出 token | sum token where `type=output` |
| cache read token | sum token where `type=cacheRead` |
| cache creation token | sum token where `type=cacheCreation` |

### 4.4 稳定性与质量指标

| 指标 | 来源 |
|---|---|
| API 失败率 | `claude_code.api_error` / `claude_code.api_request` |
| 平均 API 耗时 | `api_request.duration_ms` |
| 工具失败率 | `tool_result.success=false` |
| Bash 工具失败率 | `tool_name=Bash` |
| Edit / Write 失败率 | `tool_name=Edit/Write` |
| MCP 连接失败率 | `mcp_server_connection.status=failed` |
| Hook 阻断次数 | `hook_execution_complete.num_blocking` |
| API retry exhausted 数量 | `claude_code.api_retries_exhausted` |

---

## 5. Events 审计事件体系

Claude Code OTel events 适合做行为审计和细粒度分析。

| Event | 用途 |
|---|---|
| `claude_code.user_prompt` | 分析 prompt 数量、长度、命令类型 |
| `claude_code.tool_result` | 分析工具调用、成功率、耗时、错误 |
| `claude_code.api_request` | 分析模型、token、成本、耗时 |
| `claude_code.api_error` | 分析 API 错误 |
| `claude_code.tool_decision` | 审计工具权限决策 |
| `claude_code.permission_mode_changed` | 审计权限模式变化 |
| `claude_code.mcp_server_connection` | 分析 MCP 服务连接状态 |
| `claude_code.plugin_installed` | 审计插件安装 |
| `claude_code.skill_activated` | 分析 Skill 使用情况 |
| `claude_code.hook_execution_start` | Hook 开始执行 |
| `claude_code.hook_execution_complete` | Hook 执行完成 |
| `claude_code.api_retries_exhausted` | API 重试耗尽 |

建议以 `prompt.id`、`session.id`、`user.account_uuid`、`repo.name`、`project.name` 为核心关联字段，打通一次 AI 编程任务的完整上下文。

---

## 6. Traces 链路分析

Traces 适合分析一次 prompt 从提交到完成的完整链路。

典型 trace 结构：

```text
claude_code.interaction
├── claude_code.llm_request
├── claude_code.tool
│   ├── claude_code.tool.blocked_on_user
│   └── claude_code.tool.execution
└── claude_code.hook
```

Trace 可以回答：

- 一次 AI 编程任务耗时多久？
- 时间主要消耗在模型推理、工具执行、等待人工授权，还是 Hook？
- 哪些 Bash / Edit / Write 工具调用最慢？
- API retry 是否导致整体任务变慢？
- Claude Code 调用 MCP、Skill、Subagent 时链路是否异常？
- 某个用户感觉“Claude Code 卡顿”时，瓶颈在哪里？

生产建议：

| 场景 | 是否开启 traces |
|---|---|
| POC | 开启 |
| 小范围试点 | 开启 |
| 全企业默认 | 可选 |
| 性能排障 | 临时开启 |
| 高合规环境 | 谨慎开启，必须脱敏 |

---

## 7. Claude Code 端配置

### 7.1 最小可用配置

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-gateway.company.local:4317
```

### 7.2 生产推荐配置

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# 采集 metrics 和 events
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# 统一走企业 OTel Gateway
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otel-gateway.company.com:4317

# 成本与性能
export OTEL_METRIC_EXPORT_INTERVAL=60000
export OTEL_LOGS_EXPORT_INTERVAL=5000

# 降低 metrics 高基数风险
export OTEL_METRICS_INCLUDE_SESSION_ID=false
export OTEL_METRICS_INCLUDE_VERSION=true
export OTEL_METRICS_INCLUDE_ACCOUNT_UUID=true

# 团队维度
export OTEL_RESOURCE_ATTRIBUTES="company=acme,department=mes,team=eap,cost_center=it-ai-dev,environment=prod"
```

### 7.3 可选启用 traces

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
export OTEL_TRACES_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otel-gateway.company.com:4317
```

### 7.4 不建议默认开启的高风险配置

生产环境默认不要开启：

```bash
export OTEL_LOG_USER_PROMPTS=1
export OTEL_LOG_TOOL_DETAILS=1
export OTEL_LOG_TOOL_CONTENT=1
export OTEL_LOG_RAW_API_BODIES=1
```

风险说明：

| 开关 | 生产默认 | 风险 |
|---|---:|---|
| `OTEL_LOG_USER_PROMPTS` | 关闭 | 可能采集用户 prompt 原文 |
| `OTEL_LOG_TOOL_DETAILS` | 谨慎开启 | 可能采集 Bash 命令、文件路径、URL、工具参数 |
| `OTEL_LOG_TOOL_CONTENT` | 关闭 | 可能采集 Read 结果、Bash 输出、代码内容 |
| `OTEL_LOG_RAW_API_BODIES` | 禁止默认开启 | 可能包含完整对话历史、工具结果、代码片段、业务上下文 |

---

## 8. 企业强制配置：Managed Settings

企业不应依赖每个开发者手工设置环境变量，建议使用 Claude Code Managed Settings 强制下发 OTel 配置。

### 8.1 managed-settings.json 示例

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",

    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "https://otel-gateway.company.com:4317",

    "OTEL_METRIC_EXPORT_INTERVAL": "60000",
    "OTEL_LOGS_EXPORT_INTERVAL": "5000",

    "OTEL_METRICS_INCLUDE_SESSION_ID": "false",
    "OTEL_METRICS_INCLUDE_VERSION": "true",
    "OTEL_METRICS_INCLUDE_ACCOUNT_UUID": "true",

    "OTEL_RESOURCE_ATTRIBUTES": "company=acme,environment=prod"
  },

  "otelHeadersHelper": "/opt/claude-code/bin/generate-otel-headers.sh"
}
```

### 8.2 托管配置路径

| 系统 | 路径 |
|---|---|
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

### 8.3 企业部署方式

| 环境 | 推荐方式 |
|---|---|
| Windows | GPO / Intune / SCCM / 登录脚本 |
| macOS | MDM / Jamf |
| Linux | Ansible / Puppet / SaltStack / 镜像预装 |
| WSL | 通过 Windows 配置同步或初始化脚本 |
| Dev Container | 基础镜像内置 |
| CI Runner | CI 变量统一注入 |
| 远程开发机 | 镜像或配置管理系统下发 |

---

## 9. 动态认证 Header

企业环境通常需要短期 token、mTLS 或 API Gateway 鉴权。建议使用 `otelHeadersHelper` 动态生成认证 header。

### 9.1 managed-settings.json 配置

```json
{
  "otelHeadersHelper": "/opt/claude-code/bin/generate-otel-headers.sh"
}
```

### 9.2 generate-otel-headers.sh 示例

```bash
#!/usr/bin/env bash
set -euo pipefail

TOKEN="$(/usr/local/bin/company-sso-token --audience otel-gateway)"

jq -n --arg token "$TOKEN" '{
  "Authorization": ("Bearer " + $token),
  "X-Company-Tenant": "engineering"
}'
```

注意事项：

1. 输出必须是合法 JSON。
2. 不要在脚本中打印调试日志。
3. token 应为短期 token。
4. 建议绑定设备身份、用户身份或网络环境。
5. Header Helper 脚本权限应只允许管理员修改。

---

## 10. OpenTelemetry Collector 配置

### 10.1 本地 POC Collector

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: localhost:4317
      http:
        endpoint: localhost:4318

processors:
  batch:

exporters:
  debug:
    verbosity: detailed

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]

    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]

    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

验证命令：

```bash
otelcol validate --config=collector-local.yaml
otelcol --config=collector-local.yaml
```

### 10.2 企业生产 Gateway Collector

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  memory_limiter:
    check_interval: 5s
    limit_mib: 2048
    spike_limit_mib: 512

  batch:
    timeout: 5s
    send_batch_size: 8192
    send_batch_max_size: 16384

  resource/company:
    attributes:
      - key: telemetry.source
        value: claude-code
        action: upsert
      - key: ai.tool
        value: claude-code-cli
        action: upsert

  attributes/redact:
    actions:
      - key: user.email
        action: delete
      - key: prompt
        action: delete
      - key: tool_input
        action: delete
      - key: tool_parameters
        action: delete
      - key: body
        action: delete
      - key: body_ref
        action: delete

exporters:
  otlphttp/metrics:
    endpoint: ${env:OTEL_METRICS_BACKEND}
    headers:
      Authorization: "Bearer ${env:OTEL_BACKEND_TOKEN}"

  otlphttp/logs:
    endpoint: ${env:OTEL_LOGS_BACKEND}
    headers:
      Authorization: "Bearer ${env:OTEL_BACKEND_TOKEN}"

  otlphttp/traces:
    endpoint: ${env:OTEL_TRACES_BACKEND}
    headers:
      Authorization: "Bearer ${env:OTEL_BACKEND_TOKEN}"

extensions:
  health_check:
    endpoint: 0.0.0.0:13133

service:
  extensions: [health_check]

  pipelines:
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, resource/company, batch]
      exporters: [otlphttp/metrics]

    logs:
      receivers: [otlp]
      processors: [memory_limiter, resource/company, attributes/redact, batch]
      exporters: [otlphttp/logs]

    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource/company, attributes/redact, batch]
      exporters: [otlphttp/traces]
```

### 10.3 Collector 高可用部署建议

```text
Claude Code Clients
        │
        ▼
Load Balancer
        │
        ▼
OTel Gateway Collector Cluster
        │
        ├── Collector 1
        ├── Collector 2
        └── Collector N
        │
        ▼
Backend Storage
```

建议：

1. Collector 至少 2 个副本。
2. 前面加内部负载均衡。
3. 使用 mTLS 或 Token 鉴权。
4. Collector 自身也接入监控。
5. 开启 batch 和 memory_limiter。
6. 高峰时段按 metrics/logs/traces 拆分 pipeline。
7. 生产环境避免 debug exporter。
8. 对 logs/events 使用更严格的脱敏 processor。

---

## 11. 后端存储选型

### 11.1 推荐组合

| 数据类型 | 推荐后端 | 用途 |
|---|---|---|
| Metrics | Prometheus / Mimir / Thanos / ClickHouse | 趋势、聚合、告警 |
| Logs / Events | ClickHouse / Elasticsearch / Loki / Splunk | 审计、检索、明细分析 |
| Traces | Tempo / Jaeger / Zipkin / Honeycomb | 单次任务链路分析 |
| BI | ClickHouse / PostgreSQL / Data Warehouse | 周报、月报、ROI 分析 |
| Dashboard | Grafana / Superset / Metabase | 看板 |

### 11.2 中小规模推荐

```text
Claude Code
  → OTel Collector
  → Prometheus + Loki + Tempo
  → Grafana
```

适合：

- 100 人以下研发团队
- 主要关注使用趋势、成本、错误率
- 已经有 Grafana 技术栈

### 11.3 大规模企业推荐

```text
Claude Code
  → OTel Gateway Collector
  → Kafka / Redpanda
  → ClickHouse
  → Grafana / Superset / Metabase
```

适合：

- 数百到数千开发者
- 需要长周期统计
- 需要做部门、项目、成本中心分析
- 需要将 AI 编程数据纳入数仓

### 11.4 已有观测平台的企业

如果企业已有 Datadog、Splunk、Elastic、Grafana Cloud 等平台：

```text
Claude Code
  → OTel Collector
  → 企业现有观测平台
```

原则：

1. 不重复建设。
2. 统一走 OTel Collector 做脱敏。
3. 不让 Claude Code 客户端直连多个后端。
4. 后端权限控制要符合企业数据分级要求。

---

## 12. 数据模型设计

### 12.1 OTel 明细事件表

```sql
CREATE TABLE claude_code_events (
    event_time        DateTime64(3),
    event_name        String,
    organization_id   String,
    user_account_uuid String,
    user_account_id   String,
    user_email_hash   String,
    session_id        String,
    prompt_id         String,
    model             String,
    tool_name         String,
    success           Nullable(Bool),
    duration_ms       Nullable(UInt64),
    cost_usd          Nullable(Float64),
    input_tokens      Nullable(UInt64),
    output_tokens     Nullable(UInt64),
    cache_read_tokens Nullable(UInt64),
    error_type        Nullable(String),
    team_id           String,
    department        String,
    cost_center       String,
    repo_name         String,
    raw_json          String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_time, organization_id, user_account_uuid, session_id);
```

### 12.2 每日聚合指标表

```sql
CREATE TABLE claude_code_daily_metrics (
    stat_date          Date,
    organization_id    String,
    department         String,
    team_id            String,
    cost_center        String,
    repo_name          String,
    user_count         UInt64,
    session_count      UInt64,
    active_seconds     UInt64,
    loc_added          UInt64,
    loc_removed        UInt64,
    commit_count       UInt64,
    pr_count           UInt64,
    input_tokens       UInt64,
    output_tokens      UInt64,
    cache_read_tokens  UInt64,
    cost_usd           Float64,
    edit_accept_count  UInt64,
    edit_reject_count  UInt64,
    tool_error_count   UInt64,
    api_error_count    UInt64
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(stat_date)
ORDER BY (stat_date, organization_id, department, team_id, repo_name);
```

### 12.3 AI 代码行级归因表

如果需要统计当前代码库中 AI 代码存量，应建立独立的行级归因表：

```sql
CREATE TABLE code_line_provenance (
    repo_name       String,
    branch_name     String,
    commit_sha      String,
    file_path       String,
    line_no         UInt64,
    line_hash       String,
    line_origin     String,  -- AI_DIRECT / HUMAN_DIRECT / TOOL_GENERATED / UNKNOWN
    last_modifier   String,  -- AI / HUMAN / TOOL
    session_id      Nullable(String),
    prompt_id       Nullable(String),
    tool_name       Nullable(String),
    first_seen_at   DateTime64(3),
    last_seen_at    DateTime64(3),
    is_active       Bool
)
ENGINE = MergeTree
ORDER BY (repo_name, file_path, line_no, line_hash);
```

---

## 13. 与 Claude Code Hooks 结合

OTel 适合做统计、事件和链路分析，但不适合单独做精确行级代码归因。

推荐同时启用 Claude Code Hooks。

### 13.1 Hooks 示例

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/ai-code-provenance.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/ai-bash-audit.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/ai-session-summary.sh"
          }
        ]
      }
    ]
  }
}
```

### 13.2 OTel 与 Hooks 分工

```text
OpenTelemetry
  负责：统计、事件、链路、成本、token、工具行为

Hooks + Git Diff
  负责：文件级 / 行级 AI 代码归因

CI / PR Bot
  负责：PR 中 AI 代码占比、Review 规则、质量门禁
```

### 13.3 推荐事件关联字段

Hooks 记录的数据应尽量与 OTel 数据打通：

| 字段 | 用途 |
|---|---|
| `session_id` | 关联 Claude Code 会话 |
| `prompt_id` | 关联一次 prompt |
| `tool_use_id` | 关联一次工具调用 |
| `tool_name` | Write / Edit / Bash / NotebookEdit |
| `repo_name` | 仓库 |
| `branch_name` | 分支 |
| `commit_before` | 修改前 commit |
| `commit_after` | 修改后 commit |
| `file_path` | 文件 |
| `diff_hunks` | 行级修改 |
| `actor_user` | 使用者 |
| `model` | 模型 |
| `timestamp` | 时间 |

---

## 14. PR / CI 集成方案

### 14.1 PR 自动评论示例

```text
PR #1234 AI Code Attribution Report

AI 新增代码行：820
AI 删除代码行：140
人工新增代码行：210
AI 修改人工旧代码行：145
人工修改 AI 代码行：96
工具生成代码行：300
未知来源代码行：12

AI 参与比例：72.4%
AI 代码人工 Review 覆盖率：100%

高风险文件：
- src/eap/equipment/dispatch/*.vb
- mes/core/lot_hold/*.cpp
```

### 14.2 CI 质量门禁规则

| 规则 | 建议 |
|---|---|
| AI 代码占比 > 50% | 必须至少 1 名人工 reviewer 审核 |
| AI 修改核心生产逻辑 | 必须附测试用例 |
| AI 修改安全、权限、财务、MES 调度逻辑 | 必须架构师或模块 owner 审核 |
| UNKNOWN 行数过高 | 阻断 PR，要求补充来源说明 |
| 工具生成代码 | 单独归类，不计入 AI 生成代码 |
| AI 修改数据库脚本 | 必须 DBA 或模块 owner 审核 |
| AI 修改部署脚本 | 必须 DevOps 审核 |

### 14.3 Commit Trailer 建议

可在 commit message 中增加内部 trailer：

```text
AI-Origin: claude-code
AI-Session: 2026-04-24T10:22:31Z
AI-LOC-Added: 320
AI-LOC-Modified: 76
Human-Reviewed: false
```

注意：commit trailer 只能作为补充证据，不能替代行级归因，因为一个 commit 内可能同时包含 AI 与人工修改。

---

## 15. Dashboard 看板设计

### 15.1 企业总览看板

核心卡片：

```text
今日活跃开发者
本周活跃开发者
本月 Claude Code 会话数
本月 AI 修改代码行
本月 AI 新增代码行
本月 AI 删除代码行
本月成本
本月 token 消耗
Edit 接受率
Write 接受率
API 错误率
工具失败率
```

趋势图：

- Claude Code 使用趋势
- AI 新增 / 删除代码行趋势
- 成本趋势
- token 趋势
- 活跃用户趋势
- Edit / Write 接受率趋势
- API 错误率趋势
- 工具失败率趋势

### 15.2 团队 / 成本中心看板

维度：

```text
department
team.id
cost_center
organization.id
user.account_uuid
model
language
```

图表：

- 团队 AI 代码行排名
- 团队成本排名
- 团队 token 使用排名
- 团队 Edit 接受率
- 团队 API 错误率
- 团队活跃时间
- 团队异常工具调用统计

### 15.3 项目 / 仓库看板

建议通过启动脚本或 managed settings 注入：

```bash
export OTEL_RESOURCE_ATTRIBUTES="repo.name=mes-core,project.name=siview-modernization,department=mes,team.id=eap"
```

项目看板：

- 项目 AI 修改代码行
- 项目 AI PR 数
- 项目 AI commit 数
- 项目 token 和成本
- 项目工具失败率
- 项目风险操作次数
- 项目 AI 代码 Review 覆盖率

### 15.4 个人使用看板

建议只给本人、团队负责人或治理团队查看，避免变成简单绩效工具。

指标：

- 个人会话数
- 个人 AI 代码行
- 个人 Edit / Write 接受率
- 个人成本
- 个人常用模型
- 个人常用语言
- 工具失败率
- API 错误率

---

## 16. 安全与合规策略

### 16.1 默认采集策略

生产默认策略：

```text
采集 metrics：是
采集 events：是
采集 traces：可选
采集 prompt 原文：否
采集 tool 参数详情：默认否，治理环境可有限开启
采集 tool 输入 / 输出内容：否
采集 raw API body：否
采集代码全文：否
```

### 16.2 必须脱敏的字段

```text
user.email
prompt
tool_input
tool_parameters
body
body_ref
file contents
Bash output
.env
secret
token
password
connection string
private key
cookie
authorization header
数据库连接串
内部 IP
客户名称
设备编号
生产批号
```

### 16.3 权限模型

| 角色 | 权限 |
|---|---|
| 普通开发者 | 只能看自己的使用数据 |
| Team Lead | 查看团队聚合数据 |
| 项目负责人 | 查看项目维度数据 |
| AI 治理团队 | 查看脱敏后的组织级数据 |
| 安全团队 | 可访问高风险审计事件 |
| 管理层 | 只看聚合指标，不看个人 prompt |

### 16.4 数据保留周期

| 数据 | 建议保留 |
|---|---:|
| Metrics 聚合数据 | 12–24 个月 |
| Events 明细 | 3–6 个月 |
| Traces | 7–30 天 |
| 高风险审计事件 | 12 个月 |
| 行级 provenance | 随代码仓库生命周期 |
| 原始 prompt / raw body | 默认不采集；如采集，建议 7 天内清理 |

---

## 17. 告警策略

建议配置以下告警：

| 告警 | 条件 |
|---|---|
| 成本突增 | 单日成本超过过去 7 日均值 2 倍 |
| Token 异常 | 某用户 / 项目 token 超过阈值 |
| API 错误率高 | `api_error / api_request > 5%` |
| 工具失败率高 | `tool_result.success=false > 10%` |
| Bash 使用异常 | Bash 调用量突增 |
| bypass 权限模式 | 出现 `permission_mode_changed.to_mode=bypassPermissions` |
| 高风险插件安装 | 出现未授权 plugin |
| MCP 连接失败 | MCP failed 次数过高 |
| Hook 阻断频繁 | `num_blocking` 突增 |
| Raw API body 开启 | 检测到 `api_request_body` / `api_response_body` event |
| 单用户成本异常 | 单用户日成本超过团队均值 3 倍 |
| 单项目成本异常 | 单项目日成本超过预算阈值 |
| 高风险文件 AI 修改 | AI 修改安全、权限、财务、生产调度等核心文件 |

---

## 18. 企业落地实施计划

### 阶段一：POC，1–2 周

目标：确认 Claude Code → OTel Collector → 后端链路可用。

交付物：

```text
1. Claude Code OTel POC 配置
2. 本地 / 测试 Collector
3. Metrics 接入 Prometheus 或 ClickHouse
4. Events 接入日志系统
5. 基础 Grafana 看板
6. 安全采集边界说明
```

验收标准：

```text
能看到 session.count
能看到 token.usage
能看到 cost.usage
能看到 lines_of_code.count
能看到 tool_result event
能按 user / team / model 聚合
```

### 阶段二：试点，2–4 周

目标：在 1–2 个团队中强制启用。

交付物：

```text
1. managed-settings.json
2. OTel Gateway Collector
3. 团队维度 OTEL_RESOURCE_ATTRIBUTES
4. 数据脱敏规则
5. 成本看板
6. AI 代码行看板
7. 工具失败率看板
8. API 错误告警
```

验收标准：

```text
试点团队 90% 以上开发机有 telemetry
团队成本可核算
AI 代码行可统计
敏感内容未被采集
```

### 阶段三：生产推广，4–8 周

目标：推广到企业所有 Claude Code 用户。

交付物：

```text
1. MDM / Intune / GPO / Linux 配置下发
2. 企业 OTel Gateway HA 部署
3. 分团队 Dashboard
4. 月度 AI 编程报告
5. 安全审计报表
6. CI / PR AI 代码占比集成
7. 行级 provenance 数据库
```

验收标准：

```text
全公司 Claude Code 使用可统计
部门 / 团队 / 项目成本可核算
AI 代码贡献可统计
异常行为可告警
生产默认不采集代码全文和 prompt 原文
```

### 阶段四：治理深化，持续优化

目标：从“统计”升级到“治理”。

建设内容：

```text
1. AI 代码质量分析
2. AI 代码缺陷率分析
3. AI 代码回滚率分析
4. AI 代码 Review 覆盖率分析
5. AI 工具 ROI 分析
6. 高风险模块 AI 修改审批
7. AI 编程月报 / 季报
8. 企业 AI 编程规范持续迭代
```

---

## 19. 关键风险与应对

### 19.1 误把 OTel 行数当作最终 AI 代码存量

风险：

- OTel 记录的是 Claude Code 修改过多少行。
- 这些行后续可能被人工修改、删除、格式化或重构。
- 因此不能直接等同于当前仓库中的 AI 代码存量。

应对：

- 引入 Hooks + Git diff。
- 建立 line provenance 表。
- 在 PR / CI 阶段做 AI 代码占比分析。

### 19.2 采集过多敏感数据

风险：

- prompt 原文可能包含业务需求、客户信息、生产数据。
- Bash 输出可能包含密钥、路径、数据库连接串。
- raw API body 可能包含完整对话历史和代码上下文。

应对：

- 生产默认不采集 prompt 原文、tool content、raw API body。
- Collector 层强制脱敏。
- 后端设置严格访问控制。
- 高风险采集只允许隔离环境短期开启。

### 19.3 指标被用于简单绩效考核

风险：

- 开发者可能规避采集。
- 可能出现为了提高 AI 行数而滥用 AI。
- 可能影响真实数据质量。

应对：

- 指标主要用于工程效率、成本治理、安全审计、质量改进。
- 个人指标谨慎展示。
- 团队使用聚合数据。
- 不以 AI 代码行数作为个人绩效唯一依据。

### 19.4 高基数标签导致监控系统压力大

风险：

- session_id、prompt_id、file_path 等维度可能导致 metrics cardinality 爆炸。

应对：

- Metrics 默认关闭 session_id。
- session_id、prompt_id 放到 events/logs/traces，不放到高频 metrics。
- file_path 只进入事件系统或离线分析，不进入 Prometheus 高频标签。
- 对 repo、team、department、model 等稳定维度做聚合。

---

## 20. 最终推荐方案

### 20.1 最小可行版本

```text
Claude Code
  → OTEL metrics + events
  → OTel Collector
  → Prometheus / ClickHouse
  → Grafana
```

适合：

- 快速 POC。
- 先统计使用量、成本、token、代码行。
- 不要求精确行级归因。

### 20.2 企业推荐版本

```text
Claude Code
  → Managed Settings 强制启用 OTel
  → 本地 / 团队 Collector
  → 企业 OTel Gateway
  → Metrics + Events + Traces
  → Dashboard + Alert
  → Hooks + Git Diff
  → CI / PR AI 代码占比分析
  → AI 编程治理平台
```

适合：

- 多团队推广。
- 需要成本核算。
- 需要 AI 编程审计。
- 需要安全治理。
- 需要和 DevOps / CI / Git 平台联动。

### 20.3 高成熟度版本

```text
Claude Code
  → OTel + Hooks + Git + CI
  → OTel Gateway + Kafka
  → ClickHouse / Data Warehouse
  → Line Provenance DB
  → Grafana / Superset / Metabase
  → AI Coding Governance Portal
  → 月度 AI 编程质量与效率报告
```

适合：

- 大型企业。
- 多语言、多仓库、多团队。
- 需要 AI 代码质量分析。
- 需要企业级 AI 编程治理闭环。

---

## 21. 结论

Claude Code 的 OpenTelemetry 体系非常适合采集：

- AI 编程使用量
- token 消耗
- 成本
- 模型调用
- 代码行变化
- 工具调用
- API 错误
- Hook 执行
- 权限模式变化
- MCP / Plugin / Skill 使用情况
- 单次 prompt 的链路性能

但 OTel 本身不等于完整的 AI 代码来源系统。

如果企业目标只是看用量、成本和趋势，OTel 足够。  
如果企业目标是判断“哪些代码是 AI 写的，哪些代码是人工写的”，必须叠加：

```text
Claude Code Hooks
Git diff
PR / CI 流水线
Commit metadata
Line provenance DB
代码 Review 数据
质量缺陷数据
```

最终建议：

> 企业应以 Claude Code OTel 作为 AI 编程可观测底座，以 Hooks + Git diff 作为代码来源证据链，以 CI / PR 作为治理关口，以 Dashboard + BI 作为管理和改进工具。这样才能同时实现“可统计、可审计、可治理、可优化”的 AI 编程落地体系。

---

## 22. 参考资料

- Claude Code Monitoring usage / OpenTelemetry：<https://docs.anthropic.com/en/docs/claude-code/monitoring-usage>
- Claude Code Settings / Managed settings：<https://code.claude.com/docs/en/settings>
- Claude Code Hooks：<https://code.claude.com/docs/en/hooks>
- OpenTelemetry Collector Architecture：<https://opentelemetry.io/docs/collector/architecture/>
- OpenTelemetry Collector Configuration：<https://opentelemetry.io/docs/collector/configuration/>
- OpenTelemetry Collector Processors：<https://opentelemetry.io/docs/collector/components/processor/>
