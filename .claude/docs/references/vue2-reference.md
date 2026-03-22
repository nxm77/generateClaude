# Vue 2 本地参考

> **更新:** 2025-03-22

---

## Options API

### 基础结构

```vue
<template>
  <div>
    <h1>{{ message }}</h1>
    <button @click="increment">点击 {{ count }} 次</button>
  </div>
</template>

<script>
export default {
  name: 'MyComponent',
  components: {
    // 子组件注册
  },
  props: {
    initialValue: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      message: 'Hello Vue 2',
      count: this.initialValue
    }
  },
  computed: {
    doubled() {
      return this.count * 2
    }
  },
  watch: {
    count(newVal, oldVal) {
      console.log(`count: ${oldVal} -> ${newVal}`)
    }
  },
  methods: {
    increment() {
      this.count++
    }
  },
  created() {
    console.log('组件创建')
  },
  mounted() {
    console.log('组件挂载')
  },
  beforeDestroy() {
    console.log('组件销毁前')
  }
}
</script>

<style scoped>
/* 组件样式 */
</style>
```

---

## 生命周期

| 钩子 | 触发时机 |
|------|---------|
| `beforeCreate` | 实例创建前 |
| `created` | 实例创建完成 |
| `beforeMount` | 挂载前 |
| `mounted` | 挂载完成 |
| `beforeUpdate` | 数据更新前 |
| `updated` | 数据更新完成 |
| `beforeDestroy` | 销毁前 |
| `destroyed` | 销毁完成 |
| `activated` | keep-alive 组件激活 |
| `deactivated` | keep-alive 组件停用 |

---

## 指令

| 指令 | 用途 |
|------|------|
| `v-bind` | 属性绑定，简写 `:` |
| `v-on` | 事件绑定，简写 `@` |
| `v-model` | 双向绑定 |
| `v-if` / `v-else` / `v-else-if` | 条件渲染 |
| `v-show` | 显示隐藏 |
| `v-for` | 列表渲染 |
| `v-text` | 文本内容 |
| `v-html` | HTML 内容 |
| `v-once` | 只渲染一次 |
| `v-pre` | 跳过编译 |
| `v-cloak` | 隐藏未编译模板 |

```vue
<!-- 属性绑定 -->
<img :src="imageSrc" :alt="imageAlt">

<!-- 事件绑定 -->
<button @click="handleClick">点击</button>
<button @click.stop="handleClick">阻止冒泡</button>
<input @keyup.enter="submit">

<!-- 双向绑定 -->
<input v-model="message" v-model.trim="message">
<input v-model.number="age" type="number">
<textarea v-model.lazy="description"></textarea>

<!-- 条件渲染 -->
<div v-if="type === 'A'">A</div>
<div v-else-if="type === 'B'">B</div>
<div v-else>其他</div>

<!-- 列表渲染 -->
<li v-for="(item, index) in items" :key="item.id">
  {{ index }}: {{ item.name }}
</li>
```

---

## 组件通信

### Props

```javascript
// 父组件
<ChildComponent :title="parentTitle" :count="count" />

// 子组件
export default {
  props: {
    title: String,
    count: {
      type: Number,
      required: true,
      default: 0,
      validator: value => value >= 0
    }
  }
}
```

### Events

```javascript
// 子组件
this.$emit('update', newValue)
this.$emit('submit', { id: 1, name: 'Test' })

// 父组件
<ChildComponent @update="handleUpdate" @submit="handleSubmit" />
```

### v-model 自定义

```javascript
// 子组件
export default {
  props: ['value'],
  methods: {
    updateValue(newValue) {
      this.$emit('input', newValue)
    }
  }
}

// 父组件
<ChildComponent v-model="value" />

// 或使用 .sync 修饰符 (Vue 2.3+)
<ChildComponent :title.sync="title" />
```

---

## 状态管理 Vuex

### Store 结构

```javascript
import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    count: 0,
    user: null
  },
  getters: {
    doubledCount: state => state.count * 2,
    isAuthenticated: state => state.user !== null
  },
  mutations: {
    INCREMENT(state) {
      state.count++
    },
    SET_USER(state, user) {
      state.user = user
    }
  },
  actions: {
    async fetchUser({ commit }) {
      const user = await api.getUser()
      commit('SET_USER', user)
    }
  },
  modules: {
    moduleA: {
      namespaced: true,
      state: { /* ... */ },
      mutations: { /* ... */ },
      actions: { /* ... */ }
    }
  }
})
```

### 组件中使用

```javascript
import { mapState, mapGetters, mapMutations, mapActions } from 'vuex'

export default {
  computed: {
    ...mapState(['count', 'user']),
    ...mapGetters(['doubledCount', 'isAuthenticated'])
  },
  methods: {
    ...mapMutations(['INCREMENT']),
    ...mapActions(['fetchUser'])
  }
}
```

---

## 路由 Vue Router

```javascript
import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/user/:id',
    name: 'User',
    component: User,
    props: true
  },
  {
    path: '/admin',
    component: Admin,
    meta: { requiresAuth: true },
    children: [
      { path: '', component: AdminHome },
      { path: 'users', component: AdminUsers }
    ]
  }
]

const router = new Router({
  mode: 'history',
  routes
})

// 导航守卫
router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!auth.isAuthenticated()) {
      next({ name: 'Login' })
    } else {
      next()
    }
  } else {
    next()
  }
})
```

---

## 常用模式

### 父子组件访问

```javascript
// 父组件访问子组件
<ChildComponent ref="child" />
this.$refs.child.childMethod()

// 子组件访问父组件 (不推荐)
this.$parent.parentMethod()

// 访问根实例
this.$root
```

### 插槽

```vue
<!-- 父组件 -->
BaseLayout>
  <template v-slot:header>
    <h1>页面标题</h1>
  </template>

  <template v-slot:default>
    <p>主要内容</p>
  </template>

  <template #footer>
    <p>页脚</p>
  </template>
</BaseLayout>

<!-- 子组件 -->
<div class="layout">
  <header>
    <slot name="header">默认标题</slot>
  </header>
  <main>
    <slot></slot>
  </main>
  <footer>
    <slot name="footer">默认页脚</slot>
  </footer>
</div>
```

### 异步组件

```javascript
Vue.component('async-component', () => ({
  component: import('./AsyncComponent.vue'),
  loading: LoadingComponent,
  error: ErrorComponent,
  delay: 200,
  timeout: 3000
}))
```

---

## 与 Vue 3 主要差异

| 特性 | Vue 2 | Vue 3 |
|------|-------|-------|
| API | Options API | Composition API |
| 响应式 | Object.defineProperty | Proxy |
| 多根节点 | 不支持 | 支持 |
| Teleport | 不支持 | 支持 |
| Fragments | 不支持 | 支持 |
| v-model | `value` + `input` | `modelValue` + `update:modelValue` |
| 生命周期 | `beforeDestroy` / `destroyed` | `beforeUnmount` / `unmounted` |

---

相关文档:
- [VUE Skill](../../skills/vue/SKILL.md)
- [Vue 3 参考](vue3-reference.md)
