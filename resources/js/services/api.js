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

  // CORS fix: If the request is external, disable withCredentials to allow wildcard (*) origins
  const isExternal = config.url && (config.url.startsWith('http://') || config.url.startsWith('https://'))
  const isLocalDomain = config.url && config.url.includes('api-pegawai-4c.akufarish.my.id')

  if (isExternal && !isLocalDomain) {
    config.withCredentials = false
    
    // Automatically attach Rifki's Bearer token for Rifki's endpoints
    if (config.url.includes('rifkiaja.my.id')) {
      const rifkiToken = localStorage.getItem('rifki_api_token')
      if (rifkiToken) {
        config.headers.Authorization = `Bearer ${rifkiToken}`
      }
    }
  } else if (token) {
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