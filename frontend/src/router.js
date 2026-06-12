import { createRouter, createWebHistory } from 'vue-router'
import HomePage from './pages/HomePage.vue'
import CheckoutPage from './pages/CheckoutPage.vue'
import PaymentPage from './pages/PaymentPage.vue'
import OrderTrackingPage from './pages/OrderTrackingPage.vue'

const routes = [
  { path: '/', name: 'Home', component: HomePage },
  { path: '/checkout', name: 'Checkout', component: CheckoutPage },
  { path: '/payment/:trackingId', name: 'Payment', component: PaymentPage },
  { path: '/track/:trackingId?', name: 'Track', component: OrderTrackingPage }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
