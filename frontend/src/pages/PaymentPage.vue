<template>
  <div class="payment">
    <div class="payment-container">
      <div class="page-header">
        <router-link to="/" class="back-btn">&larr; 返回首页</router-link>
        <h1>确认支付</h1>
      </div>

      <div v-if="!orderData" class="empty-order">
        <p>订单信息丢失，请重新下单。</p>
        <router-link to="/" class="back-link">返回首页</router-link>
      </div>

      <template v-else>
        <div class="payment-card">
          <div class="order-info">
            <div class="info-row">
              <span class="info-label">餐厅</span>
              <span class="info-value">{{ orderData.restaurantName }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">追踪编号</span>
              <span class="info-value tracking-id">{{ orderData.trackingId }}</span>
            </div>
          </div>

          <div class="order-items">
            <h3>订单详情</h3>
            <div v-for="item in orderData.items" :key="item.productId" class="order-item">
              <img :src="getItemImage(item.productId)" class="item-image" />
              <div class="item-info">
                <span class="item-name">{{ getItemName(item.productId, item.name) }}</span>
                <span class="item-qty">x{{ item.quantity }}</span>
              </div>
              <span class="item-price">¥{{ (item.price * item.quantity).toFixed(2) }}</span>
            </div>
          </div>

          <div class="order-address">
            <h3>配送信息</h3>
            <p>{{ orderData.address.recipientName }} · {{ orderData.address.phone }}</p>
            <p>{{ orderData.address.street }} {{ orderData.address.doorNumber }}</p>
          </div>

          <div class="order-total">
            <span>应付金额</span>
            <span class="total-amount">¥{{ orderData.price.toFixed(2) }}</span>
          </div>

          <button class="pay-btn" @click="confirmPayment">
            确认支付 ¥{{ orderData.price.toFixed(2) }}
          </button>

          <p class="pay-hint">点击确认支付后，系统将自动处理支付并通知商家</p>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getProductDisplay } from '../config/products.js'

const router = useRouter()
const route = useRoute()

const orderData = computed(() => {
  try {
    return JSON.parse(route.query.data)
  } catch {
    return null
  }
})

function getItemName(productId, fallbackName) {
  const display = getProductDisplay(productId)
  return display.displayName || fallbackName || '未知菜品'
}

function getItemImage(productId) {
  return getProductDisplay(productId).image
}

function confirmPayment() {
  router.push({ name: 'Track', params: { trackingId: orderData.value.trackingId } })
}
</script>

<style scoped>
.payment {
  padding: 40px 20px;
}

.page-header {
  margin-bottom: 24px;
}

.back-btn {
  display: inline-block;
  color: var(--color-primary);
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 8px;
  transition: color 0.2s;
}

.back-btn:hover {
  color: var(--color-primary-dark);
}

.payment-container {
  max-width: 600px;
  margin: 0 auto;
}

h1 {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 24px;
}

.empty-order {
  text-align: center;
  padding: 60px 20px;
  color: var(--color-text-light);
}

.back-link {
  display: inline-block;
  margin-top: 12px;
  color: var(--color-primary);
  font-weight: 600;
}

.payment-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 28px;
  box-shadow: var(--shadow-card);
}

.order-info {
  padding-bottom: 16px;
  border-bottom: 1px solid var(--color-border);
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.info-label {
  font-size: 14px;
  color: var(--color-text-light);
}

.info-value {
  font-size: 14px;
  font-weight: 600;
}

.tracking-id {
  font-family: monospace;
  color: var(--color-primary);
}

.order-items h3,
.order-address h3 {
  font-size: 16px;
  font-weight: 700;
  margin-bottom: 12px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border);
}

.item-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  object-fit: cover;
}

.item-info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
}

.item-name {
  font-size: 14px;
  font-weight: 600;
}

.item-qty {
  font-size: 13px;
  color: var(--color-text-light);
}

.item-price {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-price);
}

.order-address {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid var(--color-border);
}

.order-address p {
  font-size: 14px;
  color: var(--color-text);
  margin-bottom: 4px;
}

.order-total {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 24px;
  padding-top: 16px;
  border-top: 2px solid var(--color-border);
  font-size: 18px;
  font-weight: 700;
}

.total-amount {
  color: var(--color-price);
  font-size: 24px;
}

.pay-btn {
  width: 100%;
  margin-top: 24px;
  padding: 16px;
  background: var(--color-success, #2E7D32);
  color: white;
  border-radius: var(--radius);
  font-size: 18px;
  font-weight: 700;
  transition: background 0.2s;
}

.pay-btn:hover {
  background: #1B5E20;
}

.pay-hint {
  text-align: center;
  font-size: 13px;
  color: var(--color-text-light);
  margin-top: 12px;
}
</style>
