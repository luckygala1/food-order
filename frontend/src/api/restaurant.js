import axios from 'axios'

const api = axios.create({
  baseURL: '/restaurants',
  headers: {
    'Accept': 'application/vnd.api.v1+json'
  }
})

export async function getRestaurants() {
  const { data } = await api.get('')
  return data
}

export async function getRestaurantById(restaurantId) {
  const { data } = await api.get(`/${restaurantId}`)
  return data
}
