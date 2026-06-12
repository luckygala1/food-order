import { reactive } from 'vue'

const state = reactive({
  items: [],
  restaurantId: null,
  restaurantName: ''
})

export function useCart() {
  function addItem(product, restaurantId, restaurantName) {
    if (state.restaurantId && state.restaurantId !== restaurantId) {
      if (!confirm('添加不同餐厅的商品将清空当前购物车，是否继续？')) {
        return
      }
      state.items = []
    }
    state.restaurantId = restaurantId
    state.restaurantName = restaurantName

    const existing = state.items.find(item => item.productId === product.productId)
    if (existing) {
      existing.quantity++
    } else {
      state.items.push({
        productId: product.productId,
        name: product.displayName || product.name,
        price: product.price,
        quantity: 1
      })
    }
  }

  function removeItem(productId) {
    const index = state.items.findIndex(item => item.productId === productId)
    if (index > -1) {
      state.items.splice(index, 1)
    }
    if (state.items.length === 0) {
      state.restaurantId = null
      state.restaurantName = ''
    }
  }

  function updateQuantity(productId, quantity) {
    const item = state.items.find(item => item.productId === productId)
    if (item) {
      if (quantity <= 0) {
        removeItem(productId)
      } else {
        item.quantity = quantity
      }
    }
  }

  function clearCart() {
    state.items = []
    state.restaurantId = null
    state.restaurantName = ''
  }

  function getTotalPrice() {
    return state.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  }

  function getTotalItems() {
    return state.items.reduce((sum, item) => sum + item.quantity, 0)
  }

  return {
    state,
    addItem,
    removeItem,
    updateQuantity,
    clearCart,
    getTotalPrice,
    getTotalItems
  }
}
