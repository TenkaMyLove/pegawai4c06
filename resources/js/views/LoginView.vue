<template>
  <main class="login-page">
    <section class="login-shell">
      <div class="login-hero">
        <div class="hero-content">
          <div class="brand-large">
            <img :src="logoUrl" alt="Logo Poliban" />
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
            <li>Dashboard admin dan pegawai</li>
            <li>Pegawai akan diklasifikasikan otomatis sebagai pegawai atau dosen</li>
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
              <span class="role-icon">🛡️</span>
              <strong>Admin</strong>
            </button>

            <button
              type="button"
              :class="['role-card', selectedRole === 'pegawai' && 'active']"
              @click="selectedRole = 'pegawai'"
            >
              <span class="role-icon">👤</span>
              <strong>Pegawai</strong>
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
const logoUrl = '/assets/images/logo-poliban.png'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/services/api'

const router = useRouter()

const selectedRole = ref('admin')
const username = ref('')
const password = ref('')
const showPassword = ref(false)
const error = ref('')
const loading = ref(false)

/**
 * Opsi login hanya 2:
 * - admin
 * - pegawai
 *
 * Dosen tidak tampil sebagai opsi.
 * Jika user memilih pegawai, hasil dari API bisa diklasifikasikan sebagai:
 * - pegawai
 * - dosen
 */
const roleHome = {
  admin: '/admin/dashboard',
  dosen: '/dosen/dashboard',
  pegawai: '/pegawai/profil',
}

const roleEndpoints = {
  admin: ['/api/login'],
  pegawai: ['/api/login'],
}

function getLoginValue() {
  return String(username.value || '').trim()
}

function buildLoginPayload(role = selectedRole.value) {
  const loginValue = getLoginValue()

  return {
    email: loginValue,
    username: loginValue,
    nip: loginValue,
    login: loginValue,
    password: password.value,
    role,
    tipe: role,
  }
}

function getToken(response) {
  return (
    response?.data?.token ||
    response?.data?.access_token ||
    response?.data?.data?.token ||
    response?.data?.data?.access_token ||
    response?.data?.user?.token ||
    ''
  )
}

function getUser(response) {
  const data = response?.data || {}
  const wrapper = data.data || {}
  const baseUser = data.user || wrapper.user || {}
  const pegawai = data.pegawai || wrapper.pegawai || {}
  const dosen = data.dosen || wrapper.dosen || null
  const admin = data.admin || wrapper.admin || {}
  const permissions = data.permissions || wrapper.permissions || {}

  return {
    ...baseUser,
    ...pegawai,
    ...(dosen || {}),
    ...admin,
    permissions,
    _source_user: baseUser,
    _source_pegawai: pegawai,
    _source_dosen: dosen,
    _source_admin: admin,
  }
}

function normalizeRole(value, fallback = selectedRole.value) {
  const role = String(value || fallback).toLowerCase().trim()

  if (role.includes('admin')) return 'admin'
  if (role.includes('dosen')) return 'dosen'
  if (role.includes('pegawai')) return 'pegawai'

  return fallback
}

function getRoleFromUser(user) {
  if (user?.permissions?.is_admin) return 'admin'
  if (user?.permissions?.is_dosen) return 'dosen'

  const roleId = Number(user?.ID_ROLE || user?.id_role || user?._source_user?.ID_ROLE || 0)
  if (roleId === 1) return 'admin'
  if (roleId === 2) return 'dosen'
  if (roleId === 3) return 'pegawai'

  if (user?._source_dosen || user?.id_dosen || user?.nama_dosen) return 'dosen'

  const jabatanText = Array.isArray(user?.jabatan)
    ? user.jabatan.map((item) => item?.nama_jabatan || item?.nama || item?.jabatan || '').join(' ')
    : String(user?.jabatan || user?.unit_kerja || user?.UNIT_KERJA || '')

  if (jabatanText.toLowerCase().includes('dosen')) return 'dosen'
  if (user?.permissions?.is_pegawai) return 'pegawai'

  return normalizeRole(user?.role, 'pegawai')
}

function normalizeUser(raw, role) {
  const name =
    raw?.name ||
    raw?.nama ||
    raw?.nama_pegawai ||
    raw?.NAMA_PEGAWAI ||
    raw?.nama_dosen ||
    raw?.panggilan ||
    ''

  const email = raw?.email || raw?.EMAIL || getLoginValue()

  return {
    ...raw,
    name: name || raw?.username || email,
    email,
    role,
  }
}

function getReadableLoginError(e) {
  const status = e?.response?.status
  const msg =
    e?.response?.data?.message ||
    e?.response?.data?.error ||
    e?.response?.data?.errors ||
    e?.message ||
    'Login gagal'

  if (status === 401) return 'Email/NIP atau password salah.'
  if (status === 422) return 'Data login tidak valid.'
  return typeof msg === 'string' ? msg : 'Login gagal.'
}

async function postLoginByRole(role = selectedRole.value) {
  const endpoints = roleEndpoints[role] || roleEndpoints.pegawai
  const endpoint = endpoints[0] || '/api/login'
  const payload = buildLoginPayload(role)

  return api.post(endpoint, payload)
}

async function handleLogin() {
  error.value = ''

  if (!username.value || !password.value) {
    error.value = 'Email/NIP dan password wajib diisi.'
    return
  }

  loading.value = true

  try {
    const requestedOption = selectedRole.value
    let token = ''
    let rawUser = null
    let apiRole = ''
    let isRifkiLogin = false

    // Try Rifki's login first
    let rifkiToken = ''
    try {
      const payload = {
        email: String(username.value).trim(),
        password: password.value
      }
      const rifkiResponse = await fetch('https://api-admin-4c.rifkiaja.my.id:9002/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify(payload)
      })
      if (rifkiResponse.ok) {
        const resJson = await rifkiResponse.json()
        rifkiToken = resJson?.token || resJson?.access_token || resJson?.data?.token || resJson?.data?.access_token || ''
        if (rifkiToken) {
          rawUser = getUser({ data: resJson })
          apiRole = getRoleFromUser(rawUser)
          if (!apiRole || apiRole === 'pegawai') {
            apiRole = 'dosen'
          }
          isRifkiLogin = true
          localStorage.setItem('rifki_api_token', rifkiToken)
          localStorage.setItem('rifki_token_timestamp', Date.now().toString())
        }
      } else {
        const errText = await rifkiResponse.text()
        console.warn("Rifki API login failed status:", rifkiResponse.status, errText)
      }
    } catch (rifkiError) {
      console.warn("Gagal login ke API Rifki, mencoba login lokal...", rifkiError)
    }

    // Always log in locally to get the local Sanctum token
    let localToken = ''
    let localRawUser = null
    let localApiRole = ''
    try {
      const response = await postLoginByRole(requestedOption)
      localToken = getToken(response)
      localRawUser = getUser(response)
      localApiRole = getRoleFromUser(localRawUser)
    } catch (localError) {
      console.warn("Gagal login lokal:", localError)
    }

    // Determine final values
    if (localToken) {
      token = localToken
      rawUser = localRawUser || rawUser
      apiRole = localApiRole || apiRole
    } else if (rifkiToken) {
      // Use user-provided local bearer token to prevent 401s on local API endpoints
      token = '264|ys67ffrV3ZtDDjk8KuzytYGAXy5yIAVzMNfIZljD341b1a37'
    } else {
      error.value = 'Login gagal. Silakan periksa kembali email dan password Anda.'
      loading.value = false
      return
    }

    const finalRole = normalizeRole(apiRole, requestedOption)

    if (requestedOption === 'admin' && finalRole !== 'admin') {
      error.value = 'Akun ini bukan role admin.'
      return
    }

    if (requestedOption === 'pegawai' && !['pegawai', 'dosen'].includes(finalRole)) {
      error.value = 'Akun ini bukan role pegawai atau dosen.'
      return
    }

    const user = normalizeUser(rawUser, finalRole)

    if (token) localStorage.setItem('simpadu_token', token)
    localStorage.setItem('simpadu_logged_in', 'true')
    localStorage.setItem('simpadu_user', JSON.stringify(user))
    localStorage.setItem('simpadu_role', finalRole)

    // Store credentials for automatic token refreshing
    localStorage.setItem('simpadu_u', username.value)
    localStorage.setItem('simpadu_p', password.value)

    // bersihin sisa dual-login biar repo rapi
    localStorage.removeItem('simpadu_auth_token')
    localStorage.removeItem('simpadu_auth_user')

    router.push(roleHome[finalRole] || '/')
  } catch (e) {
    error.value = getReadableLoginError(e)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.login-page {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 40px 20px;
  background: linear-gradient(135deg, #eef5ff 0%, #ffffff 100%);
  font-family: Inter, "Segoe UI", Arial, sans-serif;
  overflow: hidden;
  position: relative;
}

.login-page::before,
.login-page::after {
  display: none !important;
  content: none !important;
}

.login-shell {
  width: min(1060px, 100%);
  min-height: 650px;
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  background: #ffffff;
  border-radius: 34px;
  overflow: hidden;
  box-shadow: 0 28px 70px rgba(15, 23, 42, 0.12);
}

.login-hero {
  position: relative;
  min-height: 650px;
  color: #ffffff;
  overflow: hidden;
  background: #062b49;
}


/* Hilangkan dekorasi circle/dot/blob lama di halaman login */
.login-hero .circle,
.login-hero .dot,
.login-hero .blob,
.login-hero .decor,
.login-hero .decoration {
  display: none !important;
}

.login-hero::before {
  content: "";
  position: absolute;
  inset: -14px;
  background: url("/assets/images/dashboard.jpeg");
  background-size: cover;
  background-position: center;
  filter: blur(5px);
  transform: scale(1.05);
  opacity: 0.92;
  z-index: 0;
}

.login-hero::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(
    145deg,
    rgba(5, 42, 78, 0.68),
    rgba(5, 42, 78, 0.42)
  );
  z-index: 0;
}

.hero-overlay,
.hero-overlay::before,
.hero-overlay::after,
.hero-content::before,
.hero-content::after {
  display: none !important;
  content: none !important;
  width: 0 !important;
  height: 0 !important;
  opacity: 0 !important;
  visibility: hidden !important;
  pointer-events: none !important;
  background: transparent !important;
  box-shadow: none !important;
  border-radius: 0 !important;
}

.hero-content {
  position: relative;
  z-index: 1;
  height: 100%;
  padding: 54px 50px;
  display: flex;
  flex-direction: column;
}

.hero-content::before,
.hero-content::after {
  display: none !important;
  content: none !important;
}

.brand-large {
  display: flex;
  align-items: center;
  gap: 16px;
}

.brand-large img {
  width: 66px;
  height: 66px;
  border-radius: 18px;
  object-fit: contain;
  background: #ffffff;
  padding: 8px;
}

.brand-large h1 {
  margin: 0;
  font-size: 34px;
  line-height: 1;
  font-weight: 900;
  letter-spacing: -1px;
}

.brand-large p {
  margin: 5px 0 0;
  font-size: 14px;
  font-weight: 700;
  color: #dbeafe;
}

.hero-title {
  margin-top: auto;
  margin-bottom: 58px;
}

.hero-title h2 {
  margin: 0;
  max-width: 520px;
  font-size: clamp(38px, 5vw, 54px);
  line-height: 1.08;
  font-weight: 900;
  letter-spacing: -2px;
  text-shadow: 0 8px 22px rgba(0, 0, 0, 0.22);
}

.hero-title h2 span {
  color: #ffd21e;
}

.hero-title p {
  width: min(470px, 100%);
  margin: 26px 0 0;
  color: #f8fafc;
  font-size: 18px;
  line-height: 1.6;
  font-weight: 700;
  text-shadow: 0 6px 16px rgba(0, 0, 0, 0.22);
}

.hero-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  gap: 12px;
}

.hero-list li {
  display: flex;
  align-items: center;
  gap: 12px;
  width: min(470px, 100%);
  padding: 14px 18px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.13);
  border: 1px solid rgba(255, 255, 255, 0.18);
  color: #eef6ff;
  font-weight: 800;
  font-size: 14px;
  backdrop-filter: blur(8px);
}

.hero-list li::before {
  content: "✓";
  width: 22px;
  height: 22px;
  flex: 0 0 22px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: #ffd21e;
  color: #062b49;
  font-size: 14px;
  font-weight: 900;
}

.login-panel {
  min-height: 650px;
  display: grid;
  place-items: center;
  padding: 44px;
  background: #ffffff;
}

.login-card {
  width: min(370px, 100%);
  padding: 36px 34px;
  border-radius: 24px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  box-shadow: 0 24px 55px rgba(15, 23, 42, 0.08);
}

.login-card h2 {
  margin: 0;
  color: #06152b;
  font-size: 30px;
  font-weight: 900;
  letter-spacing: -1px;
}

.login-card > p {
  margin: 8px 0 24px;
  color: #64748b;
  font-size: 16px;
}

.role-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 24px;
}

.role-card {
  min-height: 84px;
  border: 1px solid #dbe4f0;
  background: #ffffff;
  border-radius: 18px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 9px;
  color: #0f172a;
  font-weight: 800;
  cursor: pointer;
  transition: 0.2s ease;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
}

.role-card:hover {
  border-color: #1d5fa8;
  transform: translateY(-1px);
  box-shadow: 0 14px 28px rgba(29, 95, 168, 0.12);
}

.role-card.active {
  border-color: #1d5fa8;
  background: #f4f9ff;
  color: #0b55a0;
  box-shadow: 0 16px 32px rgba(29, 95, 168, 0.15);
}

.role-icon {
  width: 36px;
  height: 36px;
  border-radius: 14px;
  display: grid;
  place-items: center;
  color: #0b55a0;
  background: #eaf3ff;
}

.role-card.active .role-icon {
  color: #ffffff;
  background: #0b55a0;
}

.login-card label {
  display: block;
  margin: 16px 0 8px;
  color: #0f172a;
  font-size: 13px;
  font-weight: 900;
}

.login-card input {
  width: 100%;
  height: 50px;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 0 14px;
  color: #0f172a;
  font-size: 15px;
  outline: none;
  background: #ffffff;
  transition: 0.2s ease;
}

.login-card input:focus {
  border-color: #1d5fa8;
  box-shadow: 0 0 0 4px rgba(29, 95, 168, 0.12);
}

.password-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.password-wrapper input {
  width: 100%;
  padding-right: 110px;
}

.toggle-password {
  position: absolute;
  right: 14px;
  background: none;
  border: none;
  color: #0b55a0;
  font-weight: 800;
  cursor: pointer;
  font-size: 14px;
}

.toggle-password:hover {
  color: #063f7c;
}

.login-error {
  margin: 16px 0 0;
  padding: 12px 14px;
  border-radius: 13px;
  background: #fff1f2;
  border: 1px solid #fecdd3;
  color: #be123c;
  font-size: 14px;
  line-height: 1.4;
}

.login-button {
  width: 100%;
  height: 54px;
  margin-top: 26px;
  border: none;
  border-radius: 14px;
  background: #15579d;
  color: #ffffff;
  font-size: 16px;
  font-weight: 900;
  cursor: pointer;
  box-shadow: 0 16px 30px rgba(21, 87, 157, 0.22);
  transition: 0.2s ease;
}

.login-button:hover {
  background: #0f4a88;
  transform: translateY(-1px);
}

.login-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

@media (max-width: 920px) {
  .login-shell {
    grid-template-columns: 1fr;
  }

  .login-hero {
    min-height: 430px;
  }

  .login-panel {
    min-height: auto;
  }

  .hero-content {
    padding: 38px 30px;
  }
}

@media (max-width: 520px) {
  .login-page {
    padding: 18px;
  }

  .login-shell {
    border-radius: 24px;
  }

  .login-panel {
    padding: 24px 18px;
  }

  .login-card {
    padding: 28px 22px;
  }

  .role-grid {
    grid-template-columns: 1fr;
  }

  .hero-title h2 {
    font-size: 36px;
  }
}
</style>


