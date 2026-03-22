# Web 模块索引

> **架构:** B/S
> **技术栈:** JAVA + VUE
> **更新:** {{UPDATE_DATE}}

---

## 后端模块 (JAVA)

### 控制器层
```
src/main/java/com/cx/mes/controller/
├── EquipmentController.java      # 设备管理
├── RecipeController.java         # 工艺配方
├── ProductionController.java     # 生产管理
└── AlarmController.java          # 报警管理
```

### 服务层
```
src/main/java/com/cx/mes/service/
├── EquipmentService.java
├── RecipeService.java
├── ProductionService.java
└── AlarmService.java
```

### 数据访问层
```
src/main/java/com/cx/mes/repository/
├── EquipmentRepository.java
├── RecipeRepository.java
└── ProductionRepository.java
```

### 实体模型
```
src/main/java/com/cx/mes/entity/
├── Equipment.java
├── Recipe.java
└── ProductionRecord.java
```

---

## 前端模块 (VUE)

### 页面组件
```
src/pages/
├── equipment/                   # 设备管理
│   ├── EquipmentList.vue
│   ├── EquipmentDetail.vue
│   └── EquipmentMonitor.vue
├── recipe/                      # 工艺配方
│   ├── RecipeList.vue
│   └── RecipeEditor.vue
└── production/                  # 生产管理
    ├── ProductionDashboard.vue
    └── ProductionTracking.vue
```

### 公共组件
```
src/components/
├── StatusIndicator.vue          # 状态指示器
├── AlarmDisplay.vue             # 报警显示
└── DataTable.vue                # 数据表格
```

### API 调用
```
src/api/
├── equipment.js
├── recipe.js
└── production.js
```

---

## 关键配置

### 后端配置
```
src/main/resources/
├── application.yml              # 主配置
├── application-dev.yml          # 开发环境
└── application-prod.yml         # 生产环境
```

### 前端配置
```
vue.config.js                    # VUE 配置
.env.development                 # 开发环境变量
.env.production                  # 生产环境变量
```

---

## TODO: 实际模块列表

请根据实际项目更新:

1. 完整模块列表
2. 各模块功能说明
3. API 端点列表
4. 页面路由配置
