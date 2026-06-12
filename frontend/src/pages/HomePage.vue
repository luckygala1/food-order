<template>
  <div class="home">
    <HeroBanner />

    <section class="menu-section">
      <div class="menu-container">
        <div v-if="loading" class="loading">
          <p>正在加载美食...</p>
        </div>

        <div v-else-if="error" class="error">
          <p>{{ error }}</p>
          <button @click="fetchRestaurants" class="retry-btn">重试</button>
        </div>

        <template v-else>
          <div v-for="restaurant in restaurants" :key="restaurant.restaurantId" class="restaurant-group">
            <div class="restaurant-header">
              <h2 class="restaurant-name">{{ getRestaurantName(restaurant.restaurantId) }}</h2>
              <p class="restaurant-desc">{{ getRestaurantDesc(restaurant.restaurantId) }}</p>
            </div>
            <div class="products-grid">
              <ProductCard
                v-for="product in restaurant.products.filter(p => p.available)"
                :key="product.productId"
                :product="product"
                :restaurant-id="restaurant.restaurantId"
                :restaurant-name="getRestaurantName(restaurant.restaurantId)"
              />
            </div>
          </div>
        </template>
      </div>
    </section>

    <Cart :is-open="cartOpen" @close="cartOpen = false" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import HeroBanner from '../components/HeroBanner/HeroBanner.vue'
import ProductCard from '../components/ProductCard/ProductCard.vue'
import Cart from '../components/Cart/Cart.vue'
import { getRestaurants } from '../api/restaurant.js'
import { getRestaurantDisplay } from '../config/products.js'

const restaurants = ref([])
const loading = ref(true)
const error = ref(null)
const cartOpen = ref(false)

function getRestaurantName(id) {
  const display = getRestaurantDisplay(id)
  const restaurant = restaurants.value.find(r => r.restaurantId === id)
  return display.displayName || restaurant?.name || '餐厅'
}

function getRestaurantDesc(id) {
  return getRestaurantDisplay(id).description
}

async function fetchRestaurants() {
  loading.value = true
  error.value = null
  try {
    restaurants.value = await getRestaurants()
  } catch (e) {
    error.value = '加载餐厅失败，请确保后端服务已启动。'
    console.error(e)
  } finally {
    loading.value = false
  }
}

onMounted(fetchRestaurants)
</script>

<style scoped>
.menu-section {
  padding: 40px 20px;
}

.menu-container {
  max-width: 800px;
  margin: 0 auto;
}

.loading, .error {
  text-align: center;
  padding: 60px 20px;
  color: var(--color-text-light);
}

.error {
  color: var(--color-danger);
}

.retry-btn {
  margin-top: 12px;
  padding: 10px 24px;
  background: var(--color-primary);
  color: white;
  border-radius: var(--radius);
  font-weight: 600;
}

.restaurant-group {
  margin-bottom: 40px;
}

.restaurant-header {
  margin-bottom: 20px;
}

.restaurant-name {
  font-size: 24px;
  font-weight: 700;
  color: var(--color-text);
  margin-bottom: 4px;
}

.restaurant-desc {
  font-size: 14px;
  color: var(--color-text-light);
}

.products-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
</style>
