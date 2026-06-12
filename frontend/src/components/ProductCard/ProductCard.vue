<template>
  <div class="product-card">
    <div class="product-image">
      <img :src="displayInfo.image" :alt="displayName" />
    </div>
    <div class="product-body">
      <h3 class="product-name">{{ displayName }}</h3>
      <p class="product-desc">{{ displayInfo.description }}</p>
      <div class="product-footer">
        <span class="product-price">¥{{ product.price.toFixed(2) }}</span>
        <button class="add-btn" @click="handleAdd">+ 加入购物车</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useCart } from '../../context/CartContext.js'
import { getProductDisplay } from '../../config/products.js'

const props = defineProps({
  product: { type: Object, required: true },
  restaurantId: { type: String, required: true },
  restaurantName: { type: String, default: '' }
})

const { addItem } = useCart()
const displayInfo = computed(() => getProductDisplay(props.product.productId))
const displayName = computed(() => displayInfo.value.displayName || props.product.name)

function handleAdd() {
  addItem({ ...props.product, displayName: displayName.value }, props.restaurantId, props.restaurantName)
}
</script>

<style scoped>
.product-card {
  background: white;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-card);
  display: flex;
  transition: box-shadow 0.2s, transform 0.2s;
}

.product-card:hover {
  box-shadow: var(--shadow-hover);
  transform: translateY(-2px);
}

.product-image {
  width: 140px;
  min-height: 120px;
  flex-shrink: 0;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-body {
  flex: 1;
  padding: 16px 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.product-name {
  font-size: 17px;
  font-weight: 700;
  color: var(--color-text);
  margin-bottom: 4px;
}

.product-desc {
  font-size: 13px;
  color: var(--color-text-light);
  line-height: 1.5;
  margin-bottom: 10px;
}

.product-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-price {
  font-size: 20px;
  font-weight: 700;
  color: var(--color-price);
}

.add-btn {
  background: var(--color-primary);
  color: white;
  padding: 8px 18px;
  border-radius: var(--radius);
  font-size: 13px;
  font-weight: 600;
  transition: background 0.2s;
  white-space: nowrap;
}

.add-btn:hover {
  background: var(--color-primary-dark);
}
</style>
