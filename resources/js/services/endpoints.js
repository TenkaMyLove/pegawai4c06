const ENDPOINTS = {
  auth: {
    login: '/api/login',
    loginAdmin: '/api/login',
    loginDosen: '/api/login',
    loginPegawai: '/api/login',
  },

  pegawai: {
    all: '/api/pegawai',
    public: '/api/pegawai',
    profile: '/api/pegawai/profile',
    updateProfile: '/api/pegawai/profile',
    byId: (id) => `/api/pegawai/${id}`,
    tambah: '/api/pegawai',
    edit: (id) => `/api/pegawai/${id}`,
    hapus: (id) => `/api/pegawai/${id}`,
  },

  dosen: {
    all: '/api/dosen',
    byId: (id) => `/api/dosen/${id}`,
    tambah: '/api/dosen',
    edit: (id) => `/api/dosen/${id}`,
    hapus: (id) => `/api/dosen/${id}`,

    // Sesuai Postman
    uploadMateri: '/api/materi',
    uploadTugas: '/api/tugas',
  },

  dashboard: {
    pegawai: '/api/dashboard/pegawai',
    dosen: '/api/dashboard/pegawai',
    profile: '/api/pegawai/profile',
    jadwalMengajar: '/api/jadwal-mengajar',
    activityLogs: '/api/admin/activity-logs',
  },

  kelas: {
    list: '/api/jadwal-mengajar',
    start: '/api/kelas/start',
    end: '/api/kelas/end',
  },

  qr: {
    generate: '/api/qr/generate',
    scan: '/api/qr/scan',
    testScan: '/api/qr/scan',
  },

  nilai: {
    index: '/api/nilai',
    store: '/api/nilai',
    settings: '/api/nilai/settings',
  },

  absensi: {
    // Absensi mahasiswa
    manual: '/api/absensi/manual',
    rekap: '/api/absensi/rekap',

    adminManual: '/api/absensi/manual',
    adminRekap: '/api/absensi/rekap',
    admin: {
      manual: '/api/absensi/manual',
      rekap: '/api/absensi/rekap',
    },

    // Absensi pegawai/dosen sebagai pegawai
    pegawaiMasuk: '/api/pegawai/absensi/masuk',
    pegawaiKeluar: '/api/pegawai/absensi/keluar',
    pegawaiHariIni: '/api/pegawai/absensi/hari-ini',
    pegawaiRekap: '/api/pegawai/absensi/rekap',

    // Alias untuk halaman dosen
    dosenMasuk: '/api/pegawai/absensi/masuk',
    dosenPulang: '/api/pegawai/absensi/keluar',
    dosenHariIni: '/api/pegawai/absensi/hari-ini',
    rekapDosen: '/api/pegawai/absensi/rekap',
  },

  rekapPresensi: {
    semua: '/api/absensi/rekap',
    pegawai: '/api/pegawai/absensi/rekap',
    dosen: '/api/pegawai/absensi/rekap',
  },
}

export default ENDPOINTS
