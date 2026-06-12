<template>
  <div v-if="isOpen" class="cart-overlay" @click.self="$emit('close')">
    <div class="cart-panel">
      <div class="cart-header">
        <h2>我的购物车</h2>
        <button class="close-btn" @click="$emit('close')">&times;</button>
      </div>

      <div v-if="state.items.length === 0" class="cart-empty">
        <p>购物车是空的</p>
      </div>

      <div v-else class="cart-content">
        <p class="restaurant-label" v-if="state.restaurantName">{{ state.restaurantName }}</p>
        <div v-for="item in state.items" :key="item.productId" class="cart-item">
          <div class="item-info">
            <span class="item-name">{{ item.name }}</span>
            <span class="item-price">¥{{ (item.price * item.quantity).toFixed(2) }}</span>
          </div>
          <div class="item-controls">
            <button class="qty-btn" @click="updateQuantity(item.productId, item.quantity - 1)">-</button>
            <span class="qty">{{ item.quantity }}</span>
            <button class="qty-btn" @click="updateQuantity(item.productId, item.quantity + 1)">+</button>
            <button class="remove-btn" @click="removeItem(item.productId)">删除</button>
          </div>
        </div>

        <div class="cart-total">
          <span>合计</span>
          <span class="total-price">¥{{ totalPrice.toFixed(2) }}</span>
        </div>

        <router-link to="/checkout" class="checkout-btn" @click="$emit('close')">
          去结算
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useCart } from '../../context/CartContext.js'

defineProps({ isOpen: Boolean })
defineEmits(['close'])

const { state, removeItem, updateQuantity, getTotalPrice } = useCart()
const totalPrice = computed(() => getTotalPrice())
</script>

<style scoped>
.cart-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  z-index: 200;
  display: flex;
  justify-content: flex-end;
}

.cart-panel {
  width: 400px;
  max-width: 90vw;
  background: white;
  height: 100%;
  display: flex;
  flex-direction: column;
  box-shadow: -4px 0 20px rgba(0,0,0,0.15);
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid var(--color-border);
}

.cart-header h2 {
  font-size: 20px;
  font-weight: 700;
}

.close-btn {
  background: none;
  font-size: 28px;
  color: var(--color-text-light);
  padding: 0 4px;
}

.cart-empty {
  padding: 60px 24px;
  text-align: center;
  color: var(--color-text-light);
}

.cart-content {
  flex: 1;
  overflow-y: auto;
  padding: 16px 24px;
}

.restaurant-label {
  font-size: 13px;
  color: var(--color-text-light);
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--color-border);
}

.cart-item {
  padding: 12px 0;
  border-bottom: 1px solid var(--color-border);
}

.item-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.item-name {
  font-weight: 600;
  font-size: 15px;
}

.item-price {
  font-weight: 600;
  color: var(--color-price);
}

.item-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.qty-btn {
  width: 28px;
  height: 28px;
  border-radius: 4px;
  background: var(--color-bg-light);
  font-size: 16px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
}

.qty-btn:hover {
  background: var(--color-border);
}

.qty {
  font-weight: 600;
  min-width: 20px;
  text-align: center;
}

.remove-btn {
  background: none;
  color: var(--color-danger);
  font-size: 13px;
  margin-left: 8px;
}

.cart-total {
  display: flex;
  justify-content: space-between;
  padding: 16px 0;
  font-size: 18px;
  font-weight: 700;
  border-top: 2px solid var(--color-text);
  margin-top: 8px;
}

.total-price {
  color: var(--color-price);
}

.checkout-btn {
  display: block;
  width: 100%;
  padding: 14px;
  background: var(--color-primary);
  color: white;
  text-align: center;
  border-radius: var(--radius);
  font-size: 16px;
  font-weight: 600;
  margin-top: 12px;
  transition: background 0.2s;
}

.checkout-btn:hover {
  background: var(--color-primary-dark);
}
</style>
