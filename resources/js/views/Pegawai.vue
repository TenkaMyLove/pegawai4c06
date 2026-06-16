<template>
  <div class="shell">
    <!-- Sidebar (style mengikuti Admin/Dosen) -->
    <aside class="sidebar">
      <!-- Brand / Poliban: selalu kembali ke Home -->
      <RouterLink :to="HOME_ROUTE" class="brand" aria-label="Simpadu Pegawai" @click.prevent="goHome">
        <img class="brand-logo" :src="logoPolibanUrl" alt="Poliban" />
        <div class="brand-text">
          <div class="brand-title">Simpadu</div>
          <div class="brand-sub">Pegawai Digital</div>
        </div>
      </RouterLink>

      <!-- Hanya 1 menu -->
      <nav class="nav">
        <RouterLink :to="HOME_ROUTE" class="nav-item" active-class="active" @click.prevent="goHome">
          <span class="nav-ic">▦</span>
          Dashboard
        </RouterLink>
      </nav>

      <!-- Profil bawah kiri -->
      <div class="sidebar-bottom">
        <button class="profile-pill" type="button" @click="view = 'profil'" aria-label="Profil">
          <div class="avatar">{{ userInitial }}</div>
          <div class="profile-meta">
            <div class="profile-name">{{ profile.nama || userName }}</div>
            <div class="profile-role">Pegawai</div>
          </div>
        </button>

        <button class="logout-btn" type="button" @click="logout">
          Keluar
        </button>
      </div>
    </aside>

    <!-- Main -->
    <main class="main">
      <!-- Header bar (mirip Admin) -->
      <div class="page-header">
        <div class="page-title">
          <h1>{{ view === 'home' ? 'Dashboard Pegawai' : 'Profil Pegawai' }}</h1>
          <p v-if="view === 'home'">Presensi datang dan pulang</p>
          <p v-else>Data profil pegawai</p>
        </div>

        <button
          v-if="view === 'home'"
          class="btn-refresh"
          type="button"
          @click="refreshData"
          :disabled="loading"
        >
          Refresh Data
        </button>

        <button v-else class="btn-refresh" type="button" @click="goHome">Kembali</button>
      </div>

      <!-- HOME: Presensi -->
      <template v-if="view === 'home'">
        <section class="welcome">
          <div class="welcome-top">DASHBOARD PEGAWAI</div>
          <div class="welcome-title">Selamat datang, {{ profile.nama || userName }}</div>
        </section>

        <section class="grid">
          <!-- Presensi Harian -->
          <div class="card presensi-card">
            <h2>Presensi Harian</h2>

            <div class="mini-grid">
              <div class="mini-box">
                <div class="mini-label">TANGGAL</div>
                <div class="mini-value">{{ tanggalPendek }}</div>
              </div>
              <div class="mini-box">
                <div class="mini-label">NAMA</div>
                <div class="mini-value">{{ (profile.nama || userName).split(' ')[0] }}</div>
              </div>
            </div>

            <div class="mode">
              <button
                class="mode-btn"
                :class="{ active: modePresensi === 'datang' }"
                type="button"
                @click="modePresensi = 'datang'"
                :disabled="loading || presensiHariIni.lengkap"
              >
                Datang
              </button>
              <button
                class="mode-btn"
                :class="{ active: modePresensi === 'pulang' }"
                type="button"
                @click="modePresensi = 'pulang'"
                :disabled="loading || presensiHariIni.lengkap || !presensiHariIni.jam_datang"
              >
                Pulang
              </button>
            </div>

            <div class="jam-box">
              <div class="jam-row">
                <span>Jam Datang</span>
                <strong>{{ presensiHariIni.jam_datang || '-' }}</strong>
              </div>
              <div class="jam-row">
                <span>Jam Pulang</span>
                <strong>{{ presensiHariIni.jam_pulang || '-' }}</strong>
              </div>
            </div>

            <button
              class="btn-presensi"
              type="button"
              @click="catatPresensi"
              :disabled="loading || presensiHariIni.lengkap || (modePresensi === 'pulang' && !presensiHariIni.jam_datang)"
            >
              <span v-if="loading">Memuat...</span>
              <span v-else>{{ tombolText }}</span>
            </button>

            <div class="hint">Presensi hanya bisa dilakukan pada hari kerja</div>
          </div>

          <!-- Riwayat (dipendekkan) -->
          <div class="card riwayat-card">
            <div class="riwayat-head">
              <h2>Riwayat Presensi</h2>
            </div>

            <div class="riwayat-list">
              <div v-for="item in riwayatRingkas" :key="item.tanggal" class="riwayat-item">
                <div class="riwayat-left">
                  <div class="riwayat-date">{{ item.tanggal }}</div>
                  <div class="riwayat-time riwayat-time-short">
                    <span>Datang <strong>{{ item.jam_datang || '-' }}</strong></span>
                    <span class="dot">•</span>
                    <span>Pulang <strong>{{ item.jam_pulang || '-' }}</strong></span>
                  </div>
                </div>
                <div class="riwayat-badge" :class="item.lengkap ? 'ok' : 'no'">
                  {{ item.lengkap ? 'Lengkap' : '-' }}
                </div>
              </div>

              <div v-if="!riwayatRingkas.length" class="riwayat-empty">Belum ada riwayat.</div>
            </div>
          </div>
        </section>
      </template>

      <!-- PROFIL: Full page (tanpa popup) -->
      <template v-else>
        <section class="profile-page">
          <div class="card profile-hero">
            <div class="profile-avatar-lg">{{ userInitial }}</div>
            <div class="profile-hero-meta">
              <div class="profile-hero-top">PROFIL PEGAWAI</div>
              <div class="profile-hero-name">{{ profile.nama || userName }}</div>
              <div class="profile-hero-email">{{ profileEmail || '-' }}</div>
            </div>
          </div>

          <div class="card profile-detail">
            <h2>Data Pegawai</h2>

            <div class="form-grid">
              <div class="field">
                <label>Nama Lengkap</label>
                <input type="text" :value="profile.nama || userName" readonly />
              </div>
              <div class="field">
                <label>Email</label>
                <input type="text" :value="profileEmail" readonly />
              </div>

              <div class="field">
                <label>NIP / Username</label>
                <input type="text" :value="profile.nip || '-'" readonly />
              </div>
              <div class="field">
                <label>NIK</label>
                <input type="text" :value="profile.nik || '-'" readonly />
              </div>

              <div class="field">
                <label>Jenis Kelamin</label>
                <input type="text" :value="profile.jenis_kelamin === 'L' ? 'Laki-laki' : profile.jenis_kelamin === 'P' ? 'Perempuan' : (profile.jenis_kelamin || '-')" readonly />
              </div>

              <div class="field">
                <label>Jabatan</label>
                <input type="text" :value="jabatanText || '-'" readonly />
              </div>

              <div class="field full">
                <label>Alamat</label>
                <textarea :value="profile.alamat || '-'" rows="3" readonly />
              </div>
            </div>

            <div class="form-actions">
              <button class="btn-secondary" type="button" @click="goHome">Kembali</button>
            </div>
          </div>
        </section>
      </template>

      <!-- Toast pesan (minimal) -->
      <div v-if="message.text" class="toast" :class="message.type">
        {{ message.text }}
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'
import ENDPOINTS from '../services/endpoints'

const router = useRouter()

// route home pegawai (1 halaman)
const HOME_ROUTE = '/pegawai/presensi'

// logo dari folder public (runtime path, tidak di-transform Vite)
const logoPolibanUrl = '/assets/images/logo-poliban.png'

const loading = ref(false)
const message = ref({ type: '', text: '' })
const view = ref('home')

const user = ref(JSON.parse(localStorage.getItem('simpadu_user') || '{}'))
const profile = ref({})
const riwayatPresensi = ref([])

// realtime clock
const now = ref(new Date())
let t = null

const tanggalPendek = computed(() =>
  now.value.toLocaleDateString('id-ID', { day: 'numeric', month: 'numeric', year: 'numeric' })
)

const isWeekday = computed(() => {
  const day = now.value.getDay()
  return day !== 0 && day !== 6
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
    .slice(0, 1)
    .map((item) => item.charAt(0).toUpperCase())
    .join('')
})

const profileEmail = computed(() => {
  return String(profile.value.email || '').trim()
})

const jabatanText = computed(() => {
  return String(profile.value.jabatan || '').trim()
})

const pegawaiId = computed(() => {
  return (
    profile.value.id ||
    profile.value.pegawai_id ||
    user.value.id ||
    user.value.ID_PEGAWAI ||
    user.value.pegawai_id ||
    user.value.nip ||
    user.value.NIP ||
    ''
  )
})

function goHome() {
  view.value = 'home'
}

function setMessage(type, text) {
  message.value = { type, text }
  if (!text) return
  window.clearTimeout(setMessage._t)
  setMessage._t = window.setTimeout(() => {
    message.value = { type: '', text: '' }
  }, 2000)
}

function ambilArray(payload) {
  const d = payload?.data ?? payload
  if (Array.isArray(d)) return d
  if (Array.isArray(d?.data)) return d.data
  if (Array.isArray(d?.result)) return d.result
  if (Array.isArray(d?.items)) return d.items
  return []
}

function toText(v) {
  if (v === null || v === undefined) return ''
  if (typeof v === 'string' || typeof v === 'number' || typeof v === 'boolean') return String(v)
  // jika object, coba ambil key yang umum dipakai
  if (typeof v === 'object') {
    // array -> ambil elemen pertama yang valid
    if (Array.isArray(v)) {
      for (const item of v) {
        const t = toText(item)
        if (t) return t
      }
      return ''
    }
    const keys = ['nama_jabatan', 'nama', 'jabatan', 'name', 'title', 'label', 'role']
    for (const k of keys) {
      if (v && v[k] !== undefined) {
        const t = toText(v[k])
        if (t) return t
      }
    }
    return ''
  }
  return ''
}

function normalizeProfile(p) {
  const obj = p?.data ?? p ?? {}
  return {
    id: toText(obj.id) || toText(obj.pegawai_id) || toText(obj.ID_PEGAWAI) || '',
    nama: toText(obj.nama) || toText(obj.nama_pegawai) || toText(obj.NAMA_PEGAWAI) || toText(obj.name) || '',
    nip: toText(obj.nip) || toText(obj.NIP) || toText(obj.username) || toText(obj.id) || '',
    nik: toText(obj.nik) || toText(obj.NIK) || '',
    email: toText(obj.email) || toText(obj.EMAIL) || toText(obj.email_pegawai) || toText(obj.EMAIL_PEGAWAI) || '',
    alamat: toText(obj.alamat) || toText(obj.ALAMAT) || '',
    // jabatan kadang berupa object (mis: {nama_jabatan: '...'}), maka wajib dinormalisasi ke string
    jabatan: toText(obj.jabatan) || toText(obj.JABATAN) || toText(obj.nama_jabatan) || toText(obj.NAMA_JABATAN) || '',
  }
}


// Convert an ISO/UTC timestamp string to local WIB time displayed as HH:MM:SS.
// If the value looks like a plain time (HH:MM or HH:MM:SS) it is returned as-is.
function formatJam(raw) {
  if (!raw) return ''
  const s = String(raw).trim()
  // Already a plain time (e.g. "09:15:57" from old records)
  if (/^\d{1,2}:\d{2}(:\d{2})?$/.test(s)) return s
  // ISO timestamp – parse and convert to local time
  const d = new Date(s)
  if (isNaN(d.getTime())) return s // not a valid date – return raw
  return d.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false })
}

function normalizePresensi(p) {
  const obj = p?.data ?? p ?? {}
  // Support both camelCase and UPPERCASE field names returned by the presensi API
  const tanggal =
    obj.TANGGAL ?? obj.tanggal ?? obj.date ??
    (obj.WAKTU_MASUK ? String(obj.WAKTU_MASUK).slice(0, 10) : '') ??
    obj.created_at ?? obj.waktu ?? obj.tgl ?? ''
  const rawMasuk =
    obj.WAKTU_MASUK ?? obj.jam_datang ?? obj.waktu_datang ??
    obj.waktu_masuk ?? obj.masuk ?? obj.check_in ?? ''
  const rawKeluar =
    obj.WAKTU_KELUAR ?? obj.jam_pulang ?? obj.waktu_pulang ??
    obj.waktu_keluar ?? obj.pulang ?? obj.check_out ?? ''
  const jam_datang = formatJam(rawMasuk)
  const jam_pulang = formatJam(rawKeluar)
  return {
    _key: obj.ID_PRESENSI ?? obj.id ?? obj._key ?? `${tanggal}-${rawMasuk}-${rawKeluar}-${Math.random()}`,
    tanggal,
    jam_datang,
    jam_pulang,
    status: obj.STATUS_PRESENSI ?? obj.status ?? '',
    pegawai_id: obj.ID_PEGAWAI ?? obj.pegawai_id ?? obj.id_pegawai ?? obj.user_id ?? obj.nip ?? obj.NIP ?? '',
    email: obj.email ?? '',
  }
}

function ambilRiwayatLokal() {
  try {
    return JSON.parse(localStorage.getItem('simpadu_pegawai_riwayat') || '[]')
  } catch {
    return []
  }
}

function simpanRiwayatLokal(list) {
  try {
    localStorage.setItem('simpadu_pegawai_riwayat', JSON.stringify(list || []))
  } catch {}
}

function gabungRiwayat(apiData, localData) {
  const map = new Map()
  ;[...(apiData || []), ...(localData || [])].forEach((raw) => {
    const it = normalizePresensi(raw)
    map.set(String(it._key), it)
  })
  return Array.from(map.values()).sort((a, b) => String(b.tanggal).localeCompare(String(a.tanggal)))
}

async function apiRequest(url, options = {}) {
  const method = options.method || 'GET'
  const config = { method, url, data: options.body ? JSON.parse(options.body) : undefined }
  const res = await api(config)
  return res?.data ?? res
}

async function ambilProfilPegawai() {
  loading.value = true
  try {
    let data = null
    try {
      data = await apiRequest(ENDPOINTS.pegawai.profile)
    } catch {
      if (pegawaiId.value) data = await apiRequest(ENDPOINTS.pegawai.byId(pegawaiId.value))
      else data = await apiRequest(ENDPOINTS.pegawai.all)
    }

    const arrayData = ambilArray(data)
    const userEmail = String(user.value.email || '').toLowerCase()
    const targetId = String(pegawaiId.value || '')

    if (arrayData.length) {
      const found = arrayData.find((item) => {
        const id = String(item.id || item.pegawai_id || item.ID_PEGAWAI || item.NIP || item.nip || '')
        const email = String(item.email || '').toLowerCase()
        return (targetId && id && id === targetId) || (userEmail && email === userEmail)
      })

      profile.value = found ? normalizeProfile(found) : normalizeProfile({ ...user.value })
    } else {
      profile.value = normalizeProfile(data?.data || data || user.value)
    }

    // Sinkronkan data user lokal agar tidak "ketempelan" user sebelumnya.
    // (mis: nama dari user A, tapi email masih user B)
    try {
      if (profile.value.id) {
        user.value.id = profile.value.id
        user.value.ID_PEGAWAI = profile.value.id
        user.value.pegawai_id = profile.value.id
      }
      if (profile.value.nip) {
        user.value.nip = profile.value.nip
        user.value.NIP = profile.value.nip
      }
      if (profile.value.nama) {
        user.value.nama = profile.value.nama
        user.value.name = profile.value.nama
        user.value.nama_pegawai = profile.value.nama
        user.value.NAMA_PEGAWAI = profile.value.nama
      }
      if (profile.value.email) {
        user.value.email = profile.value.email
      }
      if (profile.value.jabatan) {
        user.value.jabatan = profile.value.jabatan
        user.value.JABATAN = profile.value.jabatan
      }
      localStorage.setItem('simpadu_user', JSON.stringify(user.value))
    } catch {}

    localStorage.setItem('simpadu_pegawai_profile', JSON.stringify(profile.value))
  } catch {
    try {
      const localProfile = JSON.parse(localStorage.getItem('simpadu_pegawai_profile') || '{}')
      profile.value = normalizeProfile({ ...user.value, ...localProfile })
    } catch {
      profile.value = normalizeProfile(user.value)
    }
  } finally {
    loading.value = false
  }
}

async function ambilRiwayatPresensi() {
  loading.value = true
  try {
    const data = await apiRequest(ENDPOINTS.absensi.pegawaiRekap)
    const apiData = ambilArray(data).map(normalizePresensi)

    const idTarget = String(pegawaiId.value || '')
    const emailTarget = String(profile.value.email || user.value.email || '').toLowerCase()

    const filtered = apiData.filter((item) => {
      const id = String(item.pegawai_id || item.id_pegawai || item.user_id || item.nip || item.NIP || '')
      const email = String(item.email || '').toLowerCase()

      if (idTarget && id) return id === idTarget
      if (emailTarget && email) return email === emailTarget
      return false
    })

    const localData = ambilRiwayatLokal()
    riwayatPresensi.value = gabungRiwayat(filtered, localData)
    simpanRiwayatLokal(riwayatPresensi.value)
  } catch {
    riwayatPresensi.value = ambilRiwayatLokal()
  } finally {
    loading.value = false
  }
}

const presensiHariIni = computed(() => {
  const today = new Date().toISOString().slice(0, 10)
  const items = riwayatPresensi.value
    .filter((x) => String(x.tanggal || '').slice(0, 10) === today)
    .map((x) => normalizePresensi(x))

  let jam_datang = ''
  let jam_pulang = ''
  items.forEach((it) => {
    if (it.jam_datang) jam_datang = it.jam_datang
    if (it.jam_pulang) jam_pulang = it.jam_pulang
  })

  return { jam_datang, jam_pulang, lengkap: Boolean(jam_datang && jam_pulang) }
})

const modePresensi = ref('datang')
watch(
  () => presensiHariIni.value,
  (v) => {
    if (!v.jam_datang) modePresensi.value = 'datang'
    else if (v.jam_datang && !v.jam_pulang) modePresensi.value = 'pulang'
  },
  { immediate: true, deep: true }
)

const tombolText = computed(() => {
  if (presensiHariIni.value.lengkap) return 'Presensi Lengkap'
  return modePresensi.value === 'pulang' ? 'Selesai Aktivitas (Pulang)' : 'Catat Kehadiran (Masuk)'
})

const riwayatPerHari = computed(() => {
  const map = new Map()
  riwayatPresensi.value.forEach((raw) => {
    const it = normalizePresensi(raw)
    const tanggal = String(it.tanggal || '').slice(0, 10)
    if (!tanggal) return
    const existing = map.get(tanggal) || { tanggal, jam_datang: '', jam_pulang: '' }
    if (it.jam_datang) existing.jam_datang = it.jam_datang
    if (it.jam_pulang) existing.jam_pulang = it.jam_pulang
    map.set(tanggal, existing)
  })

  return Array.from(map.values())
    .sort((a, b) => String(b.tanggal).localeCompare(String(a.tanggal)))
    .map((it) => ({ ...it, lengkap: Boolean(it.jam_datang && it.jam_pulang) }))
})

// dipendekkan
const riwayatRingkas = computed(() => riwayatPerHari.value.slice(0, 3))

// Backup endpoints (akufarish) digunakan jika primary (rifkiaja) gagal
const BACKUP_MASUK  = 'https://api-pegawai-4c.akufarish.my.id:9001/pegawai/absensi/masuk'
const BACKUP_KELUAR = 'https://api-pegawai-4c.akufarish.my.id:9001/pegawai/absensi/keluar'

async function catatPresensi() {
  if (presensiHariIni.value.lengkap) return

  loading.value = true
  const isPulang   = modePresensi.value === 'pulang'
  const primary    = isPulang ? ENDPOINTS.absensi.pegawaiKeluar : ENDPOINTS.absensi.pegawaiMasuk
  const backup     = isPulang ? BACKUP_KELUAR : BACKUP_MASUK

  // Dapatkan token lokal dari localStorage untuk authentikasi fallback
  const localToken = localStorage.getItem('simpadu_token')
  const headers = {}
  if (localToken) {
    headers['Authorization'] = `Bearer ${localToken}`
  }

  try {
    try {
      await api.post(primary, {}, { headers })
    } catch (primaryErr) {
      // Primary failed – try backup silently
      console.warn('[presensi] primary endpoint failed, trying backup…', primaryErr?.message)
      await api.post(backup, {}, { headers })
    }

    await ambilRiwayatPresensi()
    setMessage('success', 'Presensi tersimpan')
  } catch (err) {
    const serverMsg = err?.response?.data?.message || err?.message
    setMessage('error', serverMsg || 'Gagal presensi. Coba lagi.')
  } finally {
    loading.value = false
  }
}

async function refreshData() {
  await ambilProfilPegawai()
  await ambilRiwayatPresensi()
}

function logout() {
  localStorage.removeItem('simpadu_token')
  localStorage.removeItem('simpadu_user')
  router.push('/')
}

onMounted(async () => {
  t = window.setInterval(() => {
    now.value = new Date()
  }, 1000)

  await ambilProfilPegawai()
  await ambilRiwayatPresensi()
})

onBeforeUnmount(() => {
  if (t) window.clearInterval(t)
})
</script>

<style scoped>
/* Layout utama */
.shell{display:grid;grid-template-columns:280px 1fr;min-height:100vh;background:radial-gradient(900px 420px at 65% 0%, rgba(255,216,77,.18), rgba(255,216,77,0) 55%),linear-gradient(180deg,#f7f9fc 0%,#f2f5fa 100%)}
.sidebar{background:linear-gradient(180deg,#083155 0%,#072a47 100%);color:#fff;padding:18px 16px;display:flex;flex-direction:column;gap:16px}
.brand{display:flex;align-items:center;gap:12px;padding:10px 12px;border-radius:16px;background:rgba(255,255,255,.06);text-decoration:none;color:inherit}
.brand-logo{width:34px;height:34px;border-radius:10px;background:#fff;object-fit:contain;padding:4px}
.brand-title{font-weight:800;font-size:18px;line-height:1}
.brand-sub{font-size:12px;color:#ffd54d;margin-top:4px;font-weight:700}
.nav{display:flex;flex-direction:column;gap:10px;margin-top:4px}
.nav-item{display:flex;align-items:center;gap:10px;padding:12px 14px;border-radius:14px;color:#eaf2ff;text-decoration:none;font-weight:700;background:transparent}
.nav-item .nav-ic{width:22px;display:inline-flex;justify-content:center;opacity:.95}
.nav-item.active{background:#ffcc29;color:#062840}
.sidebar-bottom{margin-top:auto;display:flex;flex-direction:column;gap:10px}
.profile-pill{display:flex;align-items:center;gap:10px;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:10px 12px;color:#fff;text-align:left;cursor:pointer}
.avatar{width:40px;height:40px;border-radius:14px;background:#ffcc29;color:#062840;display:flex;align-items:center;justify-content:center;font-weight:900}
.profile-name{font-weight:800;line-height:1.1}
.profile-role{font-size:11px;opacity:.85;margin-top:2px;font-weight:700}
.logout-btn{border:0;border-radius:14px;padding:12px 14px;font-weight:800;cursor:pointer;background:#ffffff;color:#062840}

.main{padding:22px 22px 40px}
.page-header{display:flex;align-items:center;justify-content:space-between;background:#fff;border:1px solid #e8eef6;border-radius:22px;padding:18px 18px;margin-bottom:18px;box-shadow:0 16px 40px rgba(2,21,46,.08)}
.page-title h1{margin:0;font-size:22px;font-weight:900;color:#0b1f35}
.page-title p{margin:6px 0 0;color:#64748b;font-weight:600}
.btn-refresh{border:0;background:#072a47;color:#fff;border-radius:14px;padding:10px 14px;font-weight:800;cursor:pointer;box-shadow:0 10px 18px rgba(7,42,71,.18)}
.btn-refresh:disabled{opacity:.6;cursor:not-allowed}

.welcome{background:#fff;border:1px solid #e8eef6;border-radius:22px;padding:18px 18px;max-width:720px;margin:0 auto 18px;box-shadow:0 16px 40px rgba(2,21,46,.08)}
.welcome-top{font-size:12px;font-weight:900;letter-spacing:.08em;color:#0b4ea2}
.welcome-title{font-size:26px;font-weight:950;margin-top:6px;color:#0b1f35}

.grid{display:grid;grid-template-columns:1fr 1fr;gap:18px;max-width:880px;margin:0 auto}
.card{background:#fff;border:1px solid #e8eef6;border-radius:22px;padding:18px;box-shadow:0 16px 40px rgba(2,21,46,.08)}
.card h2{margin:0 0 14px;font-size:18px;font-weight:900;color:#0b1f35;text-align:center}

.mini-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:14px}
.mini-box{border:1px solid #e9eef7;border-radius:14px;padding:12px;text-align:center;background:#f8fafc}
.mini-label{font-size:11px;font-weight:900;color:#64748b;letter-spacing:.06em}
.mini-value{margin-top:4px;font-size:14px;font-weight:900;color:#0b1f35}

.mode{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px}
.mode-btn{border:1px solid #e5eaf3;background:#fff;border-radius:12px;padding:10px 12px;font-weight:900;cursor:pointer;transition:all 0.2s ease}
.mode-btn.active{background:#0b4ea2;color:#fff;border-color:#0b4ea2;box-shadow:0 6px 14px rgba(11,78,162,.25)}
.mode-btn:disabled{opacity:.6;cursor:not-allowed}

.jam-box{border:1px solid #eef2f7;border-radius:14px;padding:12px;background:#fff;margin-bottom:14px}
.jam-row{display:flex;justify-content:space-between;align-items:center;font-weight:800;color:#0b1f35}
.jam-row+ .jam-row{margin-top:10px;color:#334155}

.btn-presensi{width:100%;border:0;border-radius:14px;padding:12px 14px;background:#41b883;color:#fff;font-weight:900;cursor:pointer}
.btn-presensi:disabled{opacity:.55;cursor:not-allowed}
.hint{text-align:center;font-size:11px;color:#94a3b8;margin-top:10px;font-weight:700}

.riwayat-head{display:flex;align-items:center;justify-content:center;margin-bottom:10px}
.riwayat-list{display:flex;flex-direction:column;gap:12px;max-height:340px;overflow:auto;padding-right:6px}
.riwayat-item{display:flex;align-items:center;justify-content:space-between;background:#f8fafc;border:1px solid #eef2f7;border-radius:16px;padding:12px}
.riwayat-date{font-weight:900;color:#0b1f35}
.riwayat-time{font-size:12px;color:#64748b;font-weight:700;margin-top:6px}
.riwayat-time-short{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.riwayat-time-short .dot{opacity:.5}
.riwayat-badge{min-width:82px;text-align:center;border-radius:999px;padding:6px 10px;font-weight:900;font-size:12px}
.riwayat-badge.ok{background:#e6f9ee;color:#0c7a3d}
.riwayat-badge.no{background:#ffe9e9;color:#c92b2b}
.riwayat-empty{color:#94a3b8;text-align:center;font-weight:800;padding:10px 0}

.profile-page{max-width:900px;margin:0 auto;display:flex;flex-direction:column;gap:18px}
.profile-hero{display:flex;gap:16px;align-items:center}
.profile-avatar-lg{width:74px;height:74px;border-radius:22px;background:#ffcc29;color:#062840;display:flex;align-items:center;justify-content:center;font-weight:950;font-size:34px}
.profile-hero-top{font-size:12px;font-weight:900;letter-spacing:.08em;color:#0b4ea2}
.profile-hero-name{font-size:26px;font-weight:950;color:#0b1f35;margin-top:2px}
.profile-hero-email{color:#64748b;font-weight:700;margin-top:4px}

.profile-detail h2{text-align:left;margin-bottom:12px}
.form-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.field label{display:block;font-size:12px;color:#64748b;font-weight:900;margin-bottom:6px}
.field input,.field textarea{width:100%;border:1px solid #e5eaf3;border-radius:12px;padding:10px 12px;font-weight:800;background:#fff}
.field.full{grid-column:1 / -1}
.form-actions{display:flex;justify-content:flex-end;margin-top:12px}
.btn-secondary{border:1px solid #dbe6f5;background:#fff;border-radius:12px;padding:10px 14px;font-weight:900;cursor:pointer}

.toast{position:fixed;right:18px;bottom:18px;padding:10px 12px;border-radius:14px;font-weight:900;box-shadow:0 12px 28px rgba(2,21,46,.18)}
.toast.success{background:#e6f9ee;color:#0c7a3d}
.toast.error{background:#ffe9e9;color:#c92b2b}

@media (max-width: 980px){
  .shell{grid-template-columns:1fr}
  .sidebar{position:sticky;top:0;z-index:3}
  .grid{grid-template-columns:1fr}
}
</style>
