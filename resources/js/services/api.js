import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'https://api-pegawai-4c.akufarish.my.id:9001/',
  timeout: 20000,
  withCredentials: true,
  headers: {
    Accept: 'application/json',
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('simpadu_token')

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error?.response?.status === 401) {
      localStorage.removeItem('simpadu_token')
      localStorage.removeItem('simpadu_user')
      localStorage.removeItem('simpadu_role')
    }

    return Promise.reject(error)
  }
)

export default api