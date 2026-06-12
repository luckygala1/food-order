<template>
  <header class="header">
    <router-link to="/" class="logo">美食外卖</router-link>
    <router-link to="/checkout" class="cart-btn">
      <span class="cart-icon">&#128722;</span>
      我的购物车
      <span v-if="totalItems > 0" class="badge">{{ totalItems }}</span>
    </router-link>
  </header>
</template>

<script setup>
import { computed } from 'vue'
import { useCart } from '../../context/CartContext.js'

const { getTotalItems } = useCart()
const totalItems = computed(() => getTotalItems())
</script>

<style scoped>
.header {
  background: var(--color-primary);
  color: var(--color-text-white);
  padding: 16px 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.logo {
  font-size: 24px;
  font-weight: 700;
  color: var(--color-text-white);
  letter-spacing: -0.5px;
}

.cart-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--color-primary-dark);
  color: var(--color-text-white);
  padding: 10px 20px;
  border-radius: var(--radius);
  font-size: 14px;
  font-weight: 600;
  transition: background 0.2s;
}

.cart-btn:hover {
  background: var(--color-primary-light);
}

.cart-icon {
  font-size: 18px;
}

.badge {
  background: var(--color-danger);
  color: white;
  border-radius: 50%;
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
}
</style>
