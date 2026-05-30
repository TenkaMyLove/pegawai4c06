<template>
  <div class="dashboard-layout">
    <aside class="side-nav">
      <div class="mini-brand">
        <img src="../assets/images/logo-poliban.png" alt="Logo" />
        <div>
          <h3>Simpadu</h3>
          <span>Dosen Akademik Digital</span>
        </div>
      </div>

      <nav>
        <RouterLink to="/dosen/dashboard" class="menu-item">
          🏠 <span>Dashboard</span>
        </RouterLink>

        <RouterLink to="/dosen/kelas" class="menu-item">
          📚 <span>Kelas Saya</span>
        </RouterLink>

        <RouterLink to="/dosen/input-nilai" class="menu-item">
          📝 <span>Input Nilai</span>
        </RouterLink>

        <RouterLink to="/dosen/presensi" class="menu-item">
          ✅ <span>Presensi Saya</span>
        </RouterLink>
      </nav>

      <div class="user-chip">
        <div class="avatar">{{ userInitial }}</div>
        <div>
          <strong>{{ userName }}</strong>
          <button @click="logout">Keluar</button>
        </div>
      </div>
    </aside>

    <main class="workspace">
      <header class="workspace-top">
        <h1>{{ title }}</h1>
        <div class="top-actions">
          <span>🔔</span>
        </div>
      </header>

      <div v-if="message.text" :class="['app-message', message.type]">
        {{ message.text }}
      </div>

      <p v-if="loading" class="loading-text">
        Memuat data...
      </p>

      <!-- DASHBOARD DOSEN -->
      <section v-if="page === 'dashboard'" class="page-section">
        <div class="welcome-card">
          <h2>Selamat Datang, {{ userName }}</h2>
          <p>Ringkasan aktivitas akademik berdasarkan kelas yang diberikan admin.</p>
        </div>

        <div class="stats-row four">
          <div class="metric-card">
            <small>Kelas Saya</small>
            <strong>{{ kelasSaya.length }}</strong>
          </div>

          <div class="metric-card green-text">
            <small>Hadir</small>
            <strong>{{ totalHadir }}</strong>
          </div>

          <div class="metric-card orange-text">
            <small>Izin / Sakit</small>
            <strong>{{ totalIzinSakit }}</strong>
          </div>

          <div class="metric-card red-text">
            <small>Tidak Hadir</small>
            <strong>{{ totalTidakHadir }}</strong>
          </div>
        </div>

        <div class="split-grid">
          <article class="white-card">
            <h3>Kelas Aktif</h3>

            <div
              v-for="kelas in kelasSaya.slice(0, 6)"
              :key="kelas._key"
              class="schedule-item"
            >
              <b>{{ kelas.id }}</b>
              <span>{{ kelas.nama }}</span>
              <em>{{ kelas.status || 'tersedia' }}</em>
            </div>

            <p v-if="kelasSaya.length === 0 && !loading">
              Belum ada kelas yang diberikan admin.
            </p>
          </article>

          <article class="white-card">
            <h3>Rekap Presensi Dosen</h3>

            <div
              v-for="item in riwayatPresensi.slice(0, 6)"
              :key="item._key"
              class="schedule-item"
            >
              <b>{{ item.tanggal || item.created_at || '-' }}</b>
              <span>{{ item.nama_kelas || item.kelas || '-' }}</span>
              <em>{{ item.status || '-' }}</em>
            </div>

            <p v-if="riwayatPresensi.length === 0 && !loading">
              Belum ada data presensi.
            </p>
          </article>
        </div>
      </section>

      <!-- KELAS SAYA -->
      <section v-else-if="page === 'kelas'" class="page-section">
        <div class="kelas-header">
          <div>
            <h2>Kelas Saya</h2>
            <p>
              Halaman ini digunakan untuk mengelola kelas, QR presensi, dan presensi manual mahasiswa.
            </p>
          </div>

          <button class="refresh-btn" @click="refreshData">
            Refresh Data
          </button>
        </div>

        <div v-if="kelasSaya.length > 0" class="kelas-grid">
          <article
            v-for="kelas in kelasSaya"
            :key="kelas._key"
            class="kelas-card"
          >
            <div class="kelas-card-top">
              <div class="kelas-icon">📚</div>

              <span
                :class="[
                  'kelas-status',
                  { active: kelas.status === 'berjalan' || kelas.status === 'aktif' }
                ]"
              >
                {{ kelas.status || 'Tersedia' }}
              </span>
            </div>

            <h3>{{ kelas.nama }}</h3>
            <p class="kelas-code">ID Kelas: {{ kelas.id }}</p>

            <div class="kelas-info">
              <div>
                <small>Semester</small>
                <strong>{{ kelas.semester || '-' }}</strong>
              </div>

              <div>
                <small>SKS</small>
                <strong>{{ kelas.sks || '-' }}</strong>
              </div>

              <div>
                <small>Mahasiswa</small>
                <strong>{{ kelas.jumlah_mahasiswa || kelas.total_mahasiswa || '-' }}</strong>
              </div>
            </div>

            <div class="kelas-detail">
              <p>
                <span>🏫</span>
                Ruangan:
                <b>{{ kelas.ruang || kelas.ruangan || '-' }}</b>
              </p>

              <p>
                <span>⏰</span>
                Jadwal:
                <b>{{ kelas.jadwal || kelas.jam || kelas.waktu || '-' }}</b>
              </p>

              <p>
                <span>👨‍🏫</span>
                Dosen:
                <b>{{ kelas.dosen_nama || kelas.dosen_email || userName }}</b>
              </p>
            </div>

            <textarea
              v-model="kelas.keterangan"
              class="kelas-textarea"
              placeholder="Keterangan kelas"
            ></textarea>

            <div class="kelas-actions qr-enabled-actions">
              <button
                class="start-btn"
                :disabled="loading"
                @click="startKelas(kelas)"
              >
                ▶ Start Kelas
              </button>

              <button
                class="qr-btn"
                :disabled="loading"
                @click="generateQr(kelas)"
              >
                📱 Generate QR
              </button>

              <button
                class="end-btn"
                :disabled="loading"
                @click="endKelas(kelas)"
              >
                ⏹ End Kelas
              </button>
            </div>

            <div v-if="kelas.qrCode" class="qr-preview-box">
              <h4>QR Presensi sudah dibuat</h4>

              <button class="open-qr-btn" @click="bukaQrModal(kelas)">
                Lihat QR Code
              </button>

              <button class="close-qr-btn" @click="tutupQr(kelas)">
                Hapus QR
              </button>
            </div>

            <!-- PRESENSI MANUAL MAHASISWA -->
            <div class="manual-presensi-card">
              <h4>Presensi Manual Mahasiswa</h4>
              <p>Gunakan fitur ini jika mahasiswa tidak bisa scan QR.</p>

              <div class="manual-presensi-grid">
                <input
                  v-model="kelas.manual_nim"
                  type="text"
                  placeholder="NIM Mahasiswa"
                />

                <input
                  v-model="kelas.manual_nama"
                  type="text"
                  placeholder="Nama Mahasiswa"
                />

                <select v-model="kelas.manual_status">
                  <option value="">Pilih status</option>
                  <option value="hadir">Hadir</option>
                  <option value="izin">Izin</option>
                  <option value="sakit">Sakit</option>
                  <option value="tidak_hadir">Tidak Hadir</option>
                </select>
              </div>

              <textarea
                v-model="kelas.manual_keterangan"
                placeholder="Keterangan tambahan"
              ></textarea>

              <button
                class="manual-presensi-btn"
                :disabled="loading"
                @click="simpanPresensiManualMahasiswa(kelas)"
              >
                {{ loading ? 'Menyimpan...' : 'Simpan Presensi Manual Mahasiswa' }}
              </button>
            </div>
          </article>
        </div>

        <div v-else-if="!loading" class="empty-kelas">
          <div>📭</div>
          <h3>Belum ada kelas</h3>
          <p>Minta admin menambahkan kelas untuk akun dosen ini melalui Dashboard Admin.</p>
        </div>
      </section>

      <!-- INPUT NILAI -->
      <section v-else-if="page === 'nilai'" class="page-section">
        <div class="content-header">
          <h2>Input Nilai Mahasiswa</h2>
        </div>

        <div class="white-card">
          <h3>Belum tersedia endpoint nilai</h3>
          <p>
            Di dokumentasi API yang diberikan belum ada endpoint nilai.
            Halaman ini aman agar tidak memanggil API yang belum ada.
          </p>
        </div>
      </section>

      <!-- PRESENSI DOSEN SENDIRI -->
      <section v-else class="page-section presensi-page">
        <div class="presensi-page-header">
          <div>
            <h2>Presensi Saya</h2>
            <p>
              Halaman ini digunakan untuk presensi dosen sendiri menggunakan API presensi manual.
            </p>
          </div>

          <button class="refresh-btn" @click="refreshData">
            Refresh Data
          </button>
        </div>

        <div class="presensi-layout">
          <div class="presensi-panel modern-presensi-card">
            <div class="presensi-icon">✅</div>

            <h2>Presensi Dosen</h2>
            <p class="presensi-subtitle">
              Pilih kelas, status kehadiran, lalu simpan presensi.
            </p>

            <label class="presensi-label">Pilih Kelas</label>
            <select v-model="kelasId" class="kelas-select">
              <option value="">Pilih kelas</option>

              <option
                v-for="kelas in kelasSaya"
                :key="kelas._key"
                :value="kelas.id"
              >
                {{ kelas.nama }} — ID {{ kelas.id }}
              </option>
            </select>

            <label class="presensi-label">Status Presensi</label>
            <div class="attendance-buttons">
              <button
                type="button"
                :class="{ active: statusPresensi === 'hadir' }"
                @click="statusPresensi = 'hadir'"
              >
                ✅<span>Hadir</span>
              </button>

              <button
                type="button"
                :class="{ active: statusPresensi === 'izin' }"
                @click="statusPresensi = 'izin'"
              >
                🟡<span>Izin</span>
              </button>

              <button
                type="button"
                :class="{ active: statusPresensi === 'sakit' }"
                @click="statusPresensi = 'sakit'"
              >
                🏥<span>Sakit</span>
              </button>

              <button
                type="button"
                :class="{ active: statusPresensi === 'cuti' }"
                @click="statusPresensi = 'cuti'"
              >
                📄<span>Cuti</span>
              </button>

              <button
                type="button"
                :class="{ active: statusPresensi === 'tidak_hadir' }"
                @click="statusPresensi = 'tidak_hadir'"
              >
                ❌<span>Tidak Hadir</span>
              </button>
            </div>

            <label class="presensi-label">Keterangan</label>
            <textarea
              v-model="keteranganPresensi"
              placeholder="Contoh: Hadir tepat waktu, izin kegiatan, sakit, atau catatan lainnya"
            ></textarea>

            <div class="presensi-summary">
              <div>
                <small>Kelas</small>
                <strong>{{ kelasDipilih?.nama || '-' }}</strong>
              </div>

              <div>
                <small>ID Kelas</small>
                <strong>{{ kelasId || '-' }}</strong>
              </div>

              <div>
                <small>Status</small>
                <strong>{{ statusPresensi || '-' }}</strong>
              </div>
            </div>

            <button
              class="save-presensi"
              :disabled="loading"
              @click="simpanPresensiDosen"
            >
              {{ loading ? 'Menyimpan...' : 'Simpan Presensi Dosen' }}
            </button>
          </div>

          <div class="white-card history-card modern-history-card">
            <h3>Riwayat Presensi Dosen</h3>

            <div
              v-for="item in riwayatPresensi"
              :key="item._key"
              class="history-item"
            >
              <div>
                <strong>{{ item.nama_kelas || item.kelas || '-' }}</strong>
                <p>{{ item.tanggal || item.created_at || '-' }}</p>
              </div>

              <span :class="['pill', pillClass(item.status)]">
                {{ item.status || '-' }}
              </span>
            </div>

            <p v-if="riwayatPresensi.length === 0 && !loading" class="empty-history">
              Belum ada riwayat presensi dosen.
            </p>
          </div>
        </div>
      </section>
    </main>

    <!-- POPUP QR CODE -->
    <div v-if="qrModal.show" class="qr-modal-overlay" @click.self="tutupQrModal">
      <div class="qr-modal">
        <button class="qr-modal-close" @click="tutupQrModal">
          ✕
        </button>

        <h2>QR Presensi</h2>

        <p>
          {{ qrModal.nama }} — ID {{ qrModal.kelasId }}
        </p>

        <div class="qr-modal-box">
          <img
            v-if="qrModal.qrCode"
            :src="qrModal.qrCode"
            alt="QR Presensi"
            @error="qrImageError"
          />
        </div>

        <p class="qr-modal-note">
          Scan QR ini untuk melakukan presensi.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'
import ENDPOINTS from '../services/endpoints'

const router = useRouter()

const props = defineProps({
  page: String,
})

const loading = ref(false)
const message = ref({
  type: '',
  text: '',
})

const user = ref(JSON.parse(localStorage.getItem('simpadu_user') || '{}'))

const kelasSaya = ref([])
const riwayatPresensi = ref([])

const kelasId = ref('')
const statusPresensi = ref('')
const keteranganPresensi = ref('')

const qrModal = ref({
  show: false,
  nama: '',
  kelasId: '',
  qrCode: '',
})

const adminKelasKey = 'simpadu_admin_kelas'

const userName = computed(() => {
  return (
    user.value.NAMA_PEGAWAI ||
    user.value.nama_pegawai ||
    user.value.nama ||
    user.value.name ||
    user.value.email ||
    user.value.EMAIL ||
    user.value.username ||
    'Dosen'
  )
})

const userInitial = computed(() => {
  return userName.value.charAt(0).toUpperCase()
})

const userIdentity = computed(() => {
  const keys = [
    user.value.id,
    user.value.ID,
    user.value.dosen_id,
    user.value.DOSEN_ID,
    user.value.pegawai_id,
    user.value.PEGAWAI_ID,
    user.value.user_id,
    user.value.USER_ID,
    user.value.NIP,
    user.value.nip,
    user.value.NIDN,
    user.value.nidn,
    user.value.email,
    user.value.EMAIL,
    user.value.NAMA_PEGAWAI,
    user.value.nama_pegawai,
    user.value.nama,
    user.value.name,
    user.value.username,
  ]

  return keys
    .filter((item) => item !== undefined && item !== null && String(item).trim() !== '')
    .map((item) => String(item).trim().toLowerCase())
})

const title = computed(() => {
  return {
    dashboard: 'Dashboard Dosen',
    kelas: 'Kelas Saya',
    nilai: 'Input Nilai Mahasiswa',
    presensi: 'Presensi Saya',
  }[props.page]
})

const kelasDipilih = computed(() => {
  return kelasSaya.value.find((kelas) => {
    return String(kelas.id) === String(kelasId.value)
  })
})

const totalHadir = computed(() => {
  return riwayatPresensi.value.filter((item) => {
    return normalizeStatus(item.status) === 'hadir'
  }).length
})

const totalIzinSakit = computed(() => {
  return riwayatPresensi.value.filter((item) => {
    return ['izin', 'sakit'].includes(normalizeStatus(item.status))
  }).length
})

const totalTidakHadir = computed(() => {
  return riwayatPresensi.value.filter((item) => {
    return ['tidak_hadir', 'tidak hadir', 'alpha'].includes(normalizeStatus(item.status))
  }).length
})

const presensiLocalKey = computed(() => {
  return `simpadu_presensi_dosen_${userIdentity.value[0] || 'dosen'}`
})

function setMessage(type, text) {
  message.value = {
    type,
    text,
  }
}

function normalizeStatus(status) {
  return String(status || '').toLowerCase().trim()
}

function pillClass(status) {
  const clean = normalizeStatus(status)

  if (clean === 'hadir') return 'ok'
  if (clean === 'izin' || clean === 'sakit' || clean === 'cuti') return 'warn'

  return 'danger'
}

function apiMessage(error, fallback) {
  return (
    error?.response?.data?.errors?.kelas_id?.[0] ||
    error?.response?.data?.errors?.nim?.[0] ||
    error?.response?.data?.errors?.nama?.[0] ||
    error?.response?.data?.errors?.status?.[0] ||
    error?.response?.data?.errors?.keterangan?.[0] ||
    error?.response?.data?.message ||
    error?.response?.data?.error ||
    fallback
  )
}

function ambilArray(response) {
  const data = response?.data?.data || response?.data || []

  if (Array.isArray(data)) return data
  if (Array.isArray(data.kelas)) return data.kelas
  if (Array.isArray(data.rekap)) return data.rekap
  if (Array.isArray(data.absensi)) return data.absensi
  if (Array.isArray(data.riwayat)) return data.riwayat

  return []
}

function normalizeKelas(item) {
  const id = String(
    item.id ||
      item.kelas_id ||
      item.id_kelas ||
      item.kode_kelas ||
      ''
  ).trim()

  return {
    ...item,
    id,
    _key: String(
      id ||
        item.nama ||
        item.nama_kelas ||
        item.mata_kuliah ||
        Math.random()
    ),
    nama:
      item.nama ||
      item.nama_kelas ||
      item.mata_kuliah ||
      item.kelas ||
      `Kelas ${id || ''}`,

    dosen_id: String(
      item.dosen_id ||
        item.id_dosen ||
        item.pegawai_id ||
        item.PEGAWAI_ID ||
        item.NIP ||
        item.nip ||
        ''
    ).trim(),

    dosen_email: String(
      item.dosen_email ||
        item.email_dosen ||
        item.email ||
        item.EMAIL ||
        ''
    ).trim(),

    dosen_nama: String(
      item.dosen_nama ||
        item.nama_dosen ||
        item.NAMA_PEGAWAI ||
        item.nama_pegawai ||
        ''
    ).trim(),

    ruang: item.ruang || item.ruangan || '',
    jadwal: item.jadwal || item.jam || item.waktu || '',
    status: item.status || 'tersedia',
    keterangan: item.keterangan || '',
    qrCode: item.qrCode || '',
    qrToken: item.qrToken || '',

    manual_nim: item.manual_nim || '',
    manual_nama: item.manual_nama || '',
    manual_status: item.manual_status || '',
    manual_keterangan: item.manual_keterangan || '',
  }
}

function normalizePresensi(item, index = 0) {
  return {
    ...item,
    _key:
      item._key ||
      item.id ||
      `${item.kelas_id || item.id_kelas || 'kelas'}-${item.created_at || item.tanggal || index}-${item.status || ''}`,

    tanggal:
      item.tanggal ||
      item.created_at ||
      new Date().toLocaleDateString('id-ID'),

    created_at:
      item.created_at ||
      new Date().toLocaleString('id-ID'),

    kelas_id:
      item.kelas_id ||
      item.id_kelas ||
      '',

    nama_kelas:
      item.nama_kelas ||
      item.mata_kuliah ||
      item.kelas ||
      '',

    status:
      item.status ||
      '',

    keterangan:
      item.keterangan ||
      item.catatan ||
      '',
  }
}

function ambilRiwayatPresensiLokal() {
  try {
    const data = JSON.parse(localStorage.getItem(presensiLocalKey.value) || '[]')
    return Array.isArray(data) ? data.map(normalizePresensi) : []
  } catch {
    return []
  }
}

function simpanRiwayatPresensiLokal(list) {
  localStorage.setItem(
    presensiLocalKey.value,
    JSON.stringify(list.map(normalizePresensi))
  )
}

function gabungPresensi(apiList, localList) {
  const map = new Map()

  ;[...localList, ...apiList].forEach((item, index) => {
    const presensi = normalizePresensi(item, index)
    map.set(String(presensi._key), presensi)
  })

  return Array.from(map.values())
}

function ambilSemuaKelasAdmin() {
  try {
    const data = JSON.parse(localStorage.getItem(adminKelasKey) || '[]')
    return Array.isArray(data) ? data.map(normalizeKelas) : []
  } catch {
    return []
  }
}

function simpanSemuaKelasAdmin(list) {
  localStorage.setItem(
    adminKelasKey,
    JSON.stringify(list.map(normalizeKelas))
  )
}

function kelasMilikDosen(kelas) {
  const normalized = normalizeKelas(kelas)

  const kelasKeys = [
    normalized.dosen_id,
    normalized.dosen_email,
    normalized.dosen_nama,
  ]
    .filter((item) => item !== undefined && item !== null && String(item).trim() !== '')
    .map((item) => String(item).trim().toLowerCase())

  if (kelasKeys.length === 0) {
    return false
  }

  return kelasKeys.some((key) => {
    return userIdentity.value.includes(key)
  })
}

function inferKelasDariRekap() {
  return riwayatPresensi.value
    .map((item) => ({
      id: item.kelas_id || item.id_kelas,
      nama: item.nama_kelas || item.mata_kuliah || item.kelas,
      dosen_id: item.dosen_id || item.id_dosen || item.pegawai_id || item.NIP,
      dosen_email: item.dosen_email || item.email_dosen,
      dosen_nama: item.nama_dosen || item.NAMA_PEGAWAI,
      status: item.status_kelas || '',
      jadwal: item.jadwal || item.waktu || '',
      ruang: item.ruang || item.ruangan || '',
    }))
    .filter((item) => item.id)
    .map(normalizeKelas)
}

function gabungKelas(listA, listB) {
  const map = new Map()

  ;[...listA, ...listB].forEach((item) => {
    const kelas = normalizeKelas(item)

    if (kelas.id) {
      map.set(String(kelas.id), {
        ...(map.get(String(kelas.id)) || {}),
        ...kelas,
      })
    }
  })

  return Array.from(map.values())
}

function makeQrImageFromToken(token) {
  return `https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=${encodeURIComponent(token)}`
}

function decodeHtmlEntities(text) {
  const textarea = document.createElement('textarea')
  textarea.innerHTML = text
  return textarea.value
}

function getQrValueFromResponse(data) {
  return (
    data?.qr_code ||
    data?.qrCode ||
    data?.qrcode ||
    data?.qr_url ||
    data?.qrCodeUrl ||
    data?.url ||
    data?.image ||
    data?.svg ||
    data?.data?.qr_code ||
    data?.data?.qrCode ||
    data?.data?.qrcode ||
    data?.data?.qr_url ||
    data?.data?.qrCodeUrl ||
    data?.data?.url ||
    data?.data?.image ||
    data?.data?.svg ||
    ''
  )
}

function getTokenFromResponse(data) {
  return (
    data?.token ||
    data?.qr_token ||
    data?.qrToken ||
    data?.data?.token ||
    data?.data?.qr_token ||
    data?.data?.qrToken ||
    ''
  )
}

function formatQrCode(qr) {
  if (!qr) return ''

  const API_BASE_URL = 'https://pegawai4c06.vps-poliban.my.id'

  let cleanQr = String(qr).trim()
  cleanQr = decodeHtmlEntities(cleanQr)

  if (cleanQr.includes('<svg')) {
    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(cleanQr)}`
  }

  if (cleanQr.startsWith('data:image')) return cleanQr
  if (cleanQr.startsWith('http')) return cleanQr
  if (cleanQr.startsWith('/')) return `${API_BASE_URL}${cleanQr}`

  if (
    cleanQr.startsWith('storage/') ||
    cleanQr.startsWith('uploads/') ||
    cleanQr.startsWith('qr/') ||
    cleanQr.startsWith('qrcode/') ||
    cleanQr.startsWith('qrcodes/')
  ) {
    return `${API_BASE_URL}/${cleanQr}`
  }

  if (cleanQr.startsWith('PHN2Zy') || cleanQr.startsWith('PD94bW')) {
    return `data:image/svg+xml;base64,${cleanQr}`
  }

  if (
    cleanQr.startsWith('iVBOR') ||
    cleanQr.startsWith('/9j/') ||
    cleanQr.startsWith('R0lGOD')
  ) {
    return `data:image/png;base64,${cleanQr}`
  }

  return makeQrImageFromToken(cleanQr)
}

function bukaQrModal(kelas) {
  if (!kelas?.qrCode) {
    setMessage('error', 'QR belum tersedia. Klik Generate QR terlebih dahulu.')
    return
  }

  qrModal.value = {
    show: true,
    nama: kelas.nama || 'Kelas',
    kelasId: kelas.id || '-',
    qrCode: kelas.qrCode,
  }
}

function tutupQrModal() {
  qrModal.value = {
    show: false,
    nama: '',
    kelasId: '',
    qrCode: '',
  }
}

function qrImageError() {
  setMessage('error', 'Gambar QR gagal dimuat. Cek koneksi internet atau format token QR.')
}

async function ambilKelasSaya() {
  loading.value = true
  setMessage('', '')

  try {
    const adminClasses = ambilSemuaKelasAdmin().filter(kelasMilikDosen)
    const inferredClasses = inferKelasDariRekap().filter(kelasMilikDosen)

    kelasSaya.value = gabungKelas(adminClasses, inferredClasses)

    if (kelasSaya.value.length === 0) {
      setMessage(
        'info',
        'Belum ada kelas untuk akun ini. Pastikan admin sudah memilih dosen pengampu yang sesuai.'
      )
    }
  } catch (e) {
    console.log('AMBIL KELAS DOSEN:', e)
    kelasSaya.value = []
    setMessage('error', 'Gagal mengambil data kelas dosen.')
  } finally {
    loading.value = false
  }
}

async function ambilRekapAbsensi(tampilkanPesan = false) {
  loading.value = true

  try {
    const response = await api.get(ENDPOINTS.absensi.rekap)

    const apiData = ambilArray(response).map((item, index) => {
      return normalizePresensi(item, index)
    })

    const localData = ambilRiwayatPresensiLokal()

    riwayatPresensi.value = gabungPresensi(apiData, localData)
  } catch (e) {
    console.log('REKAP ABSENSI:', e?.response?.data || e)

    riwayatPresensi.value = ambilRiwayatPresensiLokal()

    if (tampilkanPesan && riwayatPresensi.value.length === 0) {
      setMessage(
        'info',
        'Riwayat dari API belum bisa diambil, tetapi presensi tetap bisa disimpan.'
      )
    }
  } finally {
    loading.value = false
  }
}

function updateKelasLokal(kelasUpdate) {
  const semua = ambilSemuaKelasAdmin()

  const updated = semua.map((kelas) => {
    if (String(kelas.id) === String(kelasUpdate.id)) {
      return normalizeKelas({
        ...kelas,
        ...kelasUpdate,
      })
    }

    return kelas
  })

  simpanSemuaKelasAdmin(updated)

  kelasSaya.value = kelasSaya.value.map((kelas) => {
    if (String(kelas.id) === String(kelasUpdate.id)) {
      return normalizeKelas({
        ...kelas,
        ...kelasUpdate,
      })
    }

    return kelas
  })
}

async function generateQr(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan untuk membuat QR.')
    return
  }

  loading.value = true
  setMessage('', '')

  try {
    const response = await api.post(ENDPOINTS.qr.generate, {
      kelas_id: String(kelas.id),
    })

    const rawQr = getQrValueFromResponse(response.data)
    const token = getTokenFromResponse(response.data)
    const qrSource = rawQr || token

    if (!qrSource) {
      setMessage('error', 'QR dibuat, tetapi token QR tidak ditemukan di response API.')
      return
    }

    const qrCode = formatQrCode(qrSource)

    const updatedKelas = {
      ...kelas,
      qrCode,
      qrToken: token || rawQr,
    }

    updateKelasLokal(updatedKelas)

    qrModal.value = {
      show: true,
      nama: updatedKelas.nama || 'Kelas',
      kelasId: updatedKelas.id || '-',
      qrCode,
    }

    setMessage('success', response?.data?.message || 'QR berhasil dibuat.')
  } catch (e) {
    console.log('GENERATE QR ERROR:', e?.response?.data || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal membuat QR. Pastikan kelas sudah dimulai.')
    )
  } finally {
    loading.value = false
  }
}

async function startKelas(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan.')
    return
  }

  loading.value = true
  setMessage('', '')

  try {
    await api.post(ENDPOINTS.kelas.start, {
      kelas_id: String(kelas.id),
      keterangan: kelas.keterangan || '',
    })

    updateKelasLokal({
      ...kelas,
      status: 'berjalan',
    })

    setMessage('success', 'Kelas berhasil dimulai. QR sedang dibuat...')

    await generateQr({
      ...kelas,
      status: 'berjalan',
    })
  } catch (e) {
    console.log('START KELAS ERROR:', e?.response?.data || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal memulai kelas. Pastikan kelas_id benar dan milik akun dosen ini.')
    )
  } finally {
    loading.value = false
  }
}

async function endKelas(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan.')
    return
  }

  loading.value = true
  setMessage('', '')

  try {
    await api.post(ENDPOINTS.kelas.end, {
      kelas_id: String(kelas.id),
      keterangan: kelas.keterangan || '',
    })

    updateKelasLokal({
      ...kelas,
      status: 'selesai',
      qrCode: '',
      qrToken: '',
    })

    setMessage('success', 'Kelas berhasil diakhiri.')
  } catch (e) {
    console.log('END KELAS ERROR:', e?.response?.data || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal mengakhiri kelas.')
    )
  } finally {
    loading.value = false
  }
}

function tutupQr(kelas) {
  updateKelasLokal({
    ...kelas,
    qrCode: '',
    qrToken: '',
  })

  tutupQrModal()
}

async function simpanPresensiManualMahasiswa(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan.')
    return
  }

  if (!kelas.manual_status) {
    setMessage('error', 'Pilih status presensi mahasiswa terlebih dahulu.')
    return
  }

  loading.value = true
  setMessage('', '')

  try {
    const payload = {
      kelas_id: String(kelas.id),
      nim: kelas.manual_nim || '',
      nama: kelas.manual_nama || '',
      status: kelas.manual_status,
      keterangan: kelas.manual_keterangan || '',
    }

    const response = await api.post(ENDPOINTS.absensi.manual, payload)

    kelas.manual_nim = ''
    kelas.manual_nama = ''
    kelas.manual_status = ''
    kelas.manual_keterangan = ''

    updateKelasLokal(kelas)

    setMessage(
      'success',
      response?.data?.message || 'Presensi manual mahasiswa berhasil disimpan.'
    )
  } catch (e) {
    console.log('PRESENSI MANUAL MAHASISWA ERROR:', e?.response?.data || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal menyimpan presensi manual mahasiswa.')
    )
  } finally {
    loading.value = false
  }
}

async function simpanPresensiDosen() {
  if (!kelasId.value) {
    setMessage('error', 'Pilih kelas terlebih dahulu.')
    return
  }

  if (!statusPresensi.value) {
    setMessage('error', 'Pilih status presensi dosen terlebih dahulu.')
    return
  }

  loading.value = true
  setMessage('', '')

  try {
    const payload = {
      kelas_id: String(kelasId.value),
      status: statusPresensi.value,
      keterangan: keteranganPresensi.value || '',
    }

    const response = await api.post(ENDPOINTS.absensi.manual, payload)

    const presensiBaru = normalizePresensi({
      _key: `dosen-${Date.now()}`,
      tanggal: new Date().toLocaleDateString('id-ID'),
      created_at: new Date().toLocaleString('id-ID'),
      kelas_id: kelasId.value,
      nama_kelas: kelasDipilih.value?.nama || '-',
      status: statusPresensi.value,
      keterangan: keteranganPresensi.value || '',
    })

    riwayatPresensi.value.unshift(presensiBaru)

    simpanRiwayatPresensiLokal(riwayatPresensi.value)

    statusPresensi.value = ''
    keteranganPresensi.value = ''

    setMessage(
      'success',
      response?.data?.message || 'Presensi dosen berhasil disimpan.'
    )
  } catch (e) {
    console.log('PRESENSI DOSEN ERROR:', e?.response?.data || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal menyimpan presensi dosen.')
    )
  } finally {
    loading.value = false
  }
}

async function refreshData() {
  if (props.page === 'kelas') {
    await ambilKelasSaya()
    return
  }

  if (props.page === 'dashboard') {
    await ambilKelasSaya()
    await ambilRekapAbsensi(false)
    return
  }

  if (props.page === 'presensi') {
    await ambilKelasSaya()
    await ambilRekapAbsensi(false)
    return
  }
}

function logout() {
  localStorage.removeItem('simpadu_token')
  localStorage.removeItem('simpadu_user')
  localStorage.removeItem('simpadu_role')
  localStorage.removeItem('simpadu_logged_in')
  router.push('/')
}

async function loadData() {
  await refreshData()
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
.qr-btn {
  background: #2563eb;
  color: #ffffff;
}

.qr-btn:hover {
  background: #1d4ed8;
}

.qr-enabled-actions {
  grid-template-columns: repeat(3, 1fr);
}

.qr-preview-box {
  margin-top: 18px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  padding: 18px;
  text-align: center;
}

.qr-preview-box h4 {
  color: #0f172a;
  font-size: 16px;
  font-weight: 800;
  margin-bottom: 14px;
}

.open-qr-btn {
  width: 100%;
  border: none;
  background: #2563eb;
  color: #ffffff;
  padding: 12px;
  border-radius: 12px;
  font-weight: 800;
  cursor: pointer;
  margin-bottom: 10px;
}

.close-qr-btn {
  margin-top: 4px;
  width: 100%;
  border: none;
  background: #e2e8f0;
  color: #0f172a;
  padding: 12px;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
}

.qr-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 20px;
}

.qr-modal {
  position: relative;
  width: 100%;
  max-width: 420px;
  background: #ffffff;
  border-radius: 28px;
  padding: 30px;
  text-align: center;
  box-shadow: 0 30px 80px rgba(15, 23, 42, 0.35);
}

.qr-modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 50%;
  background: #f1f5f9;
  color: #0f172a;
  font-weight: 900;
  cursor: pointer;
}

.qr-modal-box {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 24px;
  padding: 22px;
  margin: 18px 0;
  min-height: 310px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.qr-modal-box img {
  width: 260px;
  height: 260px;
  object-fit: contain;
  background: #ffffff;
  padding: 14px;
  border-radius: 18px;
}

.qr-modal-note {
  font-weight: 700;
  color: #0f172a !important;
}

.manual-presensi-card {
  margin-top: 18px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  padding: 18px;
}

.manual-presensi-card h4 {
  color: #0f172a;
  font-size: 16px;
  font-weight: 900;
  margin-bottom: 6px;
}

.manual-presensi-card p {
  color: #64748b;
  font-size: 13px;
  margin-bottom: 14px;
}

.manual-presensi-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 12px;
  margin-bottom: 12px;
}

.manual-presensi-grid input,
.manual-presensi-grid select,
.manual-presensi-card textarea {
  width: 100%;
  border: 1px solid #dbe3ef;
  border-radius: 14px;
  padding: 12px 14px;
  font-size: 14px;
  outline: none;
  background: #ffffff;
}

.manual-presensi-card textarea {
  min-height: 80px;
  resize: none;
  margin-bottom: 12px;
}

.manual-presensi-btn {
  width: 100%;
  border: none;
  background: #0b3155;
  color: #ffffff;
  padding: 13px;
  border-radius: 14px;
  font-weight: 900;
  cursor: pointer;
}

.presensi-page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.presensi-page-header h2 {
  font-size: 28px;
  font-weight: 900;
  color: #06152b;
  margin-bottom: 6px;
}

.presensi-page-header p {
  color: #64748b;
  font-size: 15px;
}

.presensi-layout {
  display: grid;
  grid-template-columns: minmax(0, 1.4fr) minmax(320px, 0.8fr);
  gap: 22px;
  align-items: start;
}

.modern-presensi-card {
  background: #ffffff;
  border-radius: 28px;
  padding: 28px;
  box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
  border: 1px solid #eef2f7;
}

.presensi-icon {
  width: 58px;
  height: 58px;
  border-radius: 18px;
  background: #dcfce7;
  color: #16a34a;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  margin-bottom: 16px;
}

.presensi-subtitle {
  color: #64748b;
  margin-bottom: 18px;
}

.presensi-label {
  display: block;
  font-weight: 800;
  color: #0f172a;
  margin: 18px 0 8px;
}

.kelas-select,
.modern-presensi-card textarea {
  width: 100%;
  border: 1px solid #dbe3ef;
  border-radius: 16px;
  padding: 14px 16px;
  font-size: 15px;
  outline: none;
  background: #ffffff;
}

.modern-presensi-card textarea {
  min-height: 95px;
  resize: none;
}

.attendance-buttons {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
}

.attendance-buttons button {
  border: 1px solid #dbe3ef;
  background: #ffffff;
  border-radius: 18px;
  padding: 16px 10px;
  cursor: pointer;
  font-weight: 800;
  color: #0f172a;
  display: flex;
  flex-direction: column;
  gap: 6px;
  align-items: center;
}

.attendance-buttons button.active {
  background: #eff6ff;
  border-color: #2563eb;
  color: #1d4ed8;
}

.presensi-summary {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
  margin: 18px 0;
}

.presensi-summary div {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 14px;
  text-align: center;
}

.presensi-summary small {
  display: block;
  color: #64748b;
  font-size: 12px;
  margin-bottom: 6px;
}

.presensi-summary strong {
  color: #0f172a;
  font-size: 15px;
  text-transform: capitalize;
}

.save-presensi {
  width: 100%;
  border: none;
  background: #10b981;
  color: #ffffff;
  padding: 15px;
  border-radius: 16px;
  font-weight: 900;
  cursor: pointer;
  font-size: 15px;
}

.modern-history-card {
  border-radius: 28px;
  padding: 24px;
  box-shadow: 0 18px 45px rgba(15, 23, 42, 0.08);
  border: 1px solid #eef2f7;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  background: #f8fafc;
  border-radius: 16px;
  padding: 14px;
  margin-bottom: 10px;
}

.history-item strong {
  color: #0f172a;
  font-size: 14px;
}

.history-item p {
  color: #64748b;
  font-size: 12px;
  margin-top: 4px;
}

.empty-history {
  color: #64748b;
  text-align: center;
  padding: 24px 0;
}

@media (max-width: 1100px) {
  .presensi-layout {
    grid-template-columns: 1fr;
  }

  .attendance-buttons,
  .manual-presensi-grid,
  .presensi-summary,
  .qr-enabled-actions {
    grid-template-columns: 1fr;
  }

  .presensi-page-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>