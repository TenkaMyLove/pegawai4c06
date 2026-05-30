<template>
  <main class="login-page">
    <section class="login-shell">
      <div class="login-hero">
        <div class="hero-overlay"></div>

        <div class="hero-content">
          <div class="brand-large">
            <img src="../assets/images/logo-poliban.png" alt="Logo Poliban" />
            <div>
              <h1>Simpadu</h1>
              <p>Platform Akademik Digital</p>
            </div>
          </div>

          <div class="hero-title">
            <h2>
              Selamat Datang di<br />
              <span>Simpadu Poliban</span>
            </h2>
            <p>
              Kelola layanan akademik kampus secara lebih mudah, cepat, dan terpusat.
            </p>
          </div>

          <ul class="hero-list">
            <li>Dashboard admin dan dosen</li>
            <li>Data pegawai, absensi, jadwal, nilai, dan presensi</li>
            <li>Tampilan dibuat mengikuti desain Figma</li>
          </ul>
        </div>
      </div>

      <div class="login-panel">
        <form class="login-card" @submit.prevent="handleLogin">
          <h2>Masuk ke Sistem</h2>
          <p>Pilih peran Anda</p>

          <div class="role-grid">
            <button
              type="button"
              :class="['role-card', selectedRole === 'admin' && 'active']"
              @click="selectedRole = 'admin'"
            >
              <span>👨‍💼</span>
              <strong>Admin</strong>
            </button>

            <button
              type="button"
              :class="['role-card', selectedRole === 'dosen' && 'active']"
              @click="selectedRole = 'dosen'"
            >
              <span>👨‍🏫</span>
              <strong>Dosen</strong>
            </button>
          </div>

          <label>Email / Username / NIP</label>
          <input
            v-model="username"
            type="text"
            placeholder="Masukkan email, username, atau NIP"
          />

          <label>Password</label>
          <div class="password-wrapper">
            <input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="Masukkan password"
            />

            <button
              type="button"
              class="toggle-password"
              @click="showPassword = !showPassword"
            >
              {{ showPassword ? 'Sembunyikan' : 'Lihat' }}
            </button>
          </div>

          <p v-if="error" class="login-error">
            {{ error }}
          </p>

          <button class="login-button" type="submit" :disabled="loading">
            {{ loading ? 'Memproses...' : 'Masuk' }}
          </button>
        </form>
      </div>
    </section>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'

const router = useRouter()

const selectedRole = ref('admin')
const username = ref('')
const password = ref('')
const showPassword = ref(false)
const error = ref('')
const loading = ref(false)

function getToken(response) {
  return (
    response?.data?.token ||
    response?.data?.access_token ||
    response?.data?.data?.token ||
    response?.data?.data?.access_token
  )
}

function getUser(response) {
  return (
    response?.data?.user ||
    response?.data?.data?.user ||
    response?.data?.data ||
    response?.data
  )
}

function getRoleFromUser(user) {
  const role =
    user?.role ||
    user?.level ||
    user?.status_role ||
    user?.role_name ||
    user?.hak_akses ||
    ''

  const cleanRole = String(role).toLowerCase().trim()

  if (cleanRole.includes('admin')) return 'admin'
  if (cleanRole.includes('dosen')) return 'dosen'

  return ''
}

async function handleLogin() {
  error.value = ''

  if (!username.value || !password.value) {
    error.value = 'Login gagal'
    return
  }

  loading.value = true

  try {
    const response = await api.post('/api/login', {
      email: username.value,
      password: password.value,
    })

    const token = getToken(response)
    const user = getUser(response)

    const userRole = getRoleFromUser(user) || selectedRole.value

    if (userRole !== selectedRole.value) {
      error.value = 'Login gagal'
      return
    }

    if (token) {
      localStorage.setItem('simpadu_token', token)
    }

    localStorage.setItem('simpadu_logged_in', 'true')
    localStorage.setItem('simpadu_user', JSON.stringify(user))
    localStorage.setItem('simpadu_role', userRole)

    if (userRole === 'admin') {
      router.push('/admin/dashboard')
    } else if (userRole === 'dosen') {
      router.push('/dosen/dashboard')
    } else {
      error.value = 'Login gagal'
    }
  } catch (e) {
    console.log('LOGIN ERROR:', e?.response || e)
    error.value = 'Login gagal'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.password-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.password-wrapper input {
  width: 100%;
  padding-right: 100px;
}

.toggle-password {
  position: absolute;
  right: 14px;
  background: none;
  border: none;
  color: #2563eb;
  font-weight: 600;
  cursor: pointer;
  font-size: 14px;
}

.toggle-password:hover {
  color: #1d4ed8;
}

.login-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
</style>