<template>
  <div class="tracking">
    <div class="tracking-container">
      <div class="page-header">
        <router-link to="/" class="back-btn">&larr; 返回首页</router-link>
        <h1>订单追踪</h1>
      </div>

      <div class="search-box">
        <input
          v-model="inputTrackingId"
          type="text"
          placeholder="请输入您的追踪编号"
          @keyup.enter="trackOrder"
        />
        <button @click="trackOrder" :disabled="loading || !inputTrackingId.trim()">
          {{ loading ? '查询中...' : '追踪' }}
        </button>
      </div>

      <div v-if="error" class="error-msg">{{ error }}</div>

      <div v-if="order" class="order-status-card">
        <div class="status-header">
          <span class="tracking-label">追踪编号</span>
          <span class="tracking-id">{{ order.orderTrackingId }}</span>
        </div>

        <div class="status-flow">
          <div v-for="(step, index) in statusSteps" :key="step.key" class="status-step" :class="getStepClass(step.key, index)">
            <div class="step-dot"></div>
            <span class="step-label">{{ step.label }}</span>
          </div>
        </div>

        <div class="current-status">
          <span class="status-label">当前状态：</span>
          <span class="status-value" :class="'status-' + order.orderStatus.toLowerCase()">
            {{ currentStatusText }}
          </span>
          <span v-if="shouldPoll()" class="polling-dot"></span>
        </div>

        <div v-if="order.failureMessages && order.failureMessages.length > 0" class="failure-messages">
          <p v-for="(msg, i) in order.failureMessages" :key="i" class="failure-msg">{{ msg }}</p>
        </div>

        <div v-if="order.items && order.items.length > 0" class="order-items">
          <h3>订单详情</h3>
          <div v-for="item in order.items" :key="item.productId" class="order-item">
            <img :src="getItemImage(item.productId)" class="item-image" />
            <div class="item-info">
              <span class="item-name">{{ getItemName(item.productId, item.productName) }}</span>
              <span class="item-qty">x{{ item.quantity }}</span>
            </div>
            <span class="item-price">¥{{ item.subTotal.toFixed(2) }}</span>
          </div>
          <div class="order-total">
            <span>合计</span>
            <span class="total-amount">¥{{ order.price.toFixed(2) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { trackOrder as trackOrderApi } from '../api/order.js'
import { getProductDisplay } from '../config/products.js'

const route = useRoute()
const inputTrackingId = ref(route.params.trackingId || '')
const order = ref(null)
const loading = ref(false)
const error = ref(null)
let pollTimer = null

const statusSteps = [
  { key: 'PENDING', label: '待支付' },
  { key: 'PAID', label: '已支付' },
  { key: 'APPROVED', label: '商家已接单' }
]

const statusOrder = ['PENDING', 'PAID', 'APPROVED']

const statusText = {
  PENDING: '待支付',
  PAID: '已支付，等待商家确认',
  APPROVED: '商家已接单',
  CANCELLING: '取消中',
  CANCELLED: '已取消'
}

const currentStatusText = computed(() => {
  if (!order.value) return ''
  return statusText[order.value.orderStatus] || order.value.orderStatus
})

function getStepClass(stepKey, index) {
  if (!order.value) return ''
  const currentIdx = statusOrder.indexOf(order.value.orderStatus)
  if (order.value.orderStatus === 'CANCELLED' || order.value.orderStatus === 'CANCELLING') {
    return index <= currentIdx ? 'step-active step-cancelled' : ''
  }
  return index <= currentIdx ? 'step-active' : ''
}

function getItemName(productId, fallbackName) {
  const display = getProductDisplay(productId)
  return display.displayName || fallbackName || '未知菜品'
}

function getItemImage(productId) {
  return getProductDisplay(productId).image
}

function shouldPoll() {
  if (!order.value) return false
  return order.value.orderStatus === 'PENDING' || order.value.orderStatus === 'PAID'
}

async function fetchOrder() {
  if (!inputTrackingId.value.trim()) return
  try {
    order.value = await trackOrderApi(inputTrackingId.value.trim())
    error.value = null
  } catch (e) {
    if (!order.value) {
      error.value = e.response?.data?.message || '未找到订单，请检查您的追踪编号。'
    }
  }
}

function startPolling() {
  stopPolling()
  if (shouldPoll()) {
    pollTimer = setInterval(async () => {
      await fetchOrder()
      if (!shouldPoll()) {
        stopPolling()
      }
    }, 3000)
  }
}

function stopPolling() {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
}

async function trackOrder() {
  if (!inputTrackingId.value.trim()) return
  loading.value = true
  error.value = null
  order.value = null

  try {
    order.value = await trackOrderApi(inputTrackingId.value.trim())
    startPolling()
  } catch (e) {
    error.value = e.response?.data?.message || '未找到订单，请检查您的追踪编号。'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (route.params.trackingId) {
    trackOrder()
  }
})

onUnmounted(() => {
  stopPolling()
})
</script>

<style scoped>
.tracking {
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

.tracking-container {
  max-width: 600px;
  margin: 0 auto;
}

h1 {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 24px;
}

.search-box {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
}

.search-box input {
  flex: 1;
  padding: 12px 16px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  font-size: 15px;
}

.search-box input:focus {
  outline: none;
  border-color: var(--color-primary);
}

.search-box button {
  padding: 12px 24px;
  background: var(--color-primary);
  color: white;
  border-radius: var(--radius);
  font-weight: 600;
  transition: background 0.2s;
}

.search-box button:hover:not(:disabled) {
  background: var(--color-primary-dark);
}

.search-box button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-msg {
  color: var(--color-danger);
  font-size: 14px;
  margin-bottom: 16px;
  padding: 10px 14px;
  background: #FEE;
  border-radius: var(--radius);
}

.order-status-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 28px;
  box-shadow: var(--shadow-card);
}

.status-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--color-border);
}

.tracking-label {
  font-size: 13px;
  color: var(--color-text-light);
}

.tracking-id {
  font-size: 14px;
  font-weight: 600;
  font-family: monospace;
  color: var(--color-primary);
}

.status-flow {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
  position: relative;
}

.status-flow::before {
  content: '';
  position: absolute;
  top: 10px;
  left: 10%;
  right: 10%;
  height: 2px;
  background: var(--color-border);
}

.status-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  z-index: 1;
}

.step-dot {
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: var(--color-border);
  border: 3px solid white;
  box-shadow: 0 0 0 2px var(--color-border);
  transition: all 0.3s;
}

.step-active .step-dot {
  background: var(--color-success);
  box-shadow: 0 0 0 2px var(--color-success);
}

.step-cancelled .step-dot {
  background: var(--color-danger);
  box-shadow: 0 0 0 2px var(--color-danger);
}

.step-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text-light);
}

.step-active .step-label {
  color: var(--color-success);
}

.step-cancelled .step-label {
  color: var(--color-danger);
}

.current-status {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-label {
  font-size: 14px;
  color: var(--color-text-light);
}

.status-value {
  font-size: 16px;
  font-weight: 700;
  padding: 4px 12px;
  border-radius: 4px;
}

.status-pending {
  background: #FFF3E0;
  color: #E65100;
}

.status-paid {
  background: #E3F2FD;
  color: #1565C0;
}

.status-approved {
  background: #E8F5E9;
  color: #2E7D32;
}

.status-cancelled, .status-cancelling {
  background: #FFEBEE;
  color: #C62828;
}

.failure-messages {
  margin-top: 16px;
  padding: 12px;
  background: #FFF8E1;
  border-radius: var(--radius);
}

.failure-msg {
  font-size: 13px;
  color: var(--color-danger);
  margin-bottom: 4px;
}

.order-items {
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid var(--color-border);
}

.order-items h3 {
  font-size: 16px;
  font-weight: 700;
  margin-bottom: 16px;
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

.order-total {
  display: flex;
  justify-content: space-between;
  padding: 12px 0 0;
  font-size: 16px;
  font-weight: 700;
}

.total-amount {
  color: var(--color-price);
}

.polling-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-success, #2E7D32);
  margin-left: 8px;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}
</style>
