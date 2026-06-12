import axios from 'axios'

export async function getCustomers() {
  const response = await axios.get('/customers')
  return response.data
}
