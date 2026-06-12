import axios from 'axios'

const api = axios.create({
  baseURL: '/orders',
  headers: {
    'Accept': 'application/vnd.api.v1+json',
    'Content-Type': 'application/vnd.api.v1+json'
  }
})

export async function createOrder(orderData) {
  const { data } = await api.post('', orderData)
  return data
}

export async function trackOrder(trackingId) {
  const { data } = await api.get(`/${trackingId}`)
  return data
}
