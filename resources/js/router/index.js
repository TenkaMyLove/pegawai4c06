import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import AdminLayout from '../views/Admin.vue'
import DosenLayout from '../views/Dosen.vue'
import PegawaiLayout from '../views/Pegawai.vue'

const routes = [
  {
    path: '/',
    name: 'login',
    component: LoginView,
    meta: {
      public: true,
    },
  },

  // ADMIN
  {
    path: '/admin',
    redirect: '/admin/dashboard',
  },
  {
    path: '/admin/profil',
    component: AdminLayout,
    props: {
      page: 'profil',
    },
    meta: {
      role: 'admin',
    },
  },
  {
    path: '/admin/dashboard',
    component: AdminLayout,
    props: {
      page: 'dashboard',
    },
    meta: {
      role: 'admin',
    },
  },
  {
    path: '/admin/pegawai',
    component: AdminLayout,
    props: {
      page: 'pegawai',
    },
    meta: {
      role: 'admin',
    },
  },
  {
    path: '/admin/absensi',
    component: AdminLayout,
    props: {
      page: 'absensi',
    },
    meta: {
      role: 'admin',
    },
  },
  {
    path: '/admin/presensi',
    redirect: '/admin/absensi',
  },
  {
    path: '/admin/rekap',
    component: AdminLayout,
    props: {
      page: 'rekap',
    },
    meta: {
      role: 'admin',
    },
  },
  {
    path: '/admin/rekap-presensi',
    redirect: '/admin/rekap',
  },
  {
    path: '/admin/log',
    component: AdminLayout,
    props: {
      page: 'log',
    },
    meta: {
      role: 'admin',
    },
  },

  // DOSEN
  {
    path: '/dosen',
    redirect: '/dosen/dashboard',
  },
  {
    path: '/dosen/profil',
    component: DosenLayout,
    props: {
      page: 'profil',
    },
    meta: {
      role: 'dosen',
    },
  },
  {
    path: '/dosen/dashboard',
    component: DosenLayout,
    props: {
      page: 'dashboard',
    },
    meta: {
      role: 'dosen',
    },
  },
  {
    path: '/dosen/kelas',
    component: DosenLayout,
    props: {
      page: 'kelas',
    },
    meta: {
      role: 'dosen',
    },
  },
  {
    path: '/dosen/input-nilai',
    component: DosenLayout,
    props: {
      page: 'nilai',
    },
    meta: {
      role: 'dosen',
    },
  },
  {
    path: '/dosen/presensi',
    component: DosenLayout,
    props: {
      page: 'presensi',
    },
    meta: {
      role: 'dosen',
    },
  },

  // PEGAWAI
  {
    path: '/pegawai',
    redirect: '/pegawai/profil',
  },
  {
    path: '/pegawai/profil',
    component: PegawaiLayout,
    props: {
      page: 'profil',
    },
    meta: {
      role: 'pegawai',
    },
  },
  {
    path: '/pegawai/presensi',
    component: PegawaiLayout,
    props: {
      page: 'presensi',
    },
    meta: {
      role: 'pegawai',
    },
  },

  // FALLBACK
  {
    path: '/:pathMatch(.*)*',
    redirect: '/',
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  if (to.meta.public) return true

  const loggedIn = localStorage.getItem('simpadu_logged_in') === 'true'
  const role = localStorage.getItem('simpadu_role')
  const token = localStorage.getItem('simpadu_token')

  if (!loggedIn || !token) {
    localStorage.removeItem('simpadu_logged_in')
    localStorage.removeItem('simpadu_role')
    localStorage.removeItem('simpadu_user')
    localStorage.removeItem('simpadu_token')
    return '/'
  }

  if (to.meta.role && role && to.meta.role !== role) {
    if (role === 'admin') return '/admin/dashboard'
    if (role === 'dosen') return '/dosen/dashboard'
    if (role === 'pegawai') return '/pegawai/profil'

    return '/'
  }

  return true
})

export default router