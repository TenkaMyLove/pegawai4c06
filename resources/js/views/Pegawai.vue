<template>
  <div class="pegawai-layout">
    <aside class="sidebar">
      <div class="brand">
        <div class="brand-logo">S</div>
        <div>
          <h2>Simpadu</h2>
          <p>Platform Akademik Digital</p>
        </div>
      </div>

      <nav class="menu">
        <RouterLink to="/pegawai/profil" class="menu-item">
          <span>👤</span>
          <b>Profil Saya</b>
        </RouterLink>

        <RouterLink to="/pegawai/presensi" class="menu-item">
          <span>🕘</span>
          <b>Presensi Kehadiran</b>
        </RouterLink>
      </nav>

      <div class="user-card">
        <div class="avatar">{{ userInitial }}</div>
        <div>
          <strong>{{ profile.nama || userName }}</strong>
          <small>{{ profile.jabatan || 'Pegawai' }}</small>
        </div>
      </div>

      <button class="logout-btn" @click="logout">
        Keluar
      </button>
    </aside>

    <main class="content">
      <header class="topbar">
        <h1>{{ title }}</h1>
      </header>

      <div v-if="message.text && message.type === 'error'" :class="['message', message.type]">
        {{ message.text }}
      </div>

      <p v-if="loading" class="loading">Memuat data...</p>

      <!-- PROFIL PEGAWAI -->
      <section v-if="page === 'profil'" class="page profile-page">
        <div class="profile-hero">
          <div class="profile-avatar">{{ userInitial }}</div>

          <div>
            <h2>{{ profile.nama || userName }}</h2>
            <p>{{ profile.jabatan || 'Staff Administrasi Fakultas Teknik' }}</p>

            <div class="profile-meta">
              <span>NIP: <b>{{ profile.nip || '-' }}</b></span>
              <span>NIK: <b>{{ profile.nik || '-' }}</b></span>
            </div>
          </div>
        </div>

        <form class="profile-card" @submit.prevent="simpanProfil">
          <h3>Data Pribadi</h3>

          <div class="form-grid">
            <label>
              <span>NIP</span>
              <input v-model="profileForm.nip" type="text" placeholder="NIP" />
            </label>

            <label>
              <span>NIK</span>
              <input v-model="profileForm.nik" type="text" placeholder="NIK" />
            </label>

            <label class="full">
              <span>Nama Lengkap</span>
              <input v-model="profileForm.nama" type="text" placeholder="Nama lengkap" />
            </label>

            <label>
              <span>Email</span>
              <input v-model="profileForm.email" type="email" placeholder="Email" />
            </label>

            <label>
              <span>No. HP / WhatsApp</span>
              <input v-model="profileForm.no_hp" type="text" placeholder="No. HP" />
            </label>

            <label class="full">
              <span>Alamat Lengkap</span>
              <textarea v-model="profileForm.alamat" placeholder="Alamat lengkap"></textarea>
            </label>

            <label>
              <span>Tempat, Tanggal Lahir</span>
              <input v-model="profileForm.ttl" type="text" placeholder="Contoh: Bandung, 12 Maret 1998" />
            </label>

            <label>
              <span>Pendidikan Terakhir</span>
              <input v-model="profileForm.pendidikan" type="text" placeholder="Pendidikan terakhir" />
            </label>
          </div>

          <div class="form-actions">
            <button type="submit" class="yellow-btn" :disabled="loading">
              {{ loading ? 'Menyimpan...' : 'Simpan Perubahan' }}
            </button>
          </div>
        </form>
      </section>

      <!-- PRESENSI PEGAWAI -->
      <section v-else class="page presensi-page">
        <div class="attendance-card">
          <p class="today-label">Hari Ini</p>
          <h2>{{ tanggalHariIni }}</h2>

          <p class="section-label">Pilih Presensi Datang / Pulang</p>

          <div class="status-grid status-grid-two">
            <button
              type="button"
              :class="['status-btn hadir', presensiForm.status === 'datang' && 'active']"
              @click="presensiForm.status = 'datang'"
            >
              <span>✅</span>
              Datang
            </button>

            <button
              type="button"
              :class="['status-btn pulang', presensiForm.status === 'pulang' && 'active']"
              @click="presensiForm.status = 'pulang'"
            >
              <span>🏁</span>
              Pulang
            </button>
          </div>

          <button
            class="save-attendance"
            :disabled="loading"
            @click="simpanPresensi"
          >
            {{ loading ? 'Menyimpan...' : presensiForm.status === 'pulang' ? 'Simpan Presensi Pulang' : 'Simpan Presensi Datang' }}
          </button>
        </div>

        <div class="history-section">
          <h3>Riwayat Presensi Bulan Ini</h3>

          <div class="history-list">
            <div
              v-for="item in riwayatPresensi"
              :key="item._key"
              class="history-item"
            >
              <div>
                <strong>{{ formatTanggal(item.tanggal || item.created_at) }}</strong>
                <small>{{ item.jam || item.jam_datang || item.created_at || '-' }}</small>
              </div>

              <span :class="['status-pill', pillClass(item.status)]">
                {{ labelStatus(item.status) }}
              </span>
            </div>

            <p v-if="riwayatPresensi.length === 0 && !loading" class="empty-text">
              Belum ada riwayat presensi.
            </p>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'
import ENDPOINTS from '../services/endpoints'

const props = defineProps({
  page: {
    type: String,
    default: 'profil',
  },
})

const router = useRouter()


const loading = ref(false)
const message = ref({ type: '', text: '' })

const user = ref(JSON.parse(localStorage.getItem('simpadu_user') || '{}'))

const profile = ref({})
const profileForm = ref({
  id: '',
  nama: '',
  nip: '',
  nik: '',
  email: '',
  no_hp: '',
  alamat: '',
  ttl: '',
  pendidikan: '',
  jabatan: '',
})

const presensiForm = ref({
  status: 'datang',
  keterangan: '',
})

const riwayatPresensi = ref([])

const title = computed(() => {
  return props.page === 'profil' ? 'Profil Saya' : 'Presensi Kehadiran Kampus'
})

const userName = computed(() => {
  return (
    user.value.NAMA_PEGAWAI ||
    user.value.nama_pegawai ||
    user.value.nama ||
    user.value.name ||
    user.value.email ||
    user.value.username ||
    'Pegawai'
  )
})

const userInitial = computed(() => {
  const name = profile.value.nama || userName.value || 'P'
  return String(name)
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((item) => item.charAt(0).toUpperCase())
    .join('')
})

const pegawaiId = computed(() => {
  return (
    profile.value.id ||
    profile.value.pegawai_id ||
    user.value.id ||
    user.value.ID ||
    user.value.pegawai_id ||
    user.value.PEGAWAI_ID ||
    user.value.NIP ||
    user.value.nip ||
    ''
  )
})

const tanggalHariIni = computed(() => {
  return new Date().toLocaleDateString('id-ID', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
})

function setMessage(type, text) {
  message.value = { type, text }

  if (text) {
    setTimeout(() => {
      message.value = { type: '', text: '' }
    }, 4500)
  }
}

async function apiRequest(path, options = {}) {
  const method = String(options.method || 'GET').toLowerCase()
  const config = {
    url: path,
    method,
    headers: options.headers || {},
  }

  if (options.params) {
    config.params = options.params
  }

  if (options.body !== undefined) {
    try {
      config.data = typeof options.body === 'string'
        ? JSON.parse(options.body)
        : options.body
    } catch {
      config.data = options.body
    }
  }

  const response = await api(config)
  return response.data
}

function ambilArray(data) {
  if (Array.isArray(data)) return data
  if (Array.isArray(data?.data)) return data.data
  if (Array.isArray(data?.pegawai)) return data.pegawai
  if (Array.isArray(data?.absensi)) return data.absensi
  if (Array.isArray(data?.rekap)) return data.rekap
  if (Array.isArray(data?.riwayat)) return data.riwayat
  return []
}

function normalizeProfile(item = {}) {
  return {
    id:
      item.id ||
      item.ID ||
      item.pegawai_id ||
      item.PEGAWAI_ID ||
      item.id_pegawai ||
      item.ID_PEGAWAI ||
      user.value.id ||
      '',
    nama:
      item.nama ||
      item.nama_pegawai ||
      item.NAMA_PEGAWAI ||
      item.name ||
      userName.value,
    nip:
      item.nip ||
      item.NIP ||
      user.value.nip ||
      user.value.NIP ||
      '',
    nik:
      item.nik ||
      item.NIK ||
      '',
    email:
      item.email ||
      item.EMAIL ||
      user.value.email ||
      '',
    no_hp:
      item.no_hp ||
      item.hp ||
      item.telepon ||
      item.no_telp ||
      '',
    alamat:
      item.alamat ||
      item.ALAMAT ||
      '',
    ttl:
      item.ttl ||
      item.tempat_tanggal_lahir ||
      item.tanggal_lahir ||
      '',
    pendidikan:
      item.pendidikan ||
      item.pendidikan_terakhir ||
      '',
    jabatan:
      item.jabatan ||
      item.role ||
      item.posisi ||
      'Pegawai',
  }
}

function normalizePresensi(item = {}, index = 0) {
  return {
    ...item,
    _key:
      item._key ||
      item.id ||
      `${item.tanggal || item.created_at || 'presensi'}-${index}`,
    tanggal:
      item.tanggal ||
      item.created_at ||
      new Date().toLocaleDateString('id-ID'),
    status:
      item.status ||
      item.keterangan_status ||
      '',
    jam:
      item.jam ||
      item.jam_datang ||
      item.created_at ||
      '',
  }
}

function simpanProfilKeForm(data) {
  profile.value = normalizeProfile(data)
  profileForm.value = { ...profile.value }
  localStorage.setItem('simpadu_pegawai_profile', JSON.stringify(profile.value))
}

function ambilProfilLokal() {
  try {
    const localProfile = JSON.parse(localStorage.getItem('simpadu_pegawai_profile') || '{}')
    return normalizeProfile({ ...user.value, ...localProfile })
  } catch {
    return normalizeProfile(user.value)
  }
}

async function ambilProfilPegawai() {
  loading.value = true

  try {
    let data = null

    try {
      data = await apiRequest(ENDPOINTS.pegawai.profile)
    } catch {
      if (pegawaiId.value) {
        data = await apiRequest(ENDPOINTS.pegawai.byId(pegawaiId.value))
      } else {
        data = await apiRequest(ENDPOINTS.pegawai.all)
      }
    }

    const arrayData = ambilArray(data)

    if (arrayData.length) {
      const found =
        arrayData.find((item) => {
          return (
            String(item.id || item.pegawai_id || item.NIP || item.nip) === String(pegawaiId.value) ||
            String(item.email || '').toLowerCase() === String(user.value.email || '').toLowerCase()
          )
        }) || arrayData[0]

      simpanProfilKeForm(found)
    } else {
      simpanProfilKeForm(data?.data || data || user.value)
    }
  } catch (e) {

    simpanProfilKeForm(ambilProfilLokal())
    setMessage('info', 'Profil dari API belum bisa diambil. Menampilkan data lokal sementara.')
  } finally {
    loading.value = false
  }
}

async function simpanProfil() {
  loading.value = true

  const payload = { ...profileForm.value }

  try {
    // Sesuai Postman: update profil akun login memakai PUT /api/pegawai/profile.
    // Field lain tetap disimpan lokal agar UI dan fitur yang sudah jalan tidak berubah.
    const apiPayload = {
      alamat: payload.alamat || '',
      jenis_kelamin: user.value.jenis_kelamin || user.value.JENIS_KELAMIN || 'L',
    }

    const result = await apiRequest(ENDPOINTS.pegawai.updateProfile, {
      method: 'PUT',
      body: JSON.stringify(apiPayload),
    })

    simpanProfilKeForm({
      ...payload,
      ...(result?.data || result || {}),
    })
    setMessage('success', 'Profil berhasil disimpan.')
  } catch (e) {
    simpanProfilKeForm(payload)
    setMessage('info', 'Profil disimpan sementara di browser karena API update profil belum tersedia.')
  } finally {
    loading.value = false
  }
}

function getRiwayatLocalKey() {
  return `simpadu_riwayat_presensi_pegawai_${pegawaiId.value || 'local'}`
}

function ambilRiwayatLokal() {
  try {
    const data = JSON.parse(localStorage.getItem(getRiwayatLocalKey()) || '[]')
    return Array.isArray(data) ? data.map(normalizePresensi) : []
  } catch {
    return []
  }
}

function simpanRiwayatLokal(list) {
  localStorage.setItem(
    getRiwayatLocalKey(),
    JSON.stringify(list.map(normalizePresensi))
  )
}

async function ambilRiwayatPresensi() {
  loading.value = true

  try {
    let data = null

    try {
      data = await apiRequest(ENDPOINTS.absensi.pegawaiRekap)
    } catch {
      data = await apiRequest(ENDPOINTS.absensi.pegawaiRekap)
    }

    const apiData = ambilArray(data)
      .map(normalizePresensi)
      .filter((item) => {
        if (!pegawaiId.value) return true

        const id =
          item.pegawai_id ||
          item.id_pegawai ||
          item.user_id ||
          item.nip ||
          item.NIP ||
          ''

        if (!id) return true

        return String(id) === String(pegawaiId.value)
      })

    const localData = ambilRiwayatLokal()
    riwayatPresensi.value = gabungRiwayat(apiData, localData)
  } catch (e) {

    riwayatPresensi.value = ambilRiwayatLokal()
  } finally {
    loading.value = false
  }
}

function gabungRiwayat(apiList, localList) {
  const map = new Map()

  ;[...localList, ...apiList].forEach((item, index) => {
    const presensi = normalizePresensi(item, index)
    map.set(String(presensi._key), presensi)
  })

  return Array.from(map.values())
}

async function simpanPresensi() {
  if (!presensiForm.value.status) {
    setMessage('error', 'Pilih presensi datang atau pulang terlebih dahulu.')
    return
  }

  loading.value = true

  const isPulang = presensiForm.value.status === 'pulang'
  const now = new Date()
  const waktu = now.toLocaleTimeString('id-ID', {
    hour: '2-digit',
    minute: '2-digit',
  })

  const payload = {
    pegawai_id: pegawaiId.value,
    id_pegawai: pegawaiId.value,
    nip: profile.value.nip || user.value.nip || user.value.NIP || '',
    nama: profile.value.nama || userName.value,
    status: isPulang ? 'pulang' : 'hadir',
    tanggal: now.toISOString().slice(0, 10),
    jam_datang: isPulang ? '' : waktu,
    jam_pulang: isPulang ? waktu : '',
  }

  const endpoint = isPulang
    ? ENDPOINTS.absensi.pegawaiKeluar
    : ENDPOINTS.absensi.pegawaiMasuk

  try {
    let response = null

    try {
      // Sesuai Postman: POST /api/pegawai/absensi/masuk dan /keluar tidak memerlukan body.
      // Backend mengambil pegawai dari Bearer token.
      response = await apiRequest(endpoint, { method: 'POST' })
    } catch {
      // Fallback untuk backend yang masih menerima payload lama.
      response = await apiRequest(endpoint, {
        method: 'POST',
        body: JSON.stringify(payload),
      })
    }

    const presensiBaru = normalizePresensi({
      _key: `pegawai-${presensiForm.value.status}-${Date.now()}`,
      ...payload,
      ...(response?.data || {}),
      created_at: now.toLocaleString('id-ID'),
    })

    riwayatPresensi.value.unshift(presensiBaru)
    simpanRiwayatLokal(riwayatPresensi.value)

    setMessage('success', response?.message || response?.data?.message || `${isPulang ? 'Presensi pulang' : 'Presensi datang'} berhasil disimpan.`)
  } catch (e) {
    const presensiBaru = normalizePresensi({
      _key: `pegawai-local-${presensiForm.value.status}-${Date.now()}`,
      ...payload,
      created_at: now.toLocaleString('id-ID'),
    })

    riwayatPresensi.value.unshift(presensiBaru)
    simpanRiwayatLokal(riwayatPresensi.value)

    setMessage('info', 'API presensi belum bisa diakses. Presensi disimpan sementara di browser untuk demo.')
  } finally {
    loading.value = false
  }
}

function normalizeStatus(status) {
  return String(status || '').toLowerCase().trim()
}

function labelStatus(status) {
  const clean = normalizeStatus(status)

  if (clean === 'hadir' || clean === 'datang') return 'Datang'
  if (clean === 'pulang' || clean === 'keluar') return 'Pulang'
  if (clean === 'izin') return 'Izin'
  if (clean === 'sakit') return 'Sakit'
  if (clean === 'cuti') return 'Cuti'
  if (clean === 'tidak_hadir' || clean === 'tidak hadir') return 'Tidak Hadir'

  return status || '-'
}

function pillClass(status) {
  const clean = normalizeStatus(status)

  if (clean === 'hadir' || clean === 'datang' || clean === 'pulang' || clean === 'keluar') return 'ok'
  if (clean === 'izin') return 'info'
  if (clean === 'sakit') return 'danger'
  if (clean === 'cuti') return 'warn'

  return 'danger'
}

function formatTanggal(value) {
  if (!value) return '-'

  const date = new Date(value)

  if (Number.isNaN(date.getTime())) return value

  return date.toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
}

async function loadData() {
  await ambilProfilPegawai()

  if (props.page === 'presensi') {
    await ambilRiwayatPresensi()
  }
}

function logout() {
  localStorage.removeItem('simpadu_token')
  localStorage.removeItem('simpadu_user')
  localStorage.removeItem('simpadu_role')
  localStorage.removeItem('simpadu_logged_in')
  router.push('/')
}

onMounted(loadData)

watch(
  () => props.page,
  () => {
    loadData()
  }
)
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.pegawai-layout {
  min-height: 100vh;
  display: flex;
  background: #f5f6f8;
  color: #111827;
  font-family: Inter, "Segoe UI", Arial, sans-serif;
}

/* SIDEBAR */
.sidebar {
  width: 246px;
  min-height: 100vh;
  background: #062b49;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  padding: 24px 16px 20px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-bottom: 28px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.12);
}

.brand-logo {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: #ffd21e;
  color: #062b49;
  display: grid;
  place-items: center;
  font-weight: 900;
  font-size: 18px;
}

.brand h2 {
  margin: 0;
  font-size: 22px;
  line-height: 1;
  font-weight: 900;
}

.brand p {
  margin: 3px 0 0;
  color: #cbd5e1;
  font-size: 10px;
}

.menu {
  margin-top: 26px;
  display: grid;
  gap: 10px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 13px 16px;
  border-radius: 999px;
  color: #ffffff;
  text-decoration: none;
  font-size: 14px;
}

.menu-item b {
  font-weight: 800;
}

.menu-item:hover,
.menu-item.router-link-active,
.menu-item.router-link-exact-active {
  background: #ffd21e;
  color: #06152b;
}

.user-card {
  margin-top: auto;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 12px;
  border-radius: 22px;
  background: rgba(15, 41, 88, 0.72);
}

.avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: #ffd21e;
  color: #062b49;
  display: grid;
  place-items: center;
  font-weight: 900;
}

.user-card strong {
  display: block;
  font-size: 13px;
}

.user-card small {
  display: block;
  margin-top: 3px;
  color: #cbd5e1;
  font-size: 11px;
}

.logout-btn {
  margin-top: 14px;
  border: none;
  background: transparent;
  color: #fecaca;
  font-weight: 700;
  cursor: pointer;
}

/* MAIN */
.content {
  flex: 1;
  min-width: 0;
}

.topbar {
  height: 56px;
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  align-items: center;
  padding: 0 28px;
}

.topbar h1 {
  margin: 0;
  color: #1f2937;
  font-size: 20px;
  font-weight: 900;
}

.page {
  padding: 28px;
}

.loading {
  margin: 14px 28px 0;
  color: #64748b;
  font-weight: 700;
}

.message {
  margin: 18px 28px 0;
  padding: 12px 14px;
  border-radius: 14px;
  font-size: 14px;
  font-weight: 700;
}

.message.success {
  background: #dcfce7;
  color: #166534;
}

.message.error {
  background: #fee2e2;
  color: #991b1b;
}

.message.info {
  background: #dbeafe;
  color: #1e40af;
}

/* PROFIL */
.profile-page {
  max-width: 760px;
  margin: 0 auto;
}

.profile-hero {
  background: #ffffff;
  border-radius: 22px;
  padding: 28px;
  display: flex;
  align-items: center;
  gap: 22px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.04);
}

.profile-avatar {
  width: 90px;
  height: 90px;
  border-radius: 20px;
  background: linear-gradient(135deg, #6366f1, #2563eb);
  color: #ffffff;
  display: grid;
  place-items: center;
  font-size: 42px;
  font-weight: 900;
}

.profile-hero h2 {
  margin: 0;
  font-size: 28px;
  font-weight: 900;
}

.profile-hero p {
  margin: 6px 0 12px;
  color: #475569;
}

.profile-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  color: #475569;
  font-size: 13px;
}

.profile-card {
  margin-top: 26px;
  background: #ffffff;
  border-radius: 22px;
  padding: 28px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.04);
}

.profile-card h3 {
  margin: 0 0 22px;
  font-size: 17px;
  font-weight: 900;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
}

.form-grid label {
  display: grid;
  gap: 8px;
}

.form-grid label.full {
  grid-column: 1 / -1;
}

.form-grid span {
  color: #64748b;
  font-size: 12px;
}

.form-grid input,
.form-grid textarea {
  width: 100%;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 12px 14px;
  font-size: 14px;
  outline: none;
  background: #ffffff;
}

.form-grid textarea {
  min-height: 86px;
  resize: none;
}

.form-actions {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

.yellow-btn {
  border: none;
  background: #ffd21e;
  color: #06152b;
  padding: 13px 24px;
  border-radius: 14px;
  font-weight: 900;
  cursor: pointer;
}

.yellow-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* PRESENSI */
.presensi-page {
  max-width: 720px;
  margin: 0 auto;
}

.attendance-card {
  width: min(460px, 100%);
  margin: 0 auto;
  background: #ffffff;
  border-radius: 20px;
  padding: 34px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.04);
  text-align: center;
}

.today-label {
  margin: 0;
  color: #94a3b8;
  font-size: 13px;
}

.attendance-card h2 {
  margin: 5px 0 28px;
  font-size: 30px;
  font-weight: 900;
}

.section-label {
  margin: 0 0 14px;
  color: #64748b;
  font-size: 13px;
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
}

.status-grid-two {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.status-btn {
  min-height: 86px;
  border: 2px solid transparent;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 7px;
  font-size: 12px;
  color: #334155;
  cursor: pointer;
}

.status-btn span {
  font-size: 22px;
}

.status-btn.hadir {
  background: #dcfce7;
}

.status-btn.pulang {
  background: #dbeafe;
}

.status-btn.sakit {
  background: #fee2e2;
}

.status-btn.cuti {
  background: #fef3c7;
}

.status-btn.izin {
  background: #dbeafe;
}

.status-btn.tidak {
  background: #f1f5f9;
}

.status-btn.active {
  border-color: #facc15;
  box-shadow: 0 0 0 3px rgba(250, 204, 21, 0.18);
}

.attendance-card textarea {
  width: 100%;
  min-height: 84px;
  margin-top: 24px;
  resize: none;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 14px;
  outline: none;
}

.save-attendance {
  width: 100%;
  height: 54px;
  margin-top: 22px;
  border: none;
  border-radius: 16px;
  background: #059669;
  color: #ffffff;
  font-weight: 900;
  cursor: pointer;
}

.save-attendance:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.history-section {
  width: min(560px, 100%);
  margin: 36px auto 0;
}

.history-section h3 {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 900;
}

.history-list {
  display: grid;
  gap: 12px;
}

.history-item {
  background: #ffffff;
  border-radius: 14px;
  padding: 14px 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.history-item strong {
  display: block;
  font-size: 14px;
  font-weight: 700;
}

.history-item small {
  color: #94a3b8;
  font-size: 12px;
}

.status-pill {
  border-radius: 999px;
  padding: 7px 14px;
  font-size: 12px;
  font-weight: 800;
}

.status-pill.ok {
  background: #bbf7d0;
  color: #059669;
}

.status-pill.info {
  background: #dbeafe;
  color: #2563eb;
}

.status-pill.warn {
  background: #fef3c7;
  color: #d97706;
}

.status-pill.danger {
  background: #fee2e2;
  color: #dc2626;
}

.empty-text {
  text-align: center;
  color: #94a3b8;
  background: #ffffff;
  border-radius: 14px;
  padding: 18px;
}

@media (max-width: 860px) {
  .pegawai-layout {
    flex-direction: column;
  }

  .sidebar {
    width: 100%;
    min-height: auto;
  }

  .form-grid,
  .status-grid {
    grid-template-columns: 1fr;
  }

  .profile-hero {
    flex-direction: column;
    text-align: center;
  }

  .profile-meta {
    justify-content: center;
  }
}
</style>
