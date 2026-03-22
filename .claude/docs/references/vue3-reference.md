# Vue 3 本地参考

> **更新:** 2025-03-22

---

## Composition API

### setup()

```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)
const doubled = computed(() => count.value * 2)

function increment() {
  count.value++
}
</script>
```

### 响应式 API

| API | 用途 |
|-----|------|
| `ref()` | 响应式引用 |
| `reactive()` | 响应式对象 |
| `computed()` | 计算属性 |
| `watch()` | 监听器 |
| `watchEffect()` | 自动追踪监听 |

### 组件生命周期

| Vue 2 | Vue 3 (Composition API) |
|-------|------------------------|
| beforeCreate | setup() 开始 |
| created | setup() 开始 |
| beforeMount | onBeforeMount |
| mounted | onMounted |
| beforeUpdate | onBeforeUpdate |
| updated | onUpdated |
| beforeUnmount | onBeforeUnmount |
| unmounted | onUnmounted |

---

## Vue 2 兼容

### Options API

```vue
<script>
export default {
  data() {
    return {
      count: 0
    }
  },
  methods: {
    increment() {
      this.count++
    }
  }
}
</script>
```

---

相关文档:
- [VUE Skill](../../skills/vue/SKILL.md)
