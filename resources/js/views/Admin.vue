<template>
  <div class="admin-layout">
    <aside class="admin-sidebar">
      <RouterLink to="/admin/dashboard" class="brand" aria-label="Kembali ke Dashboard">
        <img :src="logoUrl" alt="Logo Poliban" />
        <div>
          <h2>Simpadu</h2>
          <p>Admin Akademik Digital</p>
        </div>
      </RouterLink>

      <nav class="menu">
        <RouterLink to="/admin/dashboard" class="menu-link">
          <span>🏠</span>
          <b>Dashboard</b>
        </RouterLink>

        <RouterLink to="/admin/pegawai" class="menu-link">
          <span>👥</span>
          <b>Data Pegawai</b>
        </RouterLink>

        <RouterLink to="/admin/absensi" class="menu-link">
          <span>✅</span>
          <b>Presensi</b>
        </RouterLink>

        <RouterLink to="/admin/rekap" class="menu-link">
          <span>📊</span>
          <b>Rekap Presensi</b>
        </RouterLink>

        <RouterLink to="/admin/log" class="menu-link">
          <span>📝</span>
          <b>Log Aktivitas</b>
        </RouterLink>
      </nav>

      <button class="user-profile-button" type="button" @click="openProfile">
        <div class="avatar">{{ userInitial }}</div>
        <div>
          <strong>{{ userName }}</strong>
          <small>Admin Pegawai</small>
        </div>
      </button>

      <button class="logout-btn" type="button" @click="logout">
        Keluar
      </button>
    </aside>

    <main class="admin-main">
      <header class="topbar">
        <div>
          <h1>{{ pageTitle }}</h1>
          <p>{{ pageSubtitle }}</p>
        </div>

        <button
          v-if="page !== 'profil'"
          class="refresh-btn"
          type="button"
          :disabled="loading"
          @click="refreshData"
        >
          {{ loading ? 'Memuat...' : 'Refresh Data' }}
        </button>
      </header>

      <div v-if="message.text" :class="['message', message.type]">
        {{ message.text }}
      </div>

      <!-- DASHBOARD -->
      <section v-if="page === 'dashboard'" class="page-section">
        <div class="hero-card">
          <div>
            <p class="eyebrow">Dashboard Admin Pegawai</p>
            <h2>Selamat datang, {{ userName }}</h2>
          </div>
        </div>

        <div class="stats-grid dashboard-stats">
          <article class="stat-card">
            <span>👥</span>
            <small>Total Pegawai</small>
            <strong>{{ pegawaiList.length }}</strong>
          </article>

          <article class="stat-card jabatan">
            <span>🏷️</span>
            <small>Total Jabatan</small>
            <strong>{{ totalJabatan }}</strong>
          </article>

          <article class="stat-card ok">
            <span>✅</span>
            <small>Presensi Hari Ini</small>
            <strong>{{ totalPresensiHariIni }}</strong>
          </article>
        </div>

        <div class="grid-2">
          <article class="card">
            <div class="card-head">
              <h3>Jabatan Terdata</h3>
              <RouterLink to="/admin/pegawai">Kelola pegawai</RouterLink>
            </div>

            <div class="admin-dashboard-scroll">
              <div v-for="item in jabatanSummary" :key="item.nama" class="summary-row">
                <div>
                  <strong>{{ item.nama }}</strong>
                  <p>{{ item.total }} pegawai</p>
                </div>
                <span>{{ item.total }}</span>
              </div>

              <p v-if="jabatanSummary.length === 0" class="empty">Belum ada data jabatan.</p>
            </div>
          </article>

          <article class="card">
            <div class="card-head">
              <h3>Presensi Hari Ini</h3>
              <RouterLink to="/admin/rekap">Lihat rekap</RouterLink>
            </div>

            <div class="admin-dashboard-scroll">
              <div v-for="item in presensiHariIni.slice(0, 20)" :key="item._key" class="history-row">
                <div>
                  <strong>{{ item.nama || '-' }}</strong>
                  <p>{{ item.tanggal || item.created_at || '-' }} · {{ item.jenis || '-' }}</p>
                </div>

                <span :class="['pill', statusClass(item.status)]">
                  {{ labelStatus(item.status) }}
                </span>
              </div>

              <p v-if="presensiHariIni.length === 0" class="empty">Belum ada presensi hari ini.</p>
            </div>
          </article>
        </div>
      </section>

      <!-- PEGAWAI -->
      <section v-else-if="page === 'pegawai'" class="page-section">
        <div class="section-head">
          <div>
            <h2>Data Pegawai</h2>
          </div>

          <div class="section-actions">
            <input
              v-model="search"
              class="search-input"
              type="search"
              placeholder="Cari nama, NIP, email..."
            />

            <button class="primary-btn" type="button" @click="showPegawaiForm = !showPegawaiForm">
              {{ showPegawaiForm ? 'Tutup Form' : '+ Tambah Pegawai' }}
            </button>
          </div>
        </div>

        
        <div v-if="showPegawaiForm" class="modal-overlay" @click.self="closePegawaiModal">
          <form class="card pegawai-form modal-card" @submit.prevent="handlePegawaiSubmit">
            <div class="modal-head">
              <h3>{{ isEditing ? 'Edit Pegawai' : 'Tambah Pegawai Baru' }}</h3>
              <button class="modal-close" type="button" @click="closePegawaiModal" aria-label="Tutup">
                ✕
              </button>
            </div>

            <div class="form-grid">
              <label>
                <span>Nama Pegawai</span>
                <input v-model="pegawaiForm.nama" type="text" placeholder="Nama pegawai" required />
              </label>

              <label>
                <span>NIP / ID</span>
                <input
                  v-model="pegawaiForm.nip"
                  type="text"
                  placeholder="NIP / ID pegawai"
                  :disabled="isEditing"
                  required
                />
              </label>

              <label>
                <span>Email</span>
                <input v-model="pegawaiForm.email" type="email" placeholder="Email pegawai" />
              </label>

              <label>
                <span>Jabatan</span>
                <select v-model="pegawaiForm.jabatan" required>
                  <option value="" disabled>Pilih jabatan</option>
                  <option v-for="jab in jabatanOptions" :key="jab" :value="jab">
                    {{ jab }}
                  </option>
                </select>
              </label>
            </div>

            <div class="form-actions">
              <button class="secondary-btn" type="button" @click="resetPegawaiForm">
                Reset
              </button>
              <button v-if="isEditing" class="danger-btn" type="button" @click="cancelEdit">
                Batal Edit
              </button>
              <button class="primary-btn" type="submit" :disabled="loading">
                {{ loading ? 'Menyimpan...' : (isEditing ? 'Simpan Perubahan' : 'Simpan Pegawai') }}
              </button>
            </div>
          </form>
        </div>

        <div class="table-card">
          <table>
            <thead>
              <tr>
                <th>No</th>
                <th>Nama Pegawai</th>
                <th>NIP / ID</th>
                <th>Email</th>
                <th>Jabatan</th>
                <th class="col-actions">Aksi</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="(pegawai, index) in filteredPegawai" :key="pegawai._key">
                <td>{{ index + 1 }}</td>
                <td>
                  <div class="table-user">
                    <span>{{ initial(pegawai.nama) }}</span>
                    <b>{{ pegawai.nama }}</b>
                  </div>
                </td>
                <td>{{ pegawai.nip || pegawai.id || '-' }}</td>
                <td>{{ pegawai.email || '-' }}</td>
                <td><span class="role-badge">{{ pegawai.jabatan || pegawai.role || 'Pegawai' }}</span></td>
                <td class="col-actions">
                  <div class="row-actions">
                    <button class="mini-btn" type="button" @click="startEdit(pegawai)">Edit</button>
                    <button class="mini-btn danger" type="button" @click="hapusPegawai(pegawai)">Hapus</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>

          <p v-if="filteredPegawai.length === 0" class="empty table-empty">
            Data pegawai tidak ditemukan.
          </p>
        </div>
      </section>

      
      <!-- PRESENSI -->
      <section v-else-if="page === 'absensi'" class="page-section">
        <div class="presensi-admin-layout presensi-style-like-dosen">
          <form class="card presensi-harian-card" @submit.prevent="submitAbsensi">
            <h3 class="presensi-card-title">Presensi Harian</h3>

            <div class="presensi-info-grid">
              <div class="presensi-info-box">
                <small>TANGGAL</small>
                <strong>{{ presensiTanggalLabel }}</strong>
              </div>
              <div class="presensi-info-box">
                <small>NAMA</small>
                <strong>{{ userName }}</strong>
              </div>
            </div>

            <div class="presensi-mode-switch">
              <button
                type="button"
                :class="['presensi-mode-btn', { active: fasePresensi === 'datang' }]"
                @click="setFasePresensiManual('datang')"
              >
                Datang
              </button>

              <button
                type="button"
                :class="['presensi-mode-btn', { active: fasePresensi === 'pulang' }]"
                :disabled="!bolehPilihPulang"
                @click="setFasePresensiManual('pulang')"
              >
                Pulang
              </button>
            </div>

            <div class="presensi-jam-box">
              <div class="presensi-jam-row">
                <span>Jam Datang</span>
                <strong>{{ jamDatangHariIni }}</strong>
              </div>
              <div class="presensi-jam-row">
                <span>Jam Pulang</span>
                <strong>{{ jamPulangHariIni }}</strong>
              </div>
            </div>

            <button class="presensi-submit-btn" type="submit" :disabled="loading || !bisaSubmitPresensi">
              {{ loading ? 'Menyimpan...' : 'Presensi' }}
            </button>

          </form>

          <article class="card riwayat-presensi-card">
            <h3 class="riwayat-title">Riwayat Presensi</h3>

            <div class="riwayat-list">
              <div v-for="row in riwayatPresensiGrouped.slice(0, 10)" :key="row._key" class="riwayat-item">
                <div class="riwayat-item-head">
                  <strong class="riwayat-date">{{ row.label }}</strong>
                  <span :class="['pill', row.lengkap ? 'ok' : 'danger']">
                    {{ row.lengkap ? 'Lengkap' : '-' }}
                  </span>
                </div>

                <div class="riwayat-meta">
                  Datang:{{ row.datang || '-' }} · Pulang:{{ row.pulang || '-' }}
                </div>
              </div>

              <p v-if="riwayatPresensiGrouped.length === 0" class="empty">Belum ada riwayat presensi.</p>
            </div>
          </article>
        </div>
      </section>
<!-- REKAP -->
      <section v-else-if="page === 'rekap'" class="page-section">
        <div class="section-head">
          <div>
            <h2>Rekap Presensi Seluruh Pegawai</h2>
          </div>
        </div>

        <div class="stats-grid dashboard-stats">
          <article class="stat-card ok">
            <span>✅</span>
            <small>Sudah Presensi</small>
            <strong>{{ rekapHadir }}</strong>
          </article>

          <article class="stat-card danger">
            <span>❌</span>
            <small>Belum Presensi</small>
            <strong>{{ rekapTidakHadir }}</strong>
          </article>

          <article class="stat-card">
            <span>📋</span>
            <small>Total Pegawai</small>
            <strong>{{ pegawaiList.length }}</strong>
          </article>
        </div>

        <div class="rekap-filter-card">
          <div>
            <h3>Filter Rekap</h3>
          </div>

          <div class="rekap-filter-actions">
            <select v-model="rekapFilterMode">
              <option value="hari">Per Hari</option>
              <option value="bulan">Per Bulan</option>
            </select>

            <input
              v-if="rekapFilterMode === 'hari'"
              v-model="rekapFilterDate"
              type="date"
            />

            <input
              v-else
              v-model="rekapFilterMonth"
              type="month"
            />
          </div>
        </div>

        <div class="table-card">
          <table>
            <thead>
              <tr>
                <th>ID Absensi</th>
                <th>ID Pegawai</th>
                <th>Nama Pegawai</th>
                <th>Email</th>
                <th>Tanggal</th>
                <th>Waktu Masuk</th>
                <th>Waktu Keluar</th>
                <th>Keterangan</th>
                <th>Status</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="item in rekapPresensiFiltered" :key="item._key">
                <td>{{ item.id_absensi || '-' }}</td>
                <td>{{ item.id_pegawai || item.nip || '-' }}</td>
                <td>{{ item.nama || '-' }}</td>
                <td>{{ item.email || '-' }}</td>
                <td>{{ item.tanggal || '-' }}</td>
                <td>{{ item.waktu_masuk || '-' }}</td>
                <td>{{ item.waktu_keluar || '-' }}</td>
                <td>{{ item.keterangan || '-' }}</td>
                <td><span :class="['pill', statusClass(item.status)]">{{ labelStatus(item.status) }}</span></td>
              </tr>
            </tbody>
          </table>

          <p v-if="rekapPresensiFiltered.length === 0" class="empty table-empty">
            Belum ada data rekap.
          </p>
        </div>
      </section>

      <!-- LOG -->
      <section v-else-if="page === 'log'" class="page-section">
        <div class="section-head">
          <div>
            <h2>Log Aktivitas</h2>
          </div>
        </div>

        <div class="card">
          <div class="admin-logs-scroll">
            <div v-for="log in logList" :key="log._key" class="log-row">
              <div>
                <strong>{{ log.title }}</strong>
                <p>{{ log.time }}</p>
              </div>
              <span>{{ log.type }}</span>
            </div>

            <p v-if="logList.length === 0" class="empty">Belum ada aktivitas.</p>
          </div>
        </div>
      </section>

      <!-- PROFIL -->
      <section v-else-if="page === 'profil'" class="page-section profile-section">
        <div class="profile-hero">
          <div class="big-avatar">{{ userInitial }}</div>
          <div>
            <p class="eyebrow">Profil Admin Pegawai</p>
            <h2>{{ profileForm.nama || userName }}</h2>
            <span>{{ profileForm.email || user.email || '-' }}</span>
          </div>
        </div>

        <form class="card profile-form" @submit.prevent="saveProfile">
          <h3>Data Lengkap Admin Pegawai</h3>

          <div class="form-grid">
            <label>
              <span>Nama Lengkap</span>
              <input v-model="profileForm.nama" type="text" placeholder="Nama admin" />
            </label>

            <label>
              <span>Email</span>
              <input v-model="profileForm.email" type="email" placeholder="Email admin" />
            </label>

            <label>
              <span>NIP / Username</span>
              <input v-model="profileForm.nip" type="text" placeholder="NIP atau username" />
            </label>

            <label>
              <span>Jabatan</span>
              <input v-model="profileForm.jabatan" type="text" placeholder="Admin Pegawai" />
            </label>

            <label>
              <span>Role</span>
              <input v-model="profileForm.role" type="text" placeholder="admin" />
            </label>

            <label class="full">
              <span>Alamat</span>
              <textarea v-model="profileForm.alamat" placeholder="Alamat lengkap"></textarea>
            </label>
          </div>

          <div class="form-actions">
            <button class="secondary-btn" type="button" @click="backToDashboard">
              Kembali
            </button>

            <button class="primary-btn" type="submit">
              Simpan Profil
            </button>
          </div>
        </form>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'
import ENDPOINTS from '../services/endpoints'

const logoUrl = '/assets/images/logo-poliban.png'

const props = defineProps({
  page: {
    type: String,
    default: 'dashboard',
  },
})

const router = useRouter()
const loading = ref(false)
const search = ref('')
const message = ref({ type: '', text: '' })
const showPegawaiForm = ref(false)
const isEditing = ref(false)
const editingNip = ref('')
const editingId = ref('')
const liveNow = ref(new Date())
const rekapFilterMode = ref('hari')
const rekapFilterDate = ref(new Date().toLocaleDateString('en-CA'))
const rekapFilterMonth = ref(new Date().toISOString().slice(0, 7))
const fasePresensiManual = ref('')
let clockTimer = null

function getStoredUser() {
  try {
    return JSON.parse(localStorage.getItem('simpadu_user') || '{}')
  } catch {
    return {}
  }
}

const user = ref(getStoredUser())
const pegawaiList = ref([])
const presensiList = ref([])
const logList = ref([])

const absensiForm = reactive({
  status: 'hadir',
  keterangan: '',
})

const pegawaiForm = reactive({
  nama: '',
  nip: '',
  email: '',
  jabatan: '',
})

const jabatanOptions = computed(() => {
  const set = new Set([
    'Admin Pegawai',
    'Staff Akademik',
    'Tendik',
    'Dosen',
    'Pegawai',
  ])

  pegawaiList.value.forEach((p) => {
    const val = p?.jabatan || p?.role
    if (val) set.add(String(val).trim())
  })

  // Pastikan jabatan yang sedang diedit tetap muncul di dropdown.
  if (pegawaiForm.jabatan) set.add(String(pegawaiForm.jabatan).trim())

  return Array.from(set)
    .filter(Boolean)
    .sort((a, b) => a.localeCompare(b, 'id'))
})


const profileForm = reactive({
  nama: '',
  email: '',
  nip: '',
  jabatan: 'Admin Pegawai',
  role: 'admin',
  no_hp: '',
  alamat: '',
})

const pageTitle = computed(() => ({
  dashboard: 'Dashboard Admin',
  pegawai: 'Data Pegawai',
  absensi: 'Presensi',
  rekap: 'Rekap Presensi',
  log: 'Log Aktivitas',
  profil: 'Profil Admin Pegawai',
}[props.page] || 'Dashboard Admin'))

const userName = computed(() => (
  profileForm.nama ||
  user.value.nama ||
  user.value.name ||
  user.value.nama_pegawai ||
  user.value.NAMA_PEGAWAI ||
  user.value.email ||
  user.value.username ||
  'Admin Pegawai'
))

const userInitial = computed(() => initial(userName.value))

const filteredPegawai = computed(() => {
  const keyword = search.value.trim().toLowerCase()
  if (!keyword) return pegawaiList.value

  return pegawaiList.value.filter((pegawai) => {
    return [pegawai.nama, pegawai.nip, pegawai.email, pegawai.role, pegawai.jabatan]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
      .includes(keyword)
  })
})

const totalJabatan = computed(() => {
  return new Set(
    pegawaiList.value
      .map((pegawai) => pegawai.jabatan || pegawai.role)
      .filter(Boolean)
      .map((jabatan) => String(jabatan).toLowerCase())
  ).size
})

const jabatanSummary = computed(() => {
  const map = new Map()

  pegawaiList.value.forEach((pegawai) => {
    const jabatan = pegawai.jabatan || pegawai.role || 'Pegawai'
    map.set(jabatan, (map.get(jabatan) || 0) + 1)
  })

  return Array.from(map.entries()).map(([nama, total]) => ({ nama, total }))
})

const todayKey = computed(() => formatDateKey(liveNow.value))

const presensiHariIni = computed(() => {
  return presensiList.value.filter((item) => {
    return formatDateKey(item.tanggal || item.created_at) === todayKey.value
  })
})

const totalPresensiHariIni = computed(() => presensiHariIni.value.length)


const currentUserIdKey = computed(() => {
  return String(
    profileForm.nip ||
      user.value.id_pegawai ||
      user.value.pegawai_id ||
      user.value.id ||
      user.value.NIP ||
      user.value.nip ||
      ''
  ).trim()
})

const currentUserEmailKey = computed(() => {
  return String(profileForm.email || user.value.email || user.value.EMAIL || '')
    .trim()
    .toLowerCase()
})

const todayIsoKey = computed(() => liveNow.value.toLocaleDateString('en-CA'))

function toIsoDateKey(value) {
  const raw = String(value || '').trim()
  if (!raw) return ''

  // Already ISO date
  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) return raw

  // ISO datetime
  if (/^\d{4}-\d{2}-\d{2}T/.test(raw)) return raw.slice(0, 10)

  // Common dd/mm/yyyy (treat as day/month/year)
  const m = raw.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/)
  if (m) {
    const day = m[1].padStart(2, '0')
    const month = m[2].padStart(2, '0')
    const year = m[3]
    return `${year}-${month}-${day}`
  }

  const parsed = new Date(raw)
  if (!Number.isNaN(parsed.getTime())) return parsed.toLocaleDateString('en-CA')

  return raw
}

const presensiSaya = computed(() => {
  const uid = currentUserIdKey.value
  const email = currentUserEmailKey.value

  return presensiList.value.filter((item) => {
    if (!item) return false
    const itemId = String(item.id_pegawai || item.nip || '').trim()
    const itemEmail = String(item.email || '').trim().toLowerCase()

    if (uid && itemId && itemId === uid) return true
    if (email && itemEmail && itemEmail === email) return true

    return false
  })
})

const riwayatPresensiGrouped = computed(() => {
  const map = new Map()

  presensiSaya.value.forEach((item) => {
    const iso = toIsoDateKey(item.tanggal || item.created_at)
    if (!iso) return

    const existing = map.get(iso) || {
      _key: `riwayat-${iso}`,
      iso,
      label: iso,
      datang: '',
      pulang: '',
    }

    if (!existing.datang && item.waktu_masuk) existing.datang = item.waktu_masuk
    if (!existing.pulang && item.waktu_keluar) existing.pulang = item.waktu_keluar

    map.set(iso, existing)
  })

  const list = Array.from(map.values()).map((row) => ({
    ...row,
    lengkap: Boolean(row.datang && row.pulang),
  }))

  list.sort((a, b) => String(b.iso).localeCompare(String(a.iso)))
  return list
})

const presensiHariIniRow = computed(() => {
  return riwayatPresensiGrouped.value.find((row) => row.iso === todayIsoKey.value) || null
})

const jamDatangHariIni = computed(() => presensiHariIniRow.value?.datang || '-')
const jamPulangHariIni = computed(() => presensiHariIniRow.value?.pulang || '-')

const presensiTanggalLabel = computed(() => {
  const d = liveNow.value
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`
})

const bolehPilihPulang = computed(() => {
  // Pulang hanya bisa dipilih jika sudah ada jam datang hari ini
  return Boolean(presensiHariIniRow.value?.datang)
})

const bisaSubmitPresensi = computed(() => {
  if (!bolehPresensiHariIni.value) return false

  // Jika sudah lengkap (datang & pulang), jangan izinkan submit lagi
  if (presensiHariIniRow.value?.datang && presensiHariIniRow.value?.pulang) return false

  // Pulang hanya valid jika sudah ada datang
  if (fasePresensi.value === 'pulang' && !presensiHariIniRow.value?.datang) return false

  return true
})



const rekapPresensi = computed(() => {
  const map = new Map()

  pegawaiList.value.forEach((pegawai) => {
    const idPegawai = pegawai.id || pegawai.nip || pegawai._key || '-'

    map.set(`pegawai-${pegawai._key}`, {
      _key: `rekap-pegawai-${pegawai._key}`,
      id_absensi: '-',
      id_pegawai: idPegawai,
      nama: pegawai.nama,
      nip: pegawai.nip || pegawai.id || '-',
      email: pegawai.email || '-',
      tanggal: new Date().toLocaleDateString('id-ID'),
      waktu_masuk: '-',
      waktu_keluar: '-',
      keterangan: 'Belum melakukan presensi',
      status: 'tidak_hadir',
    })
  })

  presensiList.value.forEach((item, index) => {
    const presensi = normalizePresensi(item, index)
    const key = `presensi-${presensi.id_absensi || presensi.id_pegawai || presensi.nip || presensi.nama}-${presensi.tanggal}-${presensi.waktu_masuk}-${presensi.waktu_keluar}`

    map.set(key, {
      ...presensi,
      status: presensi.waktu_masuk || presensi.waktu_keluar || normalizeStatus(presensi.status) === 'hadir'
        ? 'hadir'
        : 'tidak_hadir',
    })
  })

  return Array.from(map.values())
})

const rekapPresensiFiltered = computed(() => {
  return rekapPresensi.value.filter((item) => {
    const itemDate = toDateInputValue(item.tanggal || item.created_at)

    if (!itemDate) return false

    if (rekapFilterMode.value === 'bulan') {
      return itemDate.slice(0, 7) === rekapFilterMonth.value
    }

    return itemDate === rekapFilterDate.value
  })
})

const rekapHadir = computed(() => {
  return rekapPresensiFiltered.value.filter((item) => normalizeStatus(item.status) === 'hadir').length
})

const rekapTidakHadir = computed(() => {
  return rekapPresensiFiltered.value.filter((item) => normalizeStatus(item.status) !== 'hadir').length
})

const totalHadir = computed(() => rekapHadir.value)
const totalTidakHadir = computed(() => rekapTidakHadir.value)
const totalIzinSakit = computed(() => 0)

const liveClock = computed(() => {
  return liveNow.value.toLocaleTimeString('id-ID', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })
})

const liveDate = computed(() => liveNow.value.toLocaleDateString('id-ID', {
  weekday: 'long',
  day: '2-digit',
  month: 'long',
  year: 'numeric',
}))

const bolehPresensiHariIni = computed(() => {
  const day = liveNow.value.getDay()
  return day >= 1 && day <= 5
})

const fasePresensi = computed(() => {
  if (fasePresensiManual.value) return fasePresensiManual.value

  // Defaultkan fase berdasarkan kondisi presensi hari ini:
  // - Kalau belum datang, arahkan ke datang (supaya tombol Presensi bisa langsung dipencet).
  // - Kalau sudah datang tapi belum pulang, arahkan ke pulang.
  if (!presensiHariIniRow.value?.datang) return 'datang'
  if (!presensiHariIniRow.value?.pulang) return 'pulang'

  const hour = liveNow.value.getHours()
  return hour < 12 ? 'datang' : 'pulang'
})

const labelFasePresensi = computed(() => {
  return fasePresensi.value === 'datang' ? 'Presensi Datang' : 'Presensi Pulang'
})

const statusJadwalPresensi = computed(() => {
  if (!bolehPresensiHariIni.value) return 'Di luar jadwal'
  return fasePresensi.value === 'datang' ? 'Jadwal 08.00' : 'Jadwal 16.00'
})

function initial(value) {
  return String(value || 'A').trim().charAt(0).toUpperCase()
}

function normalizeStatus(status) {
  return String(status || '').toLowerCase().trim()
}

function labelStatus(status) {
  return normalizeStatus(status) === 'hadir' ? 'Hadir' : 'Tidak Hadir'
}

function statusClass(status) {
  const clean = normalizeStatus(status)
  if (clean === 'hadir') return 'ok'
  return 'danger'
}

function formatDateKey(value) {
  if (!value) return ''

  if (value instanceof Date) {
    return value.toLocaleDateString('id-ID')
  }

  const parsed = new Date(value)
  if (!Number.isNaN(parsed.getTime())) {
    return parsed.toLocaleDateString('id-ID')
  }

  return String(value).split(',')[0].trim()
}

function toDateInputValue(value) {
  if (!value) return ''

  if (value instanceof Date) {
    return value.toLocaleDateString('en-CA')
  }

  const raw = String(value).split(',')[0].trim()

  if (/^\d{4}-\d{2}-\d{2}/.test(raw)) {
    return raw.slice(0, 10)
  }

  const parts = raw.split(/[/-]/)

  if (parts.length === 3 && parts[0].length <= 2) {
    const [day, month, year] = parts
    return `${year.padStart(4, '0')}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
  }

  const parsed = new Date(value)
  if (!Number.isNaN(parsed.getTime())) {
    return parsed.toLocaleDateString('en-CA')
  }

  return ''
}

function setFasePresensiManual(value) {
  fasePresensiManual.value = value
}

function setMessage(type, text) {
  message.value = { type, text }

  if (text) {
    window.setTimeout(() => {
      message.value = { type: '', text: '' }
    }, 4200)
  }
}

function apiArray(response) {
  const data = response?.data?.data || response?.data || []

  if (Array.isArray(data)) return data
  if (Array.isArray(data.pegawai)) return data.pegawai
  if (Array.isArray(data.absensi)) return data.absensi
  if (Array.isArray(data.rekap)) return data.rekap
  if (Array.isArray(data.riwayat)) return data.riwayat
  if (Array.isArray(data.data)) return data.data

  return []
}

function normalizeJabatan(value) {
  if (!value) return 'Pegawai'

  if (typeof value === 'string') return value

  if (Array.isArray(value)) {
    return value
      .map((item) => normalizeJabatan(item))
      .filter(Boolean)
      .join(', ')
  }

  if (typeof value === 'object') {
    return (
      value.nama_jabatan ||
      value.nama ||
      value.jabatan ||
      value.name ||
      'Pegawai'
    )
  }

  return String(value)
}

function normalizePegawai(item, index = 0) {
  const nested = item?.pegawai || item?.user || item?.akun || item?.profile || item?.dosen || {}

  const getJabatanValue = (val) => {
    if (Array.isArray(val)) {
      return val.length > 0 ? val : null
    }
    return val
  }

  const jabatan = normalizeJabatan(
    item?.nama_jabatan ||
      item?.namaJabatan ||
      getJabatanValue(item?.jabatan) ||
      item?.unit_kerja ||
      item?.role ||
      item?.roles ||
      item?.posisi ||
      item?.UNIT_KERJA ||
      nested?.nama_jabatan ||
      nested?.namaJabatan ||
      getJabatanValue(nested?.jabatan) ||
      nested?.unit_kerja ||
      nested?.role ||
      nested?.roles ||
      nested?.posisi ||
      nested?.UNIT_KERJA
  )

  const nama =
    item?.nama ||
    item?.Nama ||
    item?.NAMA ||
    item?.nama_pegawai ||
    item?.NAMA_PEGAWAI ||
    item?.name ||
    item?.nama_lengkap ||
    item?.full_name ||
    item?.nama_dosen ||
    item?.NAMA_DOSEN ||
    nested?.nama ||
    nested?.Nama ||
    nested?.name ||
    nested?.nama_pegawai ||
    nested?.NAMA_PEGAWAI ||
    nested?.nama_lengkap ||
    nested?.full_name ||
    nested?.nama_dosen ||
    nested?.NAMA_DOSEN ||
    `Pegawai ${index + 1}`

  const nip =
    item?.nip ||
    item?.NIP ||
    item?.username ||
    item?.id_pegawai ||
    item?.ID_USER ||
    nested?.nip ||
    nested?.NIP ||
    nested?.username ||
    nested?.id_pegawai ||
    nested?.ID_USER ||
    ''

  const email =
    item?.email || item?.EMAIL || nested?.email || nested?.EMAIL || ''

  const id =
    item?.id ||
    item?.ID ||
    item?.pegawai_id ||
    item?.id_pegawai ||
    item?.id_dosen ||
    item?.ID_DOSEN ||
    nested?.id ||
    nested?.ID ||
    nested?.pegawai_id ||
    nested?.id_pegawai ||
    nested?.id_dosen ||
    nested?.ID_DOSEN ||
    ''

  return {
    ...item,
    _key: id || nip || item?.username || `pegawai-${index}`,
    id,
    nama,
    nip,
    email,
    role: jabatan,
    jabatan,
  }
}

function normalizePresensi(item, index = 0) {
  const tanggal =
    item.tanggal ||
    item.tanggal_absen ||
    item.tgl ||
    item.created_at ||
    new Date().toLocaleDateString('id-ID')

  const waktuMasuk =
    item.waktu_masuk ||
    item.jam_masuk ||
    item.check_in ||
    item.masuk ||
    item.waktu_datang ||
    item.datang ||
    item.waktuMasuk ||
    ''

  const waktuKeluar =
    item.waktu_keluar ||
    item.jam_keluar ||
    item.check_out ||
    item.keluar ||
    item.waktu_pulang ||
    item.pulang ||
    item.waktuKeluar ||
    ''

  // Support struktur dosen (beberapa backend mengirim id_dosen/nama_dosen)
  const idDosen =
    item.id_dosen ||
    item.ID_DOSEN ||
    item.dosen_id ||
    item.idDosen ||
    item.dosenId ||
    ''

  const nipDosen =
    item.nip_dosen ||
    item.NIP_DOSEN ||
    item.nipDosen ||
    ''

  const namaDosen =
    item.nama_dosen ||
    item.NAMA_DOSEN ||
    item.namaDosen ||
    ''

  const emailDosen =
    item.email_dosen ||
    item.EMAIL_DOSEN ||
    item.emailDosen ||
    ''

  const resolvedIdPegawai =
    item.id_pegawai ||
    item.pegawai_id ||
    item.idPegawai ||
    item.nip ||
    item.NIP ||
    idDosen ||
    nipDosen ||
    user.value.id_pegawai ||
    user.value.pegawai_id ||
    user.value.id ||
    user.value.NIP ||
    ''

  const resolvedNama =
    item.nama ||
    item.nama_pegawai ||
    item.NAMA_PEGAWAI ||
    item.name ||
    namaDosen ||
    userName.value

  const resolvedNip =
    item.nip ||
    item.NIP ||
    item.id_pegawai ||
    item.pegawai_id ||
    nipDosen ||
    idDosen ||
    user.value.nip ||
    user.value.NIP ||
    ''

  const resolvedEmail =
    item.email ||
    item.EMAIL ||
    emailDosen ||
    user.value.email ||
    user.value.EMAIL ||
    ''

  const keyBasis = resolvedIdPegawai || resolvedNip || resolvedNama || 'absensi'

  return {
    ...item,
    _key:
      item.id_absensi ||
      item.id ||
      item._key ||
      `${keyBasis}-${tanggal}-${waktuMasuk}-${waktuKeluar}-${index}`,
    id_absensi: item.id_absensi || item.id || item.ID || '',
    id_pegawai: resolvedIdPegawai,
    nama: resolvedNama,
    nip: resolvedNip,
    email: resolvedEmail,
    tanggal,
    waktu_masuk: waktuMasuk,
    waktu_keluar: waktuKeluar,
    created_at: item.created_at || tanggal,
    jenis: item.jenis || item.tipe_presensi || item.type || '',
    status: item.status || (waktuMasuk || waktuKeluar ? 'hadir' : 'tidak_hadir'),
    keterangan: item.keterangan || item.catatan || '',
  }
}

function loadLocalPresensi() {
  try {
    const data = JSON.parse(localStorage.getItem('simpadu_admin_presensi') || '[]')
    return Array.isArray(data) ? data.map(normalizePresensi) : []
  } catch {
    return []
  }
}

function saveLocalPresensi(list) {
  localStorage.setItem('simpadu_admin_presensi', JSON.stringify(list.map(normalizePresensi)))
}

function loadLocalPegawai() {
  try {
    const data = JSON.parse(localStorage.getItem('simpadu_admin_pegawai') || '[]')
    return Array.isArray(data) ? data.map(normalizePegawai) : []
  } catch {
    return []
  }
}

function saveLocalPegawai(list) {
  localStorage.setItem('simpadu_admin_pegawai', JSON.stringify(list.map(normalizePegawai)))
}

function loadLogs() {
  try {
    const data = JSON.parse(localStorage.getItem('simpadu_admin_logs') || '[]')
    logList.value = Array.isArray(data) ? data : []
  } catch {
    logList.value = []
  }
}

function pushLog(title, type = 'Info') {
  const log = {
    _key: `log-${Date.now()}`,
    title,
    type,
    time: new Date().toLocaleString('id-ID'),
  }

  logList.value = [log, ...logList.value].slice(0, 50)
  localStorage.setItem('simpadu_admin_logs', JSON.stringify(logList.value))
}

function uniquePegawaiKey(item, index = 0) {
  return String(
    item.nip ||
      item.NIP ||
      item.id_pegawai ||
      item.pegawai_id ||
      item.id ||
      item.ID ||
      item.email ||
      item.nama ||
      item.NAMA_PEGAWAI ||
      `pegawai-${index}`
  ).toLowerCase()
}

function sortPegawaiByNip(list) {
  return [...list].sort((a, b) => {
    const aNip = String(a.nip || a.id || '').toLowerCase()
    const bNip = String(b.nip || b.id || '').toLowerCase()
    return aNip.localeCompare(bNip, 'id', { numeric: true, sensitivity: 'base' })
  })
}

async function fetchPegawaiFromApi() {
  // Integrasi data admin:
  // - Postman menyediakan daftar pegawai/dosen melalui GET /api/dosen.
  // - Beberapa backend juga menyediakan GET /api/pegawai.
  // Keduanya dicoba dan digabung agar semua data API yang tersedia muncul di web.
  const endpointCandidates = [
    ENDPOINTS?.dosen?.all,
    ENDPOINTS?.pegawai?.all,
  ].filter(Boolean)

  const map = new Map()
  let lastError = null
  let successCount = 0

  for (const endpoint of endpointCandidates) {
    try {
      const response = await api.get(endpoint)
      successCount += 1

      apiArray(response).forEach((item, index) => {
        const normalized = normalizePegawai(item, index)
        const key = uniquePegawaiKey(normalized, index)

        if (!map.has(key)) {
          map.set(key, normalized)
        } else {
          map.set(key, { ...map.get(key), ...normalized })
        }
      })
    } catch (error) {
      lastError = error
    }
  }

  if (successCount === 0 && lastError) {
    throw lastError
  }

  return sortPegawaiByNip(Array.from(map.values()))
}

async function loadPegawai() {
  loading.value = true

  try {
    const apiData = await fetchPegawaiFromApi()

    if (apiData.length > 0) {
      pegawaiList.value = apiData
      localStorage.removeItem('simpadu_admin_pegawai')
    } else {
      pegawaiList.value = loadLocalPegawai()
      setMessage('info', 'Data pegawai dari API kosong. Menampilkan data lokal jika tersedia.')
    }
  } catch {
    pegawaiList.value = loadLocalPegawai()
    setMessage('info', 'Data pegawai API belum bisa dimuat. Menampilkan data lokal jika tersedia.')
  } finally {
    loading.value = false
  }
}

async function loadPresensi(showMessage = false) {
  loading.value = true

  try {
    const response = await api.get(ENDPOINTS.absensi.pegawaiRekap)
    const apiData = apiArray(response).map(normalizePresensi)

    if (apiData.length > 0) {
      presensiList.value = apiData
      localStorage.removeItem('simpadu_admin_presensi')
    } else {
      presensiList.value = loadLocalPresensi()

      if (showMessage && presensiList.value.length === 0) {
        setMessage('info', 'Data presensi API kosong.')
      }
    }
  } catch {
    presensiList.value = loadLocalPresensi()

    if (showMessage && presensiList.value.length === 0) {
      setMessage('info', 'Data presensi API belum bisa dimuat.')
    }
  } finally {
    loading.value = false
  }
}

async function tambahPegawai() {
  if (!pegawaiForm.nama || !pegawaiForm.nip || !pegawaiForm.jabatan) {
    setMessage('error', 'Nama, NIP/ID, dan jabatan wajib diisi.')
    return
  }

  loading.value = true

  // Backend kolaborasi kalian ternyata meng-insert ke tabel `dosen` yang mewajibkan field `nama_dosen`.
  // Jadi kita kirim field versi "Postman" + versi "dosen" sekaligus, biar kompatibel.
  const nama = String(pegawaiForm.nama).trim()
  const panggilan = nama.split(' ')[0] || nama

  const isDosen = String(pegawaiForm.jabatan).toLowerCase() === 'dosen'

  const payload = isDosen
    ? {
        id_pegawai: 53, // Default fallback id_pegawai or dynamically resolved
        id_user: 62,    // Default fallback id_user
        nama_dosen: nama,
        panggilan,
        jk: 'L',
        nidn: '0412089501',
        nip_baru: pegawaiForm.nip,
        email: pegawaiForm.email || `${panggilan.toLowerCase()}@email.com`,
        alamat: 'Jl. Sultan Adam Permai No. 22, Banjarmasin',
        id_jurusan: 1,
        id_prodi: 2,
        status_aktif: 1,
      }
    : {
        // versi Model Pegawai (menggunakan lowercase sesuai schema fillable)
        nip: pegawaiForm.nip,
        nik: '6371012345678902', // Default dummy NIK
        nama_pegawai: nama,
        jenis_kelamin: 'L',
        unit_kerja: pegawaiForm.jabatan,
        status_aktif: 1,

        // versi Postman (tetap dikirim untuk backwards compatibility jika ada)
        NIP: pegawaiForm.nip,
        NAMA_PEGAWAI: nama,
        JENIS_KELAMIN: 'Laki-laki',
        UNIT_KERJA: pegawaiForm.jabatan,
      }

  try {
    const endpoint = isDosen ? ENDPOINTS.dosen.tambah : ENDPOINTS.pegawai.tambah
    const response = await api.post(endpoint, payload)

    // server kadang balikin {data:{...}} atau langsung object
    const raw = response?.data?.data || response?.data || {}

    // Optimistic insert: pastikan langsung muncul di tabel walaupun GET /dosen belum mengembalikan data terbaru
    const optimistic = normalizePegawai(
      {
        ...raw,
        // paksa mapping nama & nip agar tidak jatuh ke "Pegawai 35"
        nama_pegawai: nama,
        NAMA_PEGAWAI: nama,
        nama_dosen: nama,
        user: raw?.user || { name: nama },
        nip: pegawaiForm.nip,
        NIP: pegawaiForm.nip,
        UNIT_KERJA: pegawaiForm.jabatan,
        jabatan: pegawaiForm.jabatan,
        role: pegawaiForm.jabatan,
      },
      0
    )

    const key = uniquePegawaiKey(optimistic, 0)
    const exists = pegawaiList.value.some((p, idx) => uniquePegawaiKey(p, idx) === key)

    if (!exists) {
      pegawaiList.value = [optimistic, ...pegawaiList.value]
    }

    resetPegawaiForm()
    showPegawaiForm.value = false
    pushLog(`Menambahkan pegawai ${optimistic.nama}`, 'CRUD')
    setMessage('success', response?.data?.message || 'Pegawai berhasil ditambahkan.')

    // Refresh dari server supaya sinkron.
    // Jika server belum mengembalikan data baru, kita tetap pertahankan data optimistic di atas.
    try {
      const before = pegawaiList.value
      await loadPegawai()
      const afterHas = pegawaiList.value.some((p, idx) => uniquePegawaiKey(p, idx) === key)
      if (!afterHas) {
        pegawaiList.value = before
      }
    } catch {
      // biarkan optimistic
    }
  } catch (err) {
    // Kalau gagal, jangan simpan ke browser (sesuai permintaan: harus benar-benar tersimpan ke server).
    const serverMsg =
      err?.response?.data?.message ||
      err?.response?.data?.error ||
      err?.message ||
      'Gagal menambahkan pegawai. Server menolak request.'

    pushLog(`Gagal menambahkan pegawai: ${nama}`, 'ERROR')
    setMessage('error', serverMsg)
  } finally {
    loading.value = false
  }
}


function getAuthHeader() {
  const token = localStorage.getItem('simpadu_token') || localStorage.getItem('token') || ''
  return token ? { Authorization: `Bearer ${token}` } : {}
}

function getPegawaiNip(row) {
  return (
    row?.nip ||
    row?.NIP ||
    row?.pegawai?.nip ||
    row?.pegawai?.NIP ||
    row?.pegawai?.id_pegawai ||
    row?.id_pegawai ||
    row?.id ||
    ''
  )
}

function getPegawaiId(row) {
  return (
    row?.id_pegawai ||
    row?.pegawai?.id_pegawai ||
    row?.id ||
    row?.ID ||
    row?.nip ||
    row?.NIP ||
    ''
  )
}

function startEdit(row) {
  const nip = getPegawaiNip(row)
  const id = getPegawaiId(row)
  if (!nip) {
    setMessage('error', 'Tidak bisa edit: NIP/ID pegawai tidak ditemukan.')
    return
  }

  isEditing.value = true
  editingNip.value = nip
  editingId.value = id
  showPegawaiForm.value = true

  pegawaiForm.nama = row?.nama || row?.nama_pegawai || row?.NAMA_PEGAWAI || row?.nama_dosen || row?.user?.name || ''
  pegawaiForm.nip = nip
  pegawaiForm.email = row?.email || row?.user?.email || ''
  pegawaiForm.jabatan = row?.jabatan || row?.role || row?.UNIT_KERJA || row?.unit_kerja || ''
}

function cancelEdit() {
  isEditing.value = false
  editingNip.value = ''
  editingId.value = ''
  resetPegawaiForm()
}


function closePegawaiModal() {
  showPegawaiForm.value = false
  if (isEditing.value) {
    cancelEdit()
    return
  }
  resetPegawaiForm()
}

async function handlePegawaiSubmit() {
  if (isEditing.value) return await updatePegawai()
  return await tambahPegawai()
}

async function updatePegawai() {
  if (!pegawaiForm.nama || !pegawaiForm.nip || !pegawaiForm.jabatan) {
    setMessage('error', 'Nama, NIP/ID, dan jabatan wajib diisi.')
    return
  }

  loading.value = true
  const nama = String(pegawaiForm.nama).trim()
  const panggilan = nama.split(' ')[0] || nama
  const nip = editingNip.value || pegawaiForm.nip

  const isDosen = String(pegawaiForm.jabatan).toLowerCase() === 'dosen'

  const payload = isDosen
    ? {
        nama_dosen: nama,
        panggilan,
        jk: 'L',
        nidn: '0412089501',
        nip_baru: nip,
        email: pegawaiForm.email || `${panggilan.toLowerCase()}@email.com`,
        alamat: 'Jl. Sultan Adam Permai No. 22, Banjarmasin',
        id_jurusan: 1,
        id_prodi: 2,
        status_aktif: 1,
      }
    : {
        // versi Model Pegawai (menggunakan lowercase sesuai schema fillable)
        nama_pegawai: nama,
        unit_kerja: pegawaiForm.jabatan,

        // versi Postman (tetap dikirim untuk backwards compatibility jika ada)
        NAMA_PEGAWAI: nama,
        UNIT_KERJA: pegawaiForm.jabatan,
      }

  try {
    const endpoint = isDosen ? ENDPOINTS.dosen.edit(nip) : ENDPOINTS.pegawai.edit(editingId.value || nip)
    await api.put(endpoint, payload, { headers: { ...getAuthHeader() } })

    // update lokal biar langsung terlihat
    const next = pegawaiList.value.map((p) => {
      const pnip = getPegawaiNip(p)
      if (pnip !== nip) return p
      return normalizePegawai(
        {
          ...p,
          nip,
          NIP: nip,
          nama_pegawai: nama,
          NAMA_PEGAWAI: nama,
          nama_dosen: nama,
          UNIT_KERJA: pegawaiForm.jabatan,
          jabatan: pegawaiForm.jabatan,
          role: pegawaiForm.jabatan,
          email: pegawaiForm.email,
          user: { ...(p.user || {}), name: nama, email: pegawaiForm.email || p?.user?.email },
        },
        0
      )
    })
    pegawaiList.value = next

    pushLog(`Mengubah pegawai ${nama} (${nip})`, 'CRUD')
    setMessage('success', 'Pegawai berhasil diperbarui.')
    cancelEdit()

    // coba sinkron dari server
    try { await loadPegawai() } catch {}
  } catch (err) {
    const serverMsg =
      err?.response?.data?.message ||
      err?.response?.data?.error ||
      err?.message ||
      'Gagal memperbarui pegawai.'
    pushLog(`Gagal edit pegawai ${nip}: ${serverMsg}`, 'ERROR')
    setMessage('error', serverMsg)
  } finally {
    loading.value = false
  }
}

async function hapusPegawai(row) {
  const nip = getPegawaiNip(row)
  const nama = row?.nama || row?.nama_pegawai || row?.NAMA_PEGAWAI || row?.nama_dosen || '-'
  if (!nip) {
    setMessage('error', 'Tidak bisa hapus: NIP/ID pegawai tidak ditemukan.')
    return
  }

  const ok = window.confirm(`Yakin hapus pegawai ${nama} (${nip})?`)
  if (!ok) return

  loading.value = true
  const isDosen = String(row?.jabatan || row?.role || '').toLowerCase() === 'dosen'

  try {
    const id = getPegawaiId(row)
    const endpoint = isDosen ? ENDPOINTS.dosen.hapus(nip) : ENDPOINTS.pegawai.hapus(id || nip)
    await api.delete(endpoint, { headers: { ...getAuthHeader() } })
    pegawaiList.value = pegawaiList.value.filter((p) => getPegawaiNip(p) !== nip)
    pushLog(`Menghapus pegawai ${nama} (${nip})`, 'CRUD')
    setMessage('success', 'Pegawai berhasil dihapus.')
  } catch (err) {
    const serverMsg =
      err?.response?.data?.message ||
      err?.response?.data?.error ||
      err?.message ||
      'Gagal menghapus pegawai.'
    pushLog(`Gagal hapus pegawai ${nip}: ${serverMsg}`, 'ERROR')
    setMessage('error', serverMsg)
  } finally {
    loading.value = false
  }
}

function resetPegawaiForm() {
  pegawaiForm.nama = ''
  pegawaiForm.nip = ''
  pegawaiForm.email = ''
  pegawaiForm.jabatan = ''
}

async function submitAbsensi() {
  if (!bolehPresensiHariIni.value) {
    setMessage('error', 'Presensi hanya tersedia Senin sampai Jumat.')
    return
  }

  loading.value = true

  const sekarang = new Date()
  const tanggalHariIni = sekarang.toLocaleDateString('en-CA')
  const waktuRealtime = sekarang.toLocaleTimeString('id-ID', {
    hour12: false,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })

  const idPegawai =
    profileForm.nip ||
    user.value.id_pegawai ||
    user.value.pegawai_id ||
    user.value.id ||
    user.value.NIP ||
    user.value.nip ||
    ''

  const payload = {
    id_pegawai: idPegawai,
    tanggal: tanggalHariIni,
    waktu_masuk: fasePresensi.value === 'datang' ? waktuRealtime : '',
    waktu_keluar: fasePresensi.value === 'pulang' ? waktuRealtime : '',
    keterangan: labelFasePresensi.value,
  }

  const endpointPresensi =
    fasePresensi.value === 'datang'
      ? ENDPOINTS.absensi.pegawaiMasuk
      : ENDPOINTS.absensi.pegawaiKeluar

  try {
    // Sesuai Postman: POST /pegawai/absensi/masuk atau POST /pegawai/absensi/keluar.
    // API mengambil id_pegawai dari Bearer token, jadi tidak perlu kirim body manual agar tidak 422.
    const response = await api.post(endpointPresensi)

    const presensiBaru = normalizePresensi({
      _key: `admin-${fasePresensi.value}-${todayKey.value}`,
      id_absensi: response?.data?.data?.id_absensi || response?.data?.data?.id || '',
      id_pegawai: idPegawai,
      nama: userName.value,
      nip: profileForm.nip || user.value.nip || user.value.NIP || '',
      email: profileForm.email || user.value.email || user.value.EMAIL || '',
      tanggal: payload.tanggal,
      waktu_masuk: payload.waktu_masuk,
      waktu_keluar: payload.waktu_keluar,
      keterangan: payload.keterangan,
      status: 'hadir',
      ...(response?.data?.data || {}),
    })

    presensiList.value = [
      presensiBaru,
      ...presensiList.value.filter((item) => String(item._key) !== String(presensiBaru._key)),
    ]
    saveLocalPresensi(presensiList.value)

    pushLog(`Admin melakukan ${labelFasePresensi.value}`, 'Presensi')
    setMessage('success', response?.data?.message || `${labelFasePresensi.value} berhasil disimpan.`)
  } catch {
    const presensiBaru = normalizePresensi({
      _key: `admin-local-${fasePresensi.value}-${todayKey.value}`,
      id_absensi: `LOCAL-${Date.now()}`,
      id_pegawai: idPegawai,
      nama: userName.value,
      nip: profileForm.nip || user.value.nip || user.value.NIP || '',
      email: profileForm.email || user.value.email || user.value.EMAIL || '',
      tanggal: payload.tanggal,
      waktu_masuk: payload.waktu_masuk,
      waktu_keluar: payload.waktu_keluar,
      keterangan: payload.keterangan,
      status: 'hadir',
    })

    presensiList.value = [
      presensiBaru,
      ...presensiList.value.filter((item) => String(item._key) !== String(presensiBaru._key)),
    ]
    saveLocalPresensi(presensiList.value)

    pushLog(`${labelFasePresensi.value} admin disimpan lokal`, 'Presensi')
    setMessage('info', 'API presensi belum bisa diakses. Data disimpan sementara di browser.')
  } finally {
    loading.value = false
  }
}

function initProfile() {
  profileForm.nama = user.value.nama || user.value.name || user.value.nama_pegawai || user.value.NAMA_PEGAWAI || 'Admin Pegawai'
  profileForm.email = user.value.email || user.value.EMAIL || 'adminpegawai@email.com'
  profileForm.nip = user.value.nip || user.value.NIP || user.value.username || 'ADMIN-001'
  profileForm.jabatan = normalizeJabatan(user.value.jabatan || user.value.role || 'Admin Pegawai')
  profileForm.role = user.value.role || user.value.tipe || 'admin'
  profileForm.no_hp = user.value.no_hp || user.value.noHp || user.value.telepon || '-'
  profileForm.alamat = user.value.alamat || user.value.ALAMAT || '-'
}

function openProfile() {
  sessionStorage.setItem('simpadu_admin_profile_allowed', 'true')
  router.push('/admin/profil')
}

function backToDashboard() {
  sessionStorage.removeItem('simpadu_admin_profile_allowed')
  router.push('/admin/dashboard')
}

function guardProfileAccess() {
  if (props.page !== 'profil') return

  const allowed = sessionStorage.getItem('simpadu_admin_profile_allowed') === 'true'

  if (!allowed) {
    router.replace('/admin/dashboard')
    setMessage('info', 'Profil hanya bisa dibuka dari kartu user di pojok kiri bawah.')
  }
}

async function saveProfile() {
  const updatedUser = {
    ...user.value,
    ...profileForm,
    role: 'admin',
    tipe: 'admin',
  }

  user.value = updatedUser
  localStorage.setItem('simpadu_user', JSON.stringify(updatedUser))

  try {
    // Sesuai Postman: PUT /api/pegawai/profile untuk update data profil akun login.
    await api.put(ENDPOINTS.pegawai.updateProfile, {
      alamat: profileForm.alamat || user.value.alamat || user.value.ALAMAT || '',
      jenis_kelamin: user.value.jenis_kelamin || user.value.JENIS_KELAMIN || 'L',
    })
    pushLog('Admin memperbarui profil melalui API', 'CRUD')
    setMessage('success', 'Profil berhasil diperbarui.')
  } catch {
    pushLog('Admin memperbarui profil lokal', 'CRUD')
    setMessage('info', 'Profil tersimpan di browser. API profil belum bisa menerima perubahan.')
  }
}

function logout() {
  sessionStorage.removeItem('simpadu_admin_profile_allowed')
  localStorage.removeItem('simpadu_token')
  localStorage.removeItem('simpadu_user')
  localStorage.removeItem('simpadu_role')
  localStorage.removeItem('simpadu_logged_in')
  router.push('/')
}

async function refreshData() {
  if (props.page === 'pegawai') {
    await loadPegawai()
    return
  }

  if (props.page === 'absensi' || props.page === 'rekap') {
    await Promise.all([loadPegawai(), loadPresensi(true)])
    return
  }

  if (props.page === 'log') {
    loadLogs()
    return
  }

  if (props.page === 'profil') {
    guardProfileAccess()
    return
  }

  await Promise.all([loadPegawai(), loadPresensi(false)])
}

onMounted(async () => {
  initProfile()
  loadLogs()
  guardProfileAccess()
  clockTimer = window.setInterval(() => {
    liveNow.value = new Date()
  }, 1000)
  await refreshData()
})

onUnmounted(() => {
  if (clockTimer) window.clearInterval(clockTimer)
})

watch(
  () => props.page,
  async () => {
    guardProfileAccess()
    await refreshData()
  }
)
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.admin-layout {
  min-height: 100vh;
  display: flex;
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.08), transparent 28%),
    linear-gradient(135deg, #f8fafc 0%, #eef2f7 100%);
  color: #111827;
  font-family: Inter, "Segoe UI", Arial, sans-serif;
}

.admin-sidebar {
  width: 260px;
  min-height: 100vh;
  background: #062b49;
  color: #ffffff;
  padding: 26px 18px 18px;
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  box-shadow: 18px 0 42px rgba(15, 23, 42, 0.12);
  z-index: 5;
}

.brand {
  display: flex;
  text-decoration: none;
  color: inherit;
  cursor: pointer;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  margin-bottom: 28px;
}

.brand img {
  width: 46px;
  height: 46px;
  border-radius: 15px;
  object-fit: contain;
  background: #ffffff;
  padding: 6px;
}

.brand h2 {
  margin: 0;
  line-height: 1;
  font-size: 24px;
  font-weight: 900;
  letter-spacing: -0.6px;
}

.brand p {
  margin: 5px 0 0;
  color: #c7d2fe;
  font-size: 11px;
  font-weight: 700;
}

.menu {
  display: grid;
  gap: 10px;
}

.menu-link {
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 46px;
  padding: 12px 15px;
  color: #e5eefb;
  text-decoration: none;
  border-radius: 999px;
  font-size: 14px;
  transition: 0.2s ease;
}

.menu-link b {
  font-weight: 800;
}

.menu-link:hover,
.menu-link.router-link-active,
.menu-link.router-link-exact-active {
  background: #ffd21e;
  color: #06152b;
  transform: translateX(2px);
}

.user-profile-button {
  width: 100%;
  margin-top: auto;
  border: 1px solid rgba(255, 255, 255, 0.16);
  background: rgba(255, 255, 255, 0.08);
  color: #ffffff;
  border-radius: 20px;
  padding: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  text-align: left;
  cursor: pointer;
  transition: 0.2s ease;
}

.user-profile-button:hover {
  background: rgba(255, 210, 30, 0.16);
  border-color: rgba(255, 210, 30, 0.45);
  transform: translateY(-1px);
}

.avatar,
.mini-avatar,
.big-avatar {
  display: grid;
  place-items: center;
  background: #ffd21e;
  color: #06152b;
  font-weight: 900;
}

.avatar {
  width: 42px;
  height: 42px;
  border-radius: 16px;
  flex: 0 0 42px;
}

.big-avatar {
  width: 96px;
  height: 96px;
  border-radius: 28px;
  font-size: 42px;
}

.user-profile-button strong {
  display: block;
  color: #ffffff;
  font-size: 13px;
  font-weight: 900;
}

.user-profile-button small {
  display: block;
  margin-top: 3px;
  color: #dbeafe;
  font-size: 11px;
  font-weight: 700;
}

.logout-btn {
  width: 100%;
  margin-top: 12px;
  border: none;
  border-radius: 14px;
  padding: 11px 14px;
  background: #ffffff;
  color: #062b49;
  font-weight: 900;
  cursor: pointer;
}

.admin-main {
  flex: 1;
  min-width: 0;
  padding: 28px;
}

.topbar {
  min-height: 78px;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(14px);
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  padding: 18px 22px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  box-shadow: 0 18px 36px rgba(15, 23, 42, 0.06);
}

.topbar h1 {
  margin: 0;
  color: #111827;
  font-size: 24px;
  font-weight: 900;
}

.topbar p {
  margin: 6px 0 0;
  color: #64748b;
  font-size: 14px;
}

.refresh-btn,
.primary-btn,
.secondary-btn {
  border: none;
  border-radius: 14px;
  padding: 12px 18px;
  font-weight: 900;
  cursor: pointer;
}

.refresh-btn,
.primary-btn {
  background: #062b49;
  color: #ffffff;
  box-shadow: 0 12px 24px rgba(6, 43, 73, 0.16);
}

.secondary-btn {
  background: #ffffff;
  color: #062b49;
  border: 1px solid #d8e2ef;
}

.refresh-btn:disabled,
.primary-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.message {
  margin-top: 18px;
  padding: 13px 16px;
  border-radius: 16px;
  font-weight: 800;
  font-size: 14px;
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

.page-section {
  padding: 26px 0 44px;
}

.hero-card,
.card,
.table-card,
.profile-hero {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06);
}

.hero-card {
  padding: 28px;
  margin-bottom: 22px;
  display: flex;
  justify-content: space-between;
  gap: 18px;
  overflow: hidden;
}

.eyebrow {
  margin: 0 0 8px;
  color: #0b4b84;
  font-size: 12px;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.hero-card h2 {
  margin: 0;
  color: #111827;
  font-size: 30px;
  font-weight: 900;
}

.hero-card span {
  display: block;
  margin-top: 8px;
  color: #64748b;
  font-size: 15px;
}

.hero-icon {
  width: 76px;
  height: 76px;
  border-radius: 24px;
  background: #eef6ff;
  display: grid;
  place-items: center;
  font-size: 34px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(160px, 1fr));
  gap: 18px;
  margin-bottom: 22px;
}

.dashboard-stats {
  grid-template-columns: repeat(3, minmax(180px, 1fr));
}

.stat-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 24px;
  padding: 20px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.05);
}

.stat-card span {
  font-size: 22px;
}

.stat-card small {
  display: block;
  margin-top: 12px;
  color: #64748b;
  font-size: 12px;
  font-weight: 900;
}

.stat-card strong {
  display: block;
  margin-top: 6px;
  color: #111827;
  font-size: 32px;
  font-weight: 900;
}

.stat-card.ok strong {
  color: #059669;
}

.stat-card.danger strong {
  color: #dc2626;
}

.stat-card.jabatan strong {
  color: #0b4b84;
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 22px;
  align-items: start;
}

.card {
  padding: 22px;
}

.card h3 {
  margin: 0 0 16px;
  color: #111827;
  font-size: 18px;
  font-weight: 900;
}

.card-head,
.section-head,
.history-row,
.log-row,
.summary-row {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: center;
}

.card-head,
.section-head {
  margin-bottom: 20px;
}

.card-head h3,
.section-head h2 {
  margin: 0;
}

.card-head a {
  color: #0b4b84;
  font-size: 13px;
  font-weight: 900;
  text-decoration: none;
}

.section-head h2 {
  color: #111827;
  font-size: 24px;
  font-weight: 900;
}

.section-head p {
  margin: 6px 0 0;
  color: #64748b;
}

.section-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  flex-wrap: wrap;
}

.search-input {
  width: min(320px, 100%);
  height: 46px;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 0 14px;
  outline: none;
  background: #ffffff;
}

.history-row,
.log-row,
.summary-row {
  padding: 14px;
  border-radius: 18px;
  background: #f8fafc;
  border: 1px solid #edf2f7;
  margin-bottom: 12px;
}

.summary-row strong,
.history-row strong,
.log-row strong {
  display: block;
  color: #111827;
  font-size: 14px;
  font-weight: 900;
}

.summary-row p,
.history-row p,
.log-row p {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 12px;
}

.summary-row span,
.log-row span {
  border-radius: 999px;
  padding: 7px 12px;
  background: #eef6ff;
  color: #062b49;
  font-size: 12px;
  font-weight: 900;
}

.empty {
  margin: 0;
  padding: 18px;
  color: #64748b;
  text-align: center;
  font-weight: 700;
}

.table-card {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  min-width: 820px;
}

th {
  text-align: left;
  padding: 16px;
  color: #475569;
  background: #f8fafc;
  font-size: 12px;
  font-weight: 900;
  text-transform: uppercase;
}

td {
  padding: 16px;
  border-top: 1px solid #edf2f7;
  color: #111827;
  font-size: 14px;
}

.table-user {
  display: flex;
  align-items: center;
  gap: 10px;
}

.table-user span {
  width: 34px;
  height: 34px;
  border-radius: 12px;
  background: #eef6ff;
  color: #062b49;
  display: grid;
  place-items: center;
  font-weight: 900;
}

.role-badge,
.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 7px 12px;
  font-size: 12px;
  font-weight: 900;
}

.role-badge {
  background: #eef6ff;
  color: #062b49;
}

.pill.ok {
  background: #dcfce7;
  color: #166534;
}

.pill.danger {
  background: #fee2e2;
  color: #991b1b;
}

.table-empty {
  padding: 24px;
}

.form-card label,
.profile-form label,
.pegawai-form label {
  display: block;
  margin: 16px 0 8px;
  color: #475569;
  font-size: 12px;
  font-weight: 900;
}

/* Modal tambah/edit pegawai */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  z-index: 120;
}

.modal-card {
  width: min(760px, 100%);
  max-height: calc(100vh - 48px);
  overflow: auto;
}

.modal-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 10px;
}

.modal-head h3 {
  margin: 0;
}

.modal-close {
  width: 40px;
  height: 40px;
  border-radius: 14px;
  border: 1px solid #d8e2ef;
  background: #ffffff;
  color: #0f172a;
  display: grid;
  place-items: center;
  cursor: pointer;
  font-weight: 900;
}

.modal-close:hover {
  background: #f1f5f9;
}


.status-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.status-grid-single {
  grid-template-columns: 1fr;
}

.status-grid button {
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 13px;
  background: #ffffff;
  color: #111827;
  font-weight: 900;
  cursor: pointer;
}

.status-grid button.active {
  background: #062b49;
  color: #ffffff;
  border-color: #062b49;
}

textarea,
.profile-form input,
.pegawai-form input,
.pegawai-form select {
  width: 100%;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 12px 14px;
  outline: none;
  background: #ffffff;
}


.pegawai-form select {
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
}

textarea {
  min-height: 92px;
  resize: none;
}

.form-card .primary-btn {
  width: 100%;
  margin-top: 18px;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
}

.form-grid .full {
  grid-column: 1 / -1;
}

.form-grid span {
  display: block;
  margin-bottom: 8px;
  color: #475569;
  font-size: 12px;
  font-weight: 900;
}

.form-actions {
  margin-top: 22px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.live-clock-card {
  text-align: center;
  background: #f8fafc;
  border: 1px solid #edf2f7;
  border-radius: 22px;
  padding: 22px;
  margin-bottom: 18px;
}

.live-clock-card small {
  color: #64748b;
  font-size: 12px;
  font-weight: 900;
  text-transform: uppercase;
}

.live-clock-card strong {
  display: block;
  margin-top: 8px;
  font-size: 34px;
  font-weight: 900;
  color: #062b49;
}

.live-clock-card p {
  margin: 6px 0 0;
  color: #64748b;
  font-weight: 700;
}

.jadwal-presensi-grid,
.presensi-summary-box {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 18px;
}

.jadwal-card,
.presensi-summary-box div {
  background: #ffffff;
  border: 1px solid #d8e2ef;
  border-radius: 18px;
  padding: 14px;
}

.jadwal-card.active {
  border-color: #ffd21e;
  background: #fff7cc;
}

.jadwal-card small,
.presensi-summary-box small {
  display: block;
  color: #64748b;
  font-size: 11px;
  font-weight: 900;
}

.jadwal-card strong,
.presensi-summary-box strong {
  display: block;
  margin-top: 4px;
  color: #111827;
  font-size: 18px;
  font-weight: 900;
}

.jadwal-card span {
  display: block;
  margin-top: 4px;
  color: #64748b;
  font-size: 12px;
  font-weight: 700;
}

.profile-section {
  max-width: 980px;
}

.profile-hero {
  padding: 26px;
  margin-bottom: 22px;
  display: flex;
  align-items: center;
  gap: 22px;
}

.profile-hero h2 {
  margin: 0 0 6px;
  font-size: 28px;
  font-weight: 900;
}

.profile-hero span {
  color: #64748b;
}

.profile-form,
.pegawai-form {
  padding: 24px;
  margin-bottom: 22px;
}

@media (max-width: 1100px) {
  .stats-grid,
  .dashboard-stats,
  .grid-2 {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 840px) {
  .admin-layout {
    flex-direction: column;
  }

  .admin-sidebar {
    width: 100%;
    min-height: auto;
    position: relative;
  }

  .admin-main {
    padding: 18px;
  }

  .topbar,
  .section-head,
  .hero-card,
  .profile-hero {
    align-items: flex-start;
    flex-direction: column;
  }

  .stats-grid,
  .dashboard-stats,
  .grid-2,
  .form-grid,
  .status-grid,
  .jadwal-presensi-grid,
  .presensi-summary-box {
    grid-template-columns: 1fr;
  }

  .section-actions {
    width: 100%;
    justify-content: stretch;
  }

  .section-actions .search-input,
  .section-actions .primary-btn {
    width: 100%;
  }
}


/* CLEAN PRESENSI ADMIN - menghilangkan item ringkasan bawah tombol hadir */
.presensi-card {
  max-width: 520px;
  margin: 0 auto;
}

.presensi-card label {
  margin-top: 18px;
  text-align: center;
}

.live-clock-card {
  margin-bottom: 20px !important;
  border-radius: 24px !important;
  background: #f8fafc !important;
}

.live-clock-card strong {
  font-size: 36px !important;
  letter-spacing: -1px !important;
}

.jadwal-presensi-grid {
  margin-bottom: 18px !important;
}

.jadwal-card {
  border-radius: 18px !important;
  background: #ffffff !important;
}

.jadwal-card.active {
  border-color: #ffd21e !important;
  background: #fff7cc !important;
}

.status-grid-single {
  margin-bottom: 22px !important;
}

.status-grid-single button {
  min-height: 54px !important;
  border-radius: 16px !important;
  background: #062b49 !important;
  color: #ffffff !important;
  font-size: 16px !important;
  box-shadow: 0 14px 26px rgba(6, 43, 73, 0.16) !important;
}

.status-grid-single button:hover {
  background: #0a3b63 !important;
}

.presensi-card .primary-btn {
  margin-top: 10px !important;
  min-height: 50px !important;
  border-radius: 16px !important;
}

/* Pastikan elemen ringkasan lama tidak tampil jika masih tersisa dari cache */
.presensi-summary-box {
  display: none !important;
}

.history-row {
  border-radius: 16px !important;
}

@media (max-width: 840px) {
  .presensi-card {
    max-width: 100% !important;
  }
}



/* REVISI PRESENSI + REKAP FIELD DOCUMENTER */
.presensi-admin-layout {
  display: grid;
  grid-template-columns: minmax(520px, 680px) minmax(420px, 1fr);
  gap: 28px;
  align-items: start;
}

.presensi-card {
  max-width: 680px !important;
  width: 100% !important;
  padding: 30px !important;
}

.live-clock-card {
  padding: 30px !important;
}

.live-clock-card strong {
  font-size: 44px !important;
}

.jadwal-presensi-grid {
  gap: 16px !important;
}

.jadwal-card {
  padding: 18px !important;
}

.hadir-only-btn {
  width: 100%;
  min-height: 62px;
  margin-top: 22px;
  border: none;
  border-radius: 18px;
  background: #062b49;
  color: #ffffff;
  font-size: 18px;
  font-weight: 900;
  cursor: pointer;
  box-shadow: 0 16px 30px rgba(6, 43, 73, 0.18);
}

.hadir-only-btn:hover {
  background: #0a3b63;
}

.hadir-only-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.status-grid-single {
  display: none !important;
}

.presensi-summary-box {
  display: none !important;
}

@media (max-width: 1100px) {
  .presensi-admin-layout {
    grid-template-columns: 1fr;
  }

  .presensi-card {
    max-width: 100% !important;
  }
}

@media (max-width: 840px) {
  .presensi-admin-layout {
    grid-template-columns: 1fr;
  }

  .live-clock-card strong {
    font-size: 34px !important;
  }
}



/* REVISI ADMIN: dashboard tanpa bintang, filter rekap, presensi tanpa jam */
.hero-card {
  align-items: center;
}

.hero-icon {
  display: none !important;
}

.presensi-admin-layout {
  grid-template-columns: minmax(560px, 760px) minmax(420px, 1fr) !important;
}

.presensi-card {
  max-width: 760px !important;
  width: 100% !important;
  padding: 30px !important;
}

.live-clock-card,
.jadwal-presensi-grid {
  display: none !important;
}

.presensi-mode-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
  margin-bottom: 24px;
}

.presensi-mode-card {
  min-height: 150px;
  border: 1px solid #d8e2ef;
  border-radius: 22px;
  background: #ffffff;
  color: #111827;
  display: grid;
  place-items: center;
  align-content: center;
  gap: 8px;
  cursor: pointer;
  transition: 0.2s ease;
}

.presensi-mode-card span {
  font-size: 34px;
}

.presensi-mode-card strong {
  display: block;
  font-size: 20px;
  font-weight: 900;
}

.presensi-mode-card small {
  color: #64748b;
  font-size: 13px;
  font-weight: 800;
}

.presensi-mode-card:hover {
  border-color: #062b49;
  box-shadow: 0 14px 28px rgba(6, 43, 73, 0.08);
  transform: translateY(-1px);
}

.presensi-mode-card.active {
  border-color: #ffd21e;
  background: #fff7cc;
  color: #06152b;
}

.hadir-only-btn {
  margin-top: 0 !important;
}

.rekap-filter-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 24px;
  padding: 20px;
  margin-bottom: 22px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.05);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.rekap-filter-card h3 {
  margin: 0;
  color: #111827;
  font-size: 18px;
  font-weight: 900;
}

.rekap-filter-card p {
  margin: 6px 0 0;
  color: #64748b;
  font-size: 13px;
  font-weight: 700;
}

.rekap-filter-actions {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.rekap-filter-actions select,
.rekap-filter-actions input {
  height: 46px;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  background: #ffffff;
  padding: 0 14px;
  color: #111827;
  font-weight: 800;
  outline: none;
}

.rekap-filter-actions select:focus,
.rekap-filter-actions input:focus {
  border-color: #062b49;
  box-shadow: 0 0 0 4px rgba(6, 43, 73, 0.12);
}

@media (max-width: 1100px) {
  .presensi-admin-layout {
    grid-template-columns: 1fr !important;
  }
}

@media (max-width: 840px) {
  .presensi-mode-grid,
  .rekap-filter-card {
    grid-template-columns: 1fr !important;
  }

  .rekap-filter-card {
    align-items: flex-start;
    flex-direction: column;
  }

  .rekap-filter-actions,
  .rekap-filter-actions select,
  .rekap-filter-actions input {
    width: 100%;
  }
}


.col-actions{
  width:1%;
  white-space:nowrap;
  text-align:center;
  vertical-align:middle;
  min-width:120px;
}

.row-actions{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  gap:6px;
}
.mini-btn{
  border:1px solid rgba(15,23,42,.15);
  background:#fff;
  padding:6px 10px;
  border-radius:10px;
  font-size:12px;
  cursor:pointer;
}
.mini-btn:hover{ background: rgba(2,132,199,.06); }
.mini-btn.danger{ border-color: rgba(239,68,68,.35); }
.mini-btn.danger:hover{ background: rgba(239,68,68,.08); }
.danger-btn{
  border:1px solid rgba(239,68,68,.35);
  background:#fff;
  color:#b91c1c;
  padding:10px 14px;
  border-radius:14px;
  font-weight:700;
  cursor:pointer;
}
.danger-btn:hover{ background: rgba(239,68,68,.08); }

/* Custom Scroll adjustments for AdminLayout components */
.admin-dashboard-scroll {
  max-height: 350px;
  overflow-y: auto;
  padding-right: 4px;
}

.admin-logs-scroll {
  max-height: calc(100vh - 240px);
  overflow-y: auto;
  padding-right: 4px;
}

.table-card {
  max-height: calc(100vh - 280px);
  overflow-y: auto;
  overflow-x: auto;
  position: relative;
}

.table-card table th {
  position: sticky;
  top: 0;
  z-index: 2;
  background: #f8fafc;
  box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.05);
}

/* Custom premium scrollbar for AdminLayout scroll containers */
.admin-dashboard-scroll::-webkit-scrollbar,
.admin-logs-scroll::-webkit-scrollbar,
.table-card::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.admin-dashboard-scroll::-webkit-scrollbar-track,
.admin-logs-scroll::-webkit-scrollbar-track,
.table-card::-webkit-scrollbar-track {
  background: transparent;
}

.admin-dashboard-scroll::-webkit-scrollbar-thumb,
.admin-logs-scroll::-webkit-scrollbar-thumb,
.table-card::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 10px;
}

.admin-dashboard-scroll::-webkit-scrollbar-thumb:hover,
.admin-logs-scroll::-webkit-scrollbar-thumb:hover,
.table-card::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.2);
}


/* Presensi layout (mirip Presensi Dosen) */
.presensi-style-like-dosen {
  display: grid;
  grid-template-columns: minmax(340px, 380px) minmax(340px, 380px);
  justify-content: center;
  gap: 26px;
}

@media (max-width: 980px) {
  .presensi-style-like-dosen {
    grid-template-columns: 1fr;
    justify-items: center;
  }
}

.presensi-harian-card {
  padding: 26px 26px 22px !important;
  max-width: 380px;
  width: 100%;
}

.presensi-card-title {
  margin: 0 0 18px;
  text-align: center;
  font-size: 20px;
  font-weight: 900;
}

.presensi-info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 18px;
}

.presensi-info-box {
  background: #f8fafc;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 14px 12px;
  text-align: center;
}

.presensi-info-box small {
  display: block;
  margin-bottom: 6px;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  color: #64748b;
}

.presensi-info-box strong {
  font-size: 14px;
  font-weight: 900;
  color: #0f172a;
}

.presensi-mode-switch {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 18px;
}

.presensi-mode-btn {
  height: 42px;
  border-radius: 14px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  font-weight: 900;
  color: #0f172a;
  cursor: pointer;
  box-shadow: 0 10px 20px rgba(15, 23, 42, 0.06);
}

.presensi-mode-btn.active {
  border-color: #cbd5e1;
  background: #ffffff;
}

.presensi-mode-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  box-shadow: none;
}

.presensi-jam-box {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 14px 14px;
  margin-bottom: 18px;
  background: #ffffff;
}

.presensi-jam-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 6px 0;
  color: #64748b;
  font-size: 12px;
  font-weight: 700;
}

.presensi-jam-row strong {
  color: #0f172a;
  font-weight: 900;
  font-size: 13px;
}

.presensi-submit-btn {
  width: 100%;
  height: 52px;
  border: none;
  border-radius: 14px;
  background: #44b68a;
  color: #ffffff;
  font-weight: 900;
  font-size: 14px;
  cursor: pointer;
  box-shadow: 0 16px 30px rgba(68, 182, 138, 0.22);
}

.presensi-submit-btn:hover {
  background: #36a97c;
}

.presensi-submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  box-shadow: none;
}

.presensi-note {
  margin: 12px 0 0;
  text-align: center;
  font-size: 11px;
  color: #94a3b8;
  font-weight: 700;
}

.riwayat-presensi-card {
  padding: 22px !important;
  max-width: 380px;
  width: 100%;
}

.riwayat-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 900;
}

.riwayat-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  max-height: 520px;
  overflow: auto;
  padding-right: 6px;
}

.riwayat-item {
  border: 1px solid #e5e7eb;
  border-radius: 18px;
  padding: 14px;
  background: #f8fafc;
}

.riwayat-item-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.riwayat-date {
  font-size: 14px;
  font-weight: 900;
  color: #0f172a;
}

.riwayat-meta {
  margin-top: 10px;
  padding: 10px 12px;
  border-radius: 14px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  color: #64748b;
  font-size: 12px;
  font-weight: 700;
}
/* Presensi Admin (rapatkan jarak antar kartu seperti contoh) */
.presensi-admin-layout.presensi-style-like-dosen {
  /* kunci lebar layout agar dua kartu tidak terpencar jauh */
  max-width: 860px;
  margin: 0 auto;
  justify-content: center;
  gap: 26px !important;
  grid-template-columns: minmax(340px, 360px) minmax(340px, 360px) !important;
}

.presensi-admin-layout.presensi-style-like-dosen .presensi-harian-card,
.presensi-admin-layout.presensi-style-like-dosen .riwayat-presensi-card {
  width: 100%;
  max-width: 360px;
}

@media (max-width: 920px) {
  .presensi-admin-layout.presensi-style-like-dosen {
    max-width: 520px;
    grid-template-columns: 1fr !important;
  }

  .presensi-admin-layout.presensi-style-like-dosen .presensi-harian-card,
  .presensi-admin-layout.presensi-style-like-dosen .riwayat-presensi-card {
    max-width: 100%;
  }
}
</style>


