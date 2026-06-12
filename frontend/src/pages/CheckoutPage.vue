<template>
  <div class="checkout">
    <div class="checkout-container">
      <div class="page-header">
        <router-link to="/" class="back-btn">&larr; 返回首页</router-link>
        <h1>结算</h1>
      </div>

      <div v-if="state.items.length === 0" class="empty-cart">
        <p>购物车是空的。</p>
        <router-link to="/" class="back-link">浏览菜单</router-link>
      </div>

      <template v-else>
        <div class="checkout-grid">
          <div class="order-section">
            <h2>订单摘要</h2>
            <p class="restaurant-name" v-if="state.restaurantName">{{ state.restaurantName }}</p>
            <div v-for="item in state.items" :key="item.productId" class="order-item">
              <span>{{ item.name }} x {{ item.quantity }}</span>
              <span class="item-total">¥{{ (item.price * item.quantity).toFixed(2) }}</span>
            </div>
            <div class="order-total">
              <span>合计</span>
              <span class="total-amount">¥{{ totalPrice.toFixed(2) }}</span>
            </div>
          </div>

          <div class="address-section">
            <h2>配送信息</h2>
            <form @submit.prevent="handleOrder" class="address-form">
              <div class="form-group">
                <label for="recipientName">收货人</label>
                <input id="recipientName" v-model="address.recipientName" type="text" required maxlength="20" placeholder="请输入收货人姓名" />
              </div>
              <div class="form-group">
                <label for="phone">联系电话</label>
                <input id="phone" v-model="address.phone" type="tel" required maxlength="20" placeholder="请输入手机号码" />
              </div>
              <div class="form-group">
                <label for="street">配送地址</label>
                <input id="street" v-model="address.street" type="text" required maxlength="50" placeholder="请输入配送地址" />
              </div>
              <div class="form-group">
                <label for="doorNumber">门牌号</label>
                <input id="doorNumber" v-model="address.doorNumber" type="text" required maxlength="10" placeholder="请输入门牌号" />
              </div>

              <div v-if="orderError" class="error-msg">{{ orderError }}</div>

              <button type="submit" class="place-order-btn" :disabled="ordering">
                {{ ordering ? '下单中...' : '提交订单' }}
              </button>
            </form>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCart } from '../context/CartContext.js'
import { createOrder } from '../api/order.js'
import { getCustomers } from '../api/customer.js'

const router = useRouter()
const { state, getTotalPrice, clearCart } = useCart()
const totalPrice = computed(() => getTotalPrice())

const address = ref({ street: '', recipientName: '', phone: '', doorNumber: '' })
const customerId = ref('')
const ordering = ref(false)
const orderError = ref(null)

onMounted(async () => {
  try {
    const customers = await getCustomers()
    if (customers.length > 0) {
      customerId.value = customers[0].id
    }
  } catch (e) {
    console.error('Failed to load customers', e)
  }
})

async function handleOrder() {
  ordering.value = true
  orderError.value = null

  try {
    const orderData = {
      customerId: customerId.value,
      restaurantId: state.restaurantId,
      price: totalPrice.value,
      items: state.items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        subTotal: item.price * item.quantity
      })),
      address: {
        street: address.value.street,
        doorNumber: address.value.doorNumber,
        recipientName: address.value.recipientName,
        phone: address.value.phone
      }
    }

    const response = await createOrder(orderData)
    clearCart()
    const paymentData = {
      trackingId: response.trackingId,
      restaurantName: state.restaurantName,
      items: state.items.map(item => ({
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity
      })),
      price: totalPrice.value,
      address: { ...address.value }
    }
    router.push({
      name: 'Payment',
      params: { trackingId: response.trackingId },
      query: { data: JSON.stringify(paymentData) }
    })
  } catch (e) {
    orderError.value = e.response?.data?.message || '下单失败，请重试。'
    console.error(e)
  } finally {
    ordering.value = false
  }
}
</script>

<style scoped>
.checkout {
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

.checkout-container {
  max-width: 900px;
  margin: 0 auto;
}

h1 {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 24px;
}

.empty-cart {
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

.checkout-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
}

.order-section, .address-section {
  background: white;
  border-radius: var(--radius-lg);
  padding: 24px;
  box-shadow: var(--shadow-card);
}

h2 {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 16px;
}

.restaurant-name {
  font-size: 13px;
  color: var(--color-text-light);
  margin-bottom: 12px;
}

.order-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid var(--color-border);
  font-size: 14px;
}

.item-total {
  font-weight: 600;
}

.order-total {
  display: flex;
  justify-content: space-between;
  padding: 12px 0 0;
  font-size: 18px;
  font-weight: 700;
}

.total-amount {
  color: var(--color-price);
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 6px;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  font-size: 14px;
  transition: border-color 0.2s;
  background: white;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--color-primary);
}

.error-msg {
  color: var(--color-danger);
  font-size: 14px;
  margin-bottom: 12px;
  padding: 8px 12px;
  background: #FEE;
  border-radius: var(--radius);
}

.place-order-btn {
  width: 100%;
  padding: 14px;
  background: var(--color-primary);
  color: white;
  border-radius: var(--radius);
  font-size: 16px;
  font-weight: 600;
  transition: background 0.2s;
}

.place-order-btn:hover:not(:disabled) {
  background: var(--color-primary-dark);
}

.place-order-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .checkout-grid {
    grid-template-columns: 1fr;
  }
}
</style>
