<template>
  <div class="dashboard-layout">
    <aside class="side-nav">
      <div class="mini-brand">
        <img src="../assets/images/logo-poliban.png" alt="Logo" />
        <div>
          <h3>Simpadu</h3>
          <span>Admin Akademik Digital</span>
        </div>
      </div>

      <nav>
        <RouterLink to="/admin/dashboard" class="menu-item">
          🏠 <span>Dashboard</span>
        </RouterLink>

        <RouterLink to="/admin/pegawai" class="menu-item">
          👥 <span>Manajemen Dosen</span>
        </RouterLink>

        <RouterLink to="/admin/kelas" class="menu-item">
          📚 <span>Manajemen Kelas</span>
        </RouterLink>

        <RouterLink to="/admin/absensi" class="menu-item">
          📋 <span>Absensi Dosen</span>
        </RouterLink>

        <RouterLink to="/admin/log" class="menu-item">
          🕒 <span>Log Aktivitas</span>
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

      <!-- DASHBOARD ADMIN -->
      <section v-if="page === 'dashboard'" class="page-section">
        <div class="welcome-card">
          <h2>Selamat Datang, {{ userName }}</h2>
          <p>
            Kelola data dosen, kelas, dan rekap absensi
          </p>
        </div>

        <div class="stats-row three">
          <div class="metric-card">
            <small>Total Dosen</small>
            <strong>{{ dosen.length }}</strong>
          </div>

          <div class="metric-card green-text">
            <small>Total Kelas</small>
            <strong>{{ kelas.length }}</strong>
          </div>

          <div class="metric-card orange-text">
            <small>Total Rekap Absensi</small>
            <strong>{{ absensi.length }}</strong>
          </div>
        </div>

        <div class="split-grid">
          <article class="white-card">
            <h3>Dosen Terbaru</h3>

            <div
              v-for="item in dosen.slice(0, 5)"
              :key="item.id"
              class="schedule-item"
            >
              <b>{{ item.nip || item.id || '-' }}</b>
              <span>{{ item.nama }}</span>
              <em>{{ item.status || item.jabatan || 'Aktif' }}</em>
            </div>

            <p v-if="dosen.length === 0 && !loading">
              Belum ada data dosen
            </p>
          </article>

          <article class="white-card">
            <h3>Kelas Terbaru</h3>

            <div
              v-for="item in kelas.slice(0, 5)"
              :key="item._key"
              class="schedule-item"
            >
              <b>{{ item.id }}</b>
              <span>{{ item.nama }}</span>
              <em>{{ item.dosen_nama || item.dosen_email || 'Belum ada dosen' }}</em>
            </div>

            <p v-if="kelas.length === 0">
              Belum ada kelas. Tambahkan melalui menu Manajemen Kelas.
            </p>
          </article>
        </div>
      </section>

      <!-- MANAJEMEN DOSEN -->
      <section v-else-if="page === 'pegawai'" class="page-section">
        <div class="content-header">
          <h2>Manajemen Data Dosen</h2>
          <button class="yellow-btn" @click="bukaFormTambah">
            + Tambah Dosen
          </button>
        </div>

        <div v-if="showForm" class="form-card">
          <h3>{{ editingId ? 'Edit Dosen' : 'Tambah Dosen' }}</h3>

          <div class="form-grid">
            <input v-model="form.nama" placeholder="Nama lengkap" />
            <input v-model="form.email" placeholder="Email" />
            <input v-model="form.nip" placeholder="NIP" />
            <input v-model="form.jabatan" placeholder="Jabatan" />
            <input v-model="form.unit_kerja" placeholder="Unit kerja" />

            <select v-model="form.status">
              <option value="Aktif">Aktif</option>
              <option value="Non Aktif">Non Aktif</option>
            </select>
          </div>

          <div class="form-actions">
            <button class="save-btn" :disabled="loading" @click="simpanDosen">
              Simpan
            </button>
            <button class="cancel-btn" @click="resetForm">
              Batal
            </button>
          </div>
        </div>

        <div class="filter-bar single">
          <input
            v-model="search"
            placeholder="Cari nama, email, NIP, atau jabatan"
          />
        </div>

        <div class="table-card">
          <table>
            <thead>
              <tr>
                <th>NIP</th>
                <th>Nama Lengkap</th>
                <th>Email</th>
                <th>Jabatan</th>
                <th>Unit Kerja</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="item in filteredDosen" :key="item.id">
                <td>{{ item.nip || '-' }}</td>
                <td>{{ item.nama || '-' }}</td>
                <td>{{ item.email || '-' }}</td>
                <td>{{ item.jabatan || '-' }}</td>
                <td>{{ item.unit_kerja || item.unit || '-' }}</td>
                <td>
                  <span
                    :class="[
                      'pill',
                      normalizeStatus(item.status) === 'non aktif'
                        ? 'danger'
                        : 'ok'
                    ]"
                  >
                    {{ item.status || 'Aktif' }}
                  </span>
                </td>
                <td>
                  <button class="icon-btn" @click="editDosen(item)">✏️</button>
                  <button class="icon-btn red" @click="hapusDosen(item)">🗑️</button>
                </td>
              </tr>
            </tbody>
          </table>

          <p v-if="filteredDosen.length === 0 && !loading" class="empty-table">
            Tidak ada data dosen.
          </p>
        </div>
      </section>

      <!-- MANAJEMEN KELAS -->
      <section v-else-if="page === 'kelas'" class="page-section">
        <div class="content-header">
          <div>
            <h2>Manajemen Kelas</h2>
            <p class="muted">
              Admin menambahkan kelas dan menentukan dosen yang boleh mengakses kelas tersebut.
            </p>
          </div>

          <button class="yellow-btn" @click="bukaFormKelas">
            + Tambah Kelas
          </button>
        </div>

        <div v-if="showKelasForm" class="form-card class-admin-form">
          <h3>{{ editingKelasId ? 'Edit Kelas' : 'Tambah Kelas' }}</h3>

          <div class="form-grid">
            <input
              v-model="kelasForm.id"
              :disabled="!!editingKelasId"
              type="text"
              placeholder="ID kelas, contoh: TIK01"
            />

            <input
              v-model="kelasForm.nama"
              type="text"
              placeholder="Nama kelas / mata kuliah"
            />

            <input
              v-model="kelasForm.semester"
              type="text"
              placeholder="Semester"
            />

            <input
              v-model="kelasForm.sks"
              type="text"
              placeholder="SKS"
            />

            <input
              v-model="kelasForm.ruang"
              type="text"
              placeholder="Ruangan"
            />

            <input
              v-model="kelasForm.jadwal"
              type="text"
              placeholder="Jadwal / waktu"
            />

            <input
              v-model="kelasForm.jumlah_mahasiswa"
              type="text"
              placeholder="Jumlah mahasiswa"
            />

            <select v-model="kelasForm.dosen_key" @change="pilihDosenUntukKelas">
              <option value="">Pilih dosen pengampu</option>

              <option
                v-for="item in dosen"
                :key="item.id"
                :value="item.id"
              >
                {{ item.nama }} — {{ item.email || item.nip || item.id }}
              </option>
            </select>
          </div>

          <div class="form-actions">
            <button class="save-btn" :disabled="loading" @click="simpanKelas">
              Simpan Kelas
            </button>

            <button class="cancel-btn" @click="resetFormKelas">
              Batal
            </button>
          </div>
        </div>

        <div class="filter-bar single">
          <input
            v-model="searchKelas"
            placeholder="Cari ID kelas, nama kelas, atau dosen"
          />
        </div>

        <div class="table-card">
          <table>
            <thead>
              <tr>
                <th>ID Kelas</th>
                <th>Nama Kelas</th>
                <th>Dosen Pengampu</th>
                <th>Semester</th>
                <th>SKS</th>
                <th>Ruangan</th>
                <th>Jadwal</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="item in filteredKelas" :key="item._key">
                <td>{{ item.id }}</td>
                <td>{{ item.nama }}</td>
                <td>{{ item.dosen_nama || item.dosen_email || '-' }}</td>
                <td>{{ item.semester || '-' }}</td>
                <td>{{ item.sks || '-' }}</td>
                <td>{{ item.ruang || '-' }}</td>
                <td>{{ item.jadwal || '-' }}</td>
                <td>
                  <span
                    :class="[
                      'pill',
                      item.status === 'berjalan'
                        ? 'ok'
                        : item.status === 'selesai'
                          ? 'warn'
                          : 'info'
                    ]"
                  >
                    {{ item.status || 'tersedia' }}
                  </span>
                </td>
                <td>
                  <button class="icon-btn" @click="editKelas(item)">✏️</button>
                  <button class="icon-btn red" @click="hapusKelas(item)">🗑️</button>
                </td>
              </tr>
            </tbody>
          </table>

          <p v-if="filteredKelas.length === 0 && !loading" class="empty-table">
            Belum ada kelas. Tambahkan kelas agar dosen bisa memulai kelas dan membuat QR.
          </p>
        </div>
      </section>

      <!-- LOG -->
      <section v-else-if="page === 'log'" class="page-section narrow">
        <h2>Log Aktivitas</h2>

        <div class="activity-card">
          <div v-for="log in logs" :key="log.id" class="activity-item">
            <div class="activity-icon">{{ log.icon }}</div>
            <div>
              <strong>{{ log.title }}</strong>
              <p>{{ log.text }}</p>
            </div>
            <small>{{ log.time }}</small>
          </div>

          <p v-if="logs.length === 0">
            Belum ada aktivitas pada sesi ini.
          </p>
        </div>
      </section>

      <!-- ABSENSI -->
      <section v-else class="page-section">
        <div class="content-header">
          <h2>Absensi Dosen</h2>
          <button class="yellow-btn" @click="ambilAbsensi">
            Refresh
          </button>
        </div>

        <div class="stats-row three">
          <div class="metric-card green-text">
            <strong>{{ totalHadir }}</strong>
            <small>Hadir</small>
          </div>

          <div class="metric-card orange-text">
            <strong>{{ totalIzinSakit }}</strong>
            <small>Izin / Sakit</small>
          </div>

          <div class="metric-card red-text">
            <strong>{{ totalTidakHadir }}</strong>
            <small>Tidak Hadir</small>
          </div>
        </div>

        <div class="table-card">
          <table>
            <thead>
              <tr>
                <th>Tanggal</th>
                <th>Nama Dosen</th>
                <th>Kelas / Mata Kuliah</th>
                <th>Jam Datang</th>
                <th>Jam Pulang</th>
                <th>Status</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="row in absensi" :key="row._key">
                <td>{{ row.tanggal || row.created_at || '-' }}</td>
                <td>{{ row.nama_dosen || row.dosen || row.nama || '-' }}</td>
                <td>{{ row.mata_kuliah || row.nama_kelas || row.kelas || '-' }}</td>
                <td>{{ row.jam_datang || row.datang || '-' }}</td>
                <td>{{ row.jam_pulang || row.pulang || '-' }}</td>
                <td>
                  <span :class="['pill', pillClass(row.status)]">
                    {{ row.status || '-' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>

          <p v-if="absensi.length === 0 && !loading" class="empty-table">
            Belum ada data absensi.
          </p>
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
  page: String,
})

const router = useRouter()

const loading = ref(false)
const message = ref({
  type: '',
  text: '',
})

const user = ref(JSON.parse(localStorage.getItem('simpadu_user') || '{}'))

const dosen = ref([])
const absensi = ref([])
const logs = ref([])

const search = ref('')
const searchKelas = ref('')

const showForm = ref(false)
const editingId = ref(null)

const form = ref({
  nama: '',
  email: '',
  nip: '',
  jabatan: '',
  unit_kerja: '',
  status: 'Aktif',
})

const kelas = ref([])
const showKelasForm = ref(false)
const editingKelasId = ref(null)

const kelasForm = ref({
  id: '',
  nama: '',
  semester: '',
  sks: '',
  ruang: '',
  jadwal: '',
  jumlah_mahasiswa: '',
  dosen_key: '',
  dosen_id: '',
  dosen_email: '',
  dosen_nama: '',
  status: 'tersedia',
})

const adminKelasKey = 'simpadu_admin_kelas'

const title = computed(() => {
  return {
    dashboard: 'Dashboard Admin',
    pegawai: 'Manajemen Dosen',
    kelas: 'Manajemen Kelas',
    absensi: 'Absensi Admin',
    log: 'Log Aktivitas',
  }[props.page]
})

const userName = computed(() => {
  return user.value.nama || user.value.name || user.value.email || 'Admin'
})

const userInitial = computed(() => {
  return userName.value.charAt(0).toUpperCase()
})

const filteredDosen = computed(() => {
  const keyword = search.value.toLowerCase()

  if (!keyword) {
    return dosen.value
  }

  return dosen.value.filter((item) => {
    return JSON.stringify(item).toLowerCase().includes(keyword)
  })
})

const filteredKelas = computed(() => {
  const keyword = searchKelas.value.toLowerCase()

  if (!keyword) {
    return kelas.value
  }

  return kelas.value.filter((item) => {
    return JSON.stringify(item).toLowerCase().includes(keyword)
  })
})

const totalHadir = computed(() => {
  return absensi.value.filter((item) => {
    return normalizeStatus(item.status) === 'hadir'
  }).length
})

const totalIzinSakit = computed(() => {
  return absensi.value.filter((item) => {
    return ['izin', 'sakit'].includes(normalizeStatus(item.status))
  }).length
})

const totalTidakHadir = computed(() => {
  return absensi.value.filter((item) => {
    return ['tidak_hadir', 'tidak hadir', 'alpha'].includes(normalizeStatus(item.status))
  }).length
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

function displayName(item) {
  return (
    item?.NAMA_PEGAWAI ||
    item?.nama_pegawai ||
    item?.nama ||
    item?.name ||
    item?.nama_lengkap ||
    item?.nama_dosen ||
    item?.full_name ||
    item?.username ||
    item?.email ||
    item?.EMAIL ||
    item?.NIP ||
    item?.nip ||
    item?.NIDN ||
    item?.nidn ||
    item?.user?.nama ||
    item?.user?.name ||
    item?.user?.email ||
    item?.pegawai?.nama ||
    item?.pegawai?.name ||
    item?.pegawai?.email ||
    'Nama dosen tidak tersedia'
  )
}

function getId(item) {
  return (
    item?.id ||
    item?.ID ||
    item?.dosen_id ||
    item?.DOSEN_ID ||
    item?.pegawai_id ||
    item?.PEGAWAI_ID ||
    item?.user_id ||
    item?.USER_ID ||
    item?.id_dosen ||
    item?.ID_DOSEN ||
    item?.id_pegawai ||
    item?.ID_PEGAWAI ||
    item?.NIP ||
    item?.nip ||
    item?.NIDN ||
    item?.nidn ||
    item?.email ||
    item?.EMAIL ||
    item?.user?.id ||
    item?.pegawai?.id ||
    ''
  )
}

function normalizeDosen(item) {
  const id = getId(item)
  const nama = displayName(item)

  return {
    ...item,
    id,
    nama,
    email:
      item?.email ||
      item?.user?.email ||
      item?.pegawai?.email ||
      '',
    nip:
      item?.nip ||
      item?.nidn ||
      item?.pegawai?.nip ||
      item?.pegawai?.nidn ||
      '',
    jabatan:
      item?.jabatan ||
      item?.role ||
      item?.posisi ||
      item?.pegawai?.jabatan ||
      '',
    unit_kerja:
      item?.unit_kerja ||
      item?.unit ||
      item?.pegawai?.unit_kerja ||
      item?.pegawai?.unit ||
      '',
    status:
      item?.status ||
      item?.pegawai?.status ||
      'Aktif',
  }
}

function apiMessage(error, fallback) {
  return (
    error?.response?.data?.message ||
    error?.response?.data?.error ||
    fallback
  )
}

function ambilArray(response) {
  const data = response?.data?.data || response?.data || []

  if (Array.isArray(data)) return data
  if (Array.isArray(data.dosen)) return data.dosen
  if (Array.isArray(data.pegawai)) return data.pegawai
  if (Array.isArray(data.absensi)) return data.absensi
  if (Array.isArray(data.rekap)) return data.rekap

  return []
}

function tambahLog(icon, title, text) {
  logs.value.unshift({
    id: Date.now(),
    icon,
    title,
    text,
    time: new Date().toLocaleString('id-ID'),
  })
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
    ruang: item.ruang || item.ruangan || '',
    dosen_id: String(
      item.dosen_id ||
        item.id_dosen ||
        item.pegawai_id ||
        ''
    ).trim(),
    dosen_email: item.dosen_email || item.email_dosen || '',
    dosen_nama: item.dosen_nama || item.nama_dosen || '',
    status: item.status || 'tersedia',
  }
}

function ambilKelasLokal() {
  try {
    return JSON.parse(localStorage.getItem(adminKelasKey) || '[]').map(normalizeKelas)
  } catch {
    return []
  }
}

function simpanKelasLokal(list) {
  localStorage.setItem(
    adminKelasKey,
    JSON.stringify(list.map(normalizeKelas))
  )
}

function pilihDosenUntukKelas() {
  const selected = dosen.value.find((item) => {
    return String(item.id) === String(kelasForm.value.dosen_key)
  })

  if (!selected) {
    kelasForm.value.dosen_id = ''
    kelasForm.value.dosen_email = ''
    kelasForm.value.dosen_nama = ''
    return
  }

  kelasForm.value.dosen_id = String(selected.id)
  kelasForm.value.dosen_email = selected.email || ''
  kelasForm.value.dosen_nama = selected.nama || displayName(selected)
}

async function ambilDosen() {
  loading.value = true
  setMessage('', '')

  try {
    const response = await api.get(ENDPOINTS.dosen.all)

    console.log('DATA DOSEN API:', response.data)

    dosen.value = ambilArray(response)
      .map(normalizeDosen)
      .filter((item) => item.id)

    if (dosen.value.length === 0) {
      setMessage(
        'info',
        'Data dosen berhasil diambil, tetapi tidak ada data yang memiliki NIP atau ID.'
      )
    }
  } catch (e) {
    console.log('AMBIL DOSEN:', e?.response || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal mengambil data dosen dari API.')
    )

    dosen.value = []
  } finally {
    loading.value = false
  }
}

async function ambilAbsensi() {
  loading.value = true
  setMessage('', '')

  try {
    const response = await api.get(ENDPOINTS.absensi.rekap)

    absensi.value = ambilArray(response).map((item, index) => ({
      ...item,
      _key: item.id || `${item.tanggal || item.created_at || 'absensi'}-${index}`,
    }))
  } catch (e) {
    console.log('AMBIL ABSENSI:', e?.response || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal mengambil data absensi dari API.')
    )

    absensi.value = []
  } finally {
    loading.value = false
  }
}

function ambilKelasAdmin() {
  kelas.value = ambilKelasLokal()
}

function bukaFormTambah() {
  editingId.value = null

  form.value = {
    nama: '',
    email: '',
    nip: '',
    jabatan: '',
    unit_kerja: '',
    status: 'Aktif',
  }

  showForm.value = true
}

function editDosen(item) {
  editingId.value = item.id

  form.value = {
    nama: item.nama || '',
    email: item.email || '',
    nip: item.nip || '',
    jabatan: item.jabatan || '',
    unit_kerja: item.unit_kerja || item.unit || '',
    status: item.status || 'Aktif',
  }

  showForm.value = true
}

function resetForm() {
  showForm.value = false
  editingId.value = null
}

async function simpanDosen() {
  loading.value = true
  setMessage('', '')

  try {
    if (editingId.value) {
      await api.put(ENDPOINTS.dosen.edit(editingId.value), form.value)

      tambahLog(
        '✏️',
        userName.value,
        `Mengedit dosen ${form.value.nama || form.value.email}`
      )

      setMessage('success', 'Data dosen berhasil diperbarui.')
    } else {
      await api.post(ENDPOINTS.dosen.tambah, form.value)

      tambahLog(
        '➕',
        userName.value,
        `Menambahkan dosen ${form.value.nama || form.value.email}`
      )

      setMessage('success', 'Data dosen berhasil ditambahkan.')
    }

    resetForm()
    await ambilDosen()
  } catch (e) {
    console.log('SIMPAN DOSEN:', e?.response || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal menyimpan data dosen.')
    )
  } finally {
    loading.value = false
  }
}

async function hapusDosen(item) {
  const id = item.id

  if (!id) {
    setMessage('error', 'ID dosen tidak ditemukan.')
    return
  }

  if (!confirm(`Hapus data ${item.nama}?`)) return

  loading.value = true
  setMessage('', '')

  try {
    await api.delete(ENDPOINTS.dosen.hapus(id))

    tambahLog('🗑️', userName.value, `Menghapus dosen ${item.nama}`)

    setMessage('success', 'Data dosen berhasil dihapus.')

    await ambilDosen()
  } catch (e) {
    console.log('HAPUS DOSEN:', e?.response || e)

    setMessage(
      'error',
      apiMessage(e, 'Gagal menghapus data dosen.')
    )
  } finally {
    loading.value = false
  }
}

function bukaFormKelas() {
  editingKelasId.value = null

  kelasForm.value = {
    id: '',
    nama: '',
    semester: '',
    sks: '',
    ruang: '',
    jadwal: '',
    jumlah_mahasiswa: '',
    dosen_key: '',
    dosen_id: '',
    dosen_email: '',
    dosen_nama: '',
    status: 'tersedia',
  }

  showKelasForm.value = true
}

function editKelas(item) {
  const kelasItem = normalizeKelas(item)

  editingKelasId.value = kelasItem.id

  kelasForm.value = {
    id: kelasItem.id,
    nama: kelasItem.nama,
    semester: kelasItem.semester || '',
    sks: kelasItem.sks || '',
    ruang: kelasItem.ruang || '',
    jadwal: kelasItem.jadwal || kelasItem.waktu || '',
    jumlah_mahasiswa:
      kelasItem.jumlah_mahasiswa ||
      kelasItem.total_mahasiswa ||
      '',
    dosen_key:
      kelasItem.dosen_id ||
      kelasItem.dosen_email ||
      '',
    dosen_id: kelasItem.dosen_id || '',
    dosen_email: kelasItem.dosen_email || '',
    dosen_nama: kelasItem.dosen_nama || '',
    status: kelasItem.status || 'tersedia',
  }

  showKelasForm.value = true
}

function resetFormKelas() {
  showKelasForm.value = false
  editingKelasId.value = null
}

function simpanKelas() {
  if (!kelasForm.value.id || !kelasForm.value.nama) {
    setMessage('error', 'ID kelas dan nama kelas wajib diisi.')
    return
  }

  if (!kelasForm.value.dosen_id && !kelasForm.value.dosen_email) {
    setMessage('error', 'Pilih dosen pengampu terlebih dahulu.')
    return
  }

  const data = normalizeKelas({
    ...kelasForm.value,
  })

  const list = ambilKelasLokal()

  const exists = list.some((item) => {
    return String(item.id) === String(data.id)
  })

  let updated = []

  if (editingKelasId.value) {
    updated = list.map((item) => {
      return String(item.id) === String(editingKelasId.value)
        ? normalizeKelas({
            ...item,
            ...data,
          })
        : item
    })

    tambahLog('✏️', userName.value, `Mengedit kelas ${data.nama}`)

    setMessage('success', 'Kelas berhasil diperbarui.')
  } else {
    if (exists) {
      setMessage('error', 'ID kelas sudah ada.')
      return
    }

    updated = [...list, data]

    tambahLog('➕', userName.value, `Menambahkan kelas ${data.nama}`)

    setMessage('success', 'Kelas berhasil ditambahkan.')
  }

  simpanKelasLokal(updated)
  kelas.value = ambilKelasLokal()
  resetFormKelas()
}

function hapusKelas(item) {
  if (!confirm(`Hapus kelas ${item.nama}?`)) return

  const updated = ambilKelasLokal().filter((kelasItem) => {
    return String(kelasItem.id) !== String(item.id)
  })

  simpanKelasLokal(updated)

  kelas.value = ambilKelasLokal()

  tambahLog('🗑️', userName.value, `Menghapus kelas ${item.nama}`)

  setMessage('success', 'Kelas berhasil dihapus.')
}

function logout() {
  localStorage.removeItem('simpadu_token')
  localStorage.removeItem('simpadu_user')
  localStorage.removeItem('simpadu_role')
  localStorage.removeItem('simpadu_logged_in')
  router.push('/')
}

async function loadData() {
  if (props.page === 'dashboard') {
    ambilKelasAdmin()
    await Promise.all([
      ambilDosen(),
      ambilAbsensi(),
    ])
  }

  if (props.page === 'pegawai') {
    await ambilDosen()
  }

  if (props.page === 'kelas') {
    ambilKelasAdmin()

    if (dosen.value.length === 0) {
      await ambilDosen()
    }
  }

  if (props.page === 'absensi') {
    await ambilAbsensi()
  }
}

onMounted(loadData)

watch(
  () => props.page,
  () => {
    loadData()
  }
)
</script>