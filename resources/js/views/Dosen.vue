<template>
  <div class="dashboard-layout">
    <aside class="side-nav">
      <RouterLink to="/dosen/dashboard" class="mini-brand">
        <img :src="logoUrl" alt="Logo" />
        <div>
          <h3>Simpadu</h3>
          <span>Dosen Akademik Digital</span>
        </div>
      </RouterLink>

      <nav>
        <RouterLink to="/dosen/dashboard" class="menu-item">
          🏠 <span>Home</span>
        </RouterLink>

        <RouterLink to="/dosen/kelas" class="menu-item">
          💻 <span>Jadwal Mengajar</span>
        </RouterLink>

        <RouterLink to="/dosen/input-nilai" class="menu-item">
          🎓 <span>Input Nilai</span>
        </RouterLink>

        <RouterLink to="/dosen/presensi" class="menu-item">
          🖥️ <span>Presensi Saya</span>
        </RouterLink>

        <RouterLink to="/dosen/validasi-krs" class="menu-item">
          📋 <span>Validasi KRS</span>
        </RouterLink>
      </nav>

      <RouterLink to="/dosen/profil" class="user-chip">
        <div class="avatar">{{ userInitial }}</div>
        <div>
          <strong>{{ userName }}</strong>
          <small>Klik untuk profil</small>
        </div>
      </RouterLink>

      <button class="logout-btn" @click="logout">
        Keluar
      </button>
    </aside>

    <main class="workspace">
      <header class="workspace-top">
        <div>
          <h1>{{ title }}</h1>
        </div>

        <div class="top-actions">
          <button
            type="button"
            class="refresh-btn"
            :disabled="loading"
            @click="refreshData"
          >
            {{ loading ? 'Memuat...' : 'Refresh Data' }}
          </button>
        </div>
      </header>

      <div v-if="message.text" :class="['app-message', message.type]">
        {{ message.text }}
      </div>

      <p v-if="loading" class="loading-text">
        Memuat data...
      </p>

      <!-- PROFIL DOSEN -->
      <section v-if="page === 'profil'" class="page-section profile-page">
        <div class="profile-hero-card">
          <div class="profile-avatar">{{ userInitial }}</div>

          <div>
            <p class="eyebrow">Profil Dosen</p>
            <h2>{{ userProfile.nama }}</h2>
            <p class="profile-role-text">{{ userProfile.jabatan || 'Dosen' }}</p>

            <div class="profile-meta">
              <span>Email: <b>{{ userProfile.email || '-' }}</b></span>
              <span>NIP/NIDN: <b>{{ userProfile.nip || '-' }}</b></span>
            </div>
          </div>
        </div>

        <form class="profile-form-card" @submit.prevent="saveProfile">
          <h3>Data Profil</h3>

          <div class="form-grid">
            <label>
              <span>Nama Lengkap</span>
              <input v-model="profileForm.nama" type="text" placeholder="Nama lengkap" readonly />
            </label>

            <label>
              <span>Email</span>
              <input v-model="profileForm.email" type="email" placeholder="Email" />
            </label>

            <label>
              <span>NIP / NIDN</span>
              <input v-model="profileForm.nip" type="text" placeholder="NIP atau NIDN" readonly />
            </label>

            <label>
              <span>Jabatan</span>
              <input v-model="profileForm.jabatan" type="text" placeholder="Jabatan" readonly />
            </label>

            <label class="full">
              <span>Alamat</span>
              <textarea v-model="profileForm.alamat" placeholder="Alamat lengkap"></textarea>
            </label>
          </div>

          <div class="form-actions">
            <button class="primary-btn" type="submit">
              Simpan Profil
            </button>
          </div>
        </form>
      </section>

      <!-- DASHBOARD -->
      <section v-else-if="page === 'dashboard'" class="page-section">
        <div class="welcome-card">
          <h2>Selamat Datang, {{ userName }}</h2>
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

            <p v-if="kelasSaya.length === 0 && !loading" class="empty-history">
              Belum ada kelas yang tersedia.
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

            <p v-if="riwayatPresensi.length === 0 && !loading" class="empty-history">
              Belum ada data presensi.
            </p>
          </article>
        </div>
      </section>

      <!-- JADWAL MENGAJAR -->
      <section v-else-if="page === 'kelas'" class="page-section">
        <div v-if="!selectedKelasDetail" class="kelas-header">
          <div>
            <h2>Jadwal Mengajar</h2>
          </div>

          <button class="refresh-btn" type="button" @click="refreshData">
            Refresh Data
          </button>
        </div>

        <!-- DAFTAR KELAS -->
        <div v-if="!selectedKelasDetail && kelasSaya.length > 0" class="kelas-grid kelas-grid-clean">
          <article
            v-for="kelas in kelasSaya"
            :key="kelas._key"
            class="kelas-card kelas-card-clickable"
            @click="bukaDetailKelas(kelas)"
          >
            <div class="kelas-card-top">
              <div class="kelas-icon">📚</div>

              <span :class="['kelas-status', { active: kelas.status === 'berjalan' || kelas.status === 'aktif' }]">
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
                <strong>{{ jumlahPesertaKelas(kelas) }}</strong>
              </div>
            </div>

            <div class="kelas-open-row">
              <span>Buka detail kelas</span>
              <b>→</b>
            </div>
          </article>
        </div>

        <!-- HALAMAN DETAIL KELAS -->
        <div v-else-if="selectedKelasDetail" class="kelas-detail-page">
          <button class="back-to-classes" type="button" @click="kembaliKeDaftarKelas">
            ← Kembali ke daftar kelas
          </button>

          <div class="kelas-detail-hero">
            <div>
              <p class="eyebrow">Detail Kelas</p>
              <h2>{{ selectedKelasDetail.nama }}</h2>
              <span>ID Kelas: {{ selectedKelasDetail.id }}</span>
            </div>

            <span :class="['kelas-status', { active: selectedKelasDetail.status === 'berjalan' || selectedKelasDetail.status === 'aktif' }]">
              {{ selectedKelasDetail.status || 'Tersedia' }}
            </span>
          </div>

          <!-- UPLOAD MATERI & TUGAS (PINDAH KE ATAS) -->
          <section class="detail-card" style="margin-bottom: 22px;">
            <div class="detail-card-head">
              <div>
                <h3>Upload Materi & Tugas</h3>
                <p>Unggah file untuk kelas ini.</p>
              </div>
            </div>

            <div class="kelas-upload-grid">
              <div class="upload-card">
                <div>
                  <h4>Upload Materi</h4>
                  <p>Unggah materi pembelajaran.</p>
                </div>

                <input type="file" @change="pilihFileMateri(selectedKelasDetail, $event)" />

                <button
                  type="button"
                  class="upload-btn"
                  :disabled="loading || !selectedKelasDetail.materi_file"
                  @click="uploadMateriKelas(selectedKelasDetail)"
                >
                  {{ loading ? 'Mengupload...' : 'Upload Materi' }}
                </button>

                <div v-if="selectedKelasDetail.materi_list && selectedKelasDetail.materi_list.length" class="upload-list">
                  <span
                    v-for="materi in selectedKelasDetail.materi_list"
                    :key="materi._key"
                  >
                    📄 {{ materi.nama }}
                  </span>
                </div>
              </div>

              <div class="upload-card">
                <div>
                  <h4>Upload Tugas</h4>
                  <p>Unggah tugas mahasiswa.</p>
                </div>

                <input type="file" @change="pilihFileTugas(selectedKelasDetail, $event)" />

                <button
                  type="button"
                  class="upload-btn"
                  :disabled="loading || !selectedKelasDetail.tugas_file"
                  @click="uploadTugasKelas(selectedKelasDetail)"
                >
                  {{ loading ? 'Mengupload...' : 'Upload Tugas' }}
                </button>

                <div v-if="selectedKelasDetail.tugas_list && selectedKelasDetail.tugas_list.length" class="upload-list">
                  <span
                    v-for="tugas in selectedKelasDetail.tugas_list"
                    :key="tugas._key"
                  >
                    📝 {{ tugas.nama }}
                  </span>
                </div>
              </div>
            </div>
          </section>

          <div class="kelas-detail-summary">
            <div>
              <small>Semester</small>
              <strong>{{ selectedKelasDetail.semester || '-' }}</strong>
            </div>

            <div>
              <small>SKS</small>
              <strong>{{ selectedKelasDetail.sks || '-' }}</strong>
            </div>

            <div>
              <small>Mahasiswa</small>
              <strong>{{ jumlahPesertaKelas(selectedKelasDetail) }}</strong>
            </div>

            <div>
              <small>Ruangan</small>
              <strong>{{ selectedKelasDetail.ruang || selectedKelasDetail.ruangan || '-' }}</strong>
            </div>
          </div>

          <div class="kelas-detail-layout" style="align-items: stretch;">
            <div class="detail-main-column">
              <section class="detail-card">
                <div class="detail-card-head">
                  <div>
                    <h3>Informasi Kelas</h3>
                    <p>Data jadwal dan dosen mata kuliah.</p>
                  </div>
                </div>

                <div class="kelas-detail-list">
                  <p>
                    <span>⏰</span>
                    Jadwal:
                    <b>{{ selectedKelasDetail.jadwal || selectedKelasDetail.jam || selectedKelasDetail.waktu || '-' }}</b>
                  </p>

                  <p>
                    <span>👨‍🏫</span>
                    Dosen Mata Kuliah:
                    <b>{{ namaDosenKelas(selectedKelasDetail) }}</b>
                  </p>
                </div>

                <div class="kelas-actions detail-actions">
                  <button
                    class="start-btn"
                    type="button"
                    :disabled="loading"
                    @click="startKelas(selectedKelasDetail)"
                  >
                    ▶ Mulai Kelas
                  </button>

                  <button
                    class="end-btn"
                    type="button"
                    :disabled="loading"
                    @click="endKelas(selectedKelasDetail)"
                  >
                    ⏹ Akhiri Kelas
                  </button>
                </div>
              </section>

              <section class="detail-card">
                <div class="detail-card-head">
                  <div>
                    <h3>Presensi Kelas</h3>
                    <p>Gunakan QR untuk presensi, atau input manual jika mahasiswa tidak bisa scan.</p>
                    <div class="meeting-selector-row" style="margin: 12px 0 0; display: flex; align-items: center; gap: 8px;">
                      <label style="font-weight: 700; font-size: 13px; color: #475569;">Pertemuan Ke:</label>
                      <select v-model="pertemuanKe" @change="fetchRoster(selectedKelasDetail)" style="padding: 6px 10px; border-radius: 10px; border: 1.4px solid #cbd5e1; background: #fff; font-weight: 800; color: #1e293b; font-size: 13px; cursor: pointer;">
                        <option v-for="n in 16" :key="n" :value="n">Pertemuan {{ n }}</option>
                      </select>
                    </div>
                  </div>

                  <button
                    v-if="selectedKelasDetail.qrCode"
                    class="qr-demo-btn detail-qr-btn"
                    type="button"
                    @click="bukaQrModal(selectedKelasDetail)"
                  >
                    🔳 Lihat QR
                  </button>
                </div>

                <div v-if="selectedKelasDetail.qrCode" class="qr-preview-card">
                  <img :src="selectedKelasDetail.qrCode" alt="QR Presensi" @error="qrImageError" />
                  <div>
                    <strong>QR Presensi Aktif</strong>
                    <p>Mahasiswa dapat melakukan scan QR untuk presensi kelas ini.</p>
                  </div>
                </div>

                <div v-else class="qr-empty-card">
                  <strong>QR belum dibuat</strong>
                  <p>Klik tombol Mulai Kelas untuk membuat QR presensi.</p>
                </div>
              </section>
            </div>

            <div class="detail-side-column" style="display: flex; flex-direction: column; height: 100%;">
              <!-- PRESENSI MANUAL MAHASISWA (PINDAH KE KANAN) -->
              <section class="detail-card" style="flex: 1; display: flex; flex-direction: column; margin: 0;">
                <div class="detail-card-head">
                  <div>
                    <h3>Presensi Manual</h3>
                    <p>Pilih status presensi mahasiswa (H, S, I, A) untuk pertemuan ke-{{ pertemuanKe }}.</p>
                  </div>
                </div>

                <div class="manual-mobile-card" style="border: 0; padding: 0; box-shadow: none; margin: 0; display: flex; flex-direction: column; flex: 1; min-height: 0;">
                  <div class="manual-mobile-head" style="padding: 0 0 12px 0; flex-shrink: 0;">
                    <h4>Daftar Mahasiswa</h4>
                    <span>{{ jumlahPesertaKelas(selectedKelasDetail) }} Mahasiswa</span>
                  </div>

                  <div class="manual-scroll-list" style="max-height: 320px; overflow-y: auto; padding-right: 6px; margin-bottom: 12px;">
                    <div
                      v-for="peserta in selectedKelasDetail.peserta"
                      :key="peserta._key"
                      class="manual-student-row"
                    >
                      <div class="manual-student-info">
                        <strong>{{ peserta.nama }}</strong>
                        <small>{{ peserta.nim || peserta.id || '-' }}</small>
                      </div>

                      <div class="manual-status-row">
                        <button
                          v-for="opsi in manualStatusOptions"
                          :key="opsi.value"
                          type="button"
                          :class="['manual-status-pill', opsi.className, { active: statusManualPeserta(peserta) === opsi.value }]"
                          @click="setStatusPresensiManual(selectedKelasDetail, peserta, opsi.value)"
                        >
                          {{ opsi.label }}
                        </button>
                      </div>
                    </div>

                    <p v-if="!selectedKelasDetail.peserta || selectedKelasDetail.peserta.length === 0" class="manual-empty-text">
                      Belum ada mahasiswa di kelas ini.
                    </p>
                  </div>

                  <div class="manual-mobile-footer" style="padding-left: 0; padding-right: 0; padding-bottom: 0; flex-shrink: 0;">
                    <button
                      class="manual-save-mobile-btn"
                      type="button"
                      :disabled="loading || !selectedKelasDetail.peserta || selectedKelasDetail.peserta.length === 0"
                      @click="simpanPresensiManualMahasiswa(selectedKelasDetail)"
                    >
                      💾 {{ loading ? 'Menyimpan...' : 'Simpan Presensi Manual' }}
                    </button>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </div>

        <div v-else-if="!loading" class="empty-kelas">
          <div>📭</div>
          <h3>Belum ada kelas</h3>
          <p>Minta admin menambahkan kelas untuk akun dosen ini.</p>
        </div>
      </section>

            <!-- INPUT NILAI -->
      <section v-else-if="page === 'nilai'" class="page-section">
        <div class="content-header">
          <div>
            <h2>Input Nilai Mahasiswa</h2>

          </div>

          <button class="refresh-btn" type="button" @click="refreshData">
            Refresh Data
          </button>
        </div>

        <div class="nilai-layout">
          <div class="white-card nilai-form-card">
            <h3>Form Input Nilai</h3>

            <div class="nilai-id-grid">
              <label>
                <span>ID Kelas</span>
                <input :value="NILAI_ID_KELAS" type="text" disabled />
              </label>

              <label>
                <span>ID MK</span>
                <input :value="NILAI_ID_MK" type="text" disabled />
              </label>
            </div>

            <label class="nilai-label">Pilih Mahasiswa</label>
            <select v-model="nilaiForm.nim" class="nilai-input" @change="pilihMahasiswaNilai">
              <option value="">Pilih mahasiswa</option>
              <option
                v-for="peserta in pesertaNilai"
                :key="peserta._key"
                :value="peserta.nim"
              >
                {{ peserta.nama }} — {{ peserta.nim || '-' }}
              </option>
            </select>

            <div class="nilai-grid">
              <label>
                <span>NIM</span>
                <input v-model="nilaiForm.nim" type="text" placeholder="NIM mahasiswa" readonly />
              </label>

              <label>
                <span>Nama Mahasiswa</span>
                <input v-model="nilaiForm.nama" type="text" placeholder="Nama mahasiswa" readonly />
              </label>

              <label>
                <span>Partisipasi</span>
                <input v-model.number="nilaiForm.participation_score" type="number" min="0" max="100" placeholder="0-100" />
              </label>

              <label>
                <span>Tugas</span>
                <input v-model.number="nilaiForm.assignment_score" type="number" min="0" max="100" placeholder="0-100" />
              </label>

              <label>
                <span>Quiz</span>
                <input v-model.number="nilaiForm.quiz_score" type="number" min="0" max="100" placeholder="0-100" />
              </label>

              <label>
                <span>UTS</span>
                <input v-model.number="nilaiForm.uts_score" type="number" min="0" max="100" placeholder="0-100" />
              </label>

              <label>
                <span>UAS</span>
                <input v-model.number="nilaiForm.uas_score" type="number" min="0" max="100" placeholder="0-100" />
              </label>

              <label>
                <span>Final Score</span>
                <input :value="nilaiAkhir" type="text" disabled />
              </label>

              <label>
                <span>Grade</span>
                <input :value="gradeNilai || '-'" type="text" disabled />
              </label>
            </div>

            <button
              class="save-nilai-btn"
              type="button"
              :disabled="loading"
              @click="simpanNilaiMahasiswa"
            >
              {{ loading ? 'Menyimpan...' : 'Simpan Nilai Mahasiswa' }}
            </button>
          </div>

          <div class="white-card nilai-list-card">
            <h3>Daftar Nilai</h3>

            <div class="nilai-list-scroll">
              <div
                v-for="item in daftarNilai"
                :key="item._key"
                class="nilai-item nilai-item-full"
              >
                <div class="nilai-info">
                  <strong>{{ item.nama || '-' }}</strong>
                  <p>
                    {{ item.nim || '-' }} · id_kelas {{ item.id_kelas || NILAI_ID_KELAS }} · id_mk {{ item.id_mk || NILAI_ID_MK }}
                  </p>
                </div>

                <div class="nilai-breakdown nilai-breakdown-five">
                  <div>
                    <small>Partisipasi</small>
                    <b>{{ item.participation_score ?? 0 }}</b>
                  </div>

                  <div>
                    <small>Tugas</small>
                    <b>{{ item.assignment_score ?? 0 }}</b>
                  </div>

                  <div>
                    <small>Quiz</small>
                    <b>{{ item.quiz_score ?? 0 }}</b>
                  </div>

                  <div>
                    <small>UTS</small>
                    <b>{{ item.uts_score ?? 0 }}</b>
                  </div>

                  <div>
                    <small>UAS</small>
                    <b>{{ item.uas_score ?? 0 }}</b>
                  </div>
                </div>

                <div class="nilai-score nilai-score-grade">
                  <small>Grade</small>
                  <b>{{ item.grade || '-' }}</b>
                  <span>Final {{ item.final_score ?? '-' }}</span>
                </div>
              </div>

              <p v-if="daftarNilai.length === 0 && !loading" class="empty-history">
                Belum ada nilai yang diinput.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- PRESENSI DOSEN -->
      <section v-if="page === 'presensi'" class="dashboard-card presensi-page">
        <div class="presensi-layout">
          <div class="white-card presensi-panel modern-presensi-card">
                        <h2>Presensi Harian</h2>

            <div class="daily-presensi-info">
              <div>
                <small>Tanggal</small>
                <strong>{{ new Date().toLocaleDateString('id-ID') }}</strong>
              </div>
              <div>
                <small>Nama</small>
                <strong>{{ userName }}</strong>
              </div>
            </div>

            <!-- Mode seperti admin pegawai: Datang / Pulang -->
            <div class="presensi-mode-toggle">
              <button
                type="button"
                :class="['mode-btn', modePresensi === 'masuk' ? 'active' : '']"
                @click="modePresensi = 'masuk'"
              >
                Datang
              </button>
              <button
                type="button"
                :class="['mode-btn', modePresensi === 'pulang' ? 'active' : '']"
                @click="modePresensi = 'pulang'"
                :disabled="!presensiHariIni || !presensiHariIni.waktu_masuk"
                title="Presensi pulang aktif setelah presensi datang"
              >
                Pulang
              </button>
            </div>

            <div class="today-status">
              <div class="today-row">
                <span class="today-label">Jam Datang</span>
                <strong class="today-value">{{ presensiHariIni?.waktu_masuk || '-' }}</strong>
              </div>
              <div class="today-row">
                <span class="today-label">Jam Pulang</span>
                <strong class="today-value">{{ presensiHariIni?.waktu_keluar || '-' }}</strong>
              </div>
            </div>

            <button
              class="save-presensi"
              type="button"
              :disabled="loading || !isWeekday || (modePresensi === 'pulang' && (!presensiHariIni || !presensiHariIni.waktu_masuk))"
              @click="simpanPresensiDosen"
            >
              {{
                loading
                  ? 'Menyimpan...'
                  : !isWeekday
                    ? 'Presensi'
                    : modePresensi === 'masuk'
                      ? '✅ Presensi Datang'
                      : '✅ Presensi Pulang'
              }}
            </button>

            <p v-if="!isWeekday" class="hint">
              Presensi hanya bisa dilakukan pada hari kerja
            </p>
          </div>

          <div class="white-card history-card modern-history-card">
            <h3>Riwayat Presensi</h3>

            <div v-if="riwayatPresensi.length" class="history-list">
              <div
                v-for="item in riwayatPresensi"
                :key="item._key"
                class="history-item"
              >
                <div class="history-main">
                  <strong>{{ item.tanggal || '-' }}</strong>
                  <p class="history-sub">
                    Datang: <span>{{ item.waktu_masuk || '-' }}</span>
                    · Pulang: <span>{{ item.waktu_keluar || '-' }}</span>
                  </p>
                </div>

                <span class="pill ok" v-if="item.waktu_masuk && item.waktu_keluar">Lengkap</span>
                <span class="pill warn" v-else-if="item.waktu_masuk && !item.waktu_keluar">Belum pulang</span>
                <span class="pill danger" v-else>-</span>
              </div>
            </div>

            <p v-else-if="!loading" class="empty-history">
              Belum ada riwayat presensi.
            </p>
          </div>
        </div>
      </section>

      <!-- VALIDASI KRS -->
      <section v-else-if="page === 'validasi-krs'" class="page-section krs-page">
        <!-- DETIL KRS MAHASISWA -->
        <div v-if="selectedKrs" class="krs-detail-view">
          <button class="back-to-krs" type="button" @click="closeKrsDetail">
            ← Kembali ke daftar KRS
          </button>

          <div class="krs-detail-hero">
            <div class="krs-hero-main">
              <div class="avatar-large">{{ selectedKrs.nim.charAt(selectedKrs.nim.length - 1) }}</div>
              <div>
                <p class="krs-eyebrow">Rencana Studi Mahasiswa</p>
                <h2>{{ getStudentName(selectedKrs.nim) }}</h2>
                <p class="krs-sub">NIM: <b>{{ selectedKrs.nim }}</b> &middot; Kelas: <b>{{ selectedKrs.nama_kelas }}</b></p>
              </div>
            </div>

            <div class="krs-status-badge-container">
              <span :class="['krs-status-badge', getKrsStatus(selectedKrs).toLowerCase().replace(/\s+/g, '-')]">
                {{ getKrsStatus(selectedKrs) }}
              </span>
            </div>
          </div>

          <div class="krs-detail-layout">
            <!-- Left Column - Courses Table -->
            <div class="krs-main-col">
              <div class="krs-card">
                <div class="krs-card-head">
                  <h3>Mata Kuliah Yang Diambil</h3>
                  <p>Daftar mata kuliah yang diajukan oleh mahasiswa untuk Semester {{ selectedKrs.semester }}.</p>
                </div>

                <div class="krs-table-wrapper">
                  <table class="krs-table">
                    <thead>
                      <tr>
                        <th>Kode MK</th>
                        <th>Nama Mata Kuliah</th>
                        <th class="text-center">SKS</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="mk in selectedKrs.mata_kuliahs" :key="mk.id_mk">
                        <td><code>{{ mk.id_mk }}</code></td>
                        <td class="font-semibold">{{ mk.nama_mk }}</td>
                        <td class="text-center font-bold">{{ mk.sks }} SKS</td>
                      </tr>
                    </tbody>
                    <tfoot>
                      <tr>
                        <td colspan="2" class="text-right"><b>Total SKS Diajukan:</b></td>
                        <td class="text-center total-sks"><b>{{ calculateTotalSks(selectedKrs) }} SKS</b></td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
              </div>
            </div>

            <!-- Right Column - Actions -->
            <div class="krs-side-col">
              <div class="krs-card krs-action-card">
                <h3>Persetujuan Akademik</h3>
                <p>Silakan tinjau data rencana studi di samping sebelum melakukan validasi.</p>

                <div class="krs-action-status-box">
                  <small>Status Saat Ini</small>
                  <strong>{{ getKrsStatus(selectedKrs) }}</strong>
                </div>

                <div class="krs-action-buttons">
                  <button 
                    class="krs-btn approve-btn" 
                    type="button" 
                    :disabled="loading || getKrsStatus(selectedKrs) === 'Disetujui'"
                    @click="updateKrsStatus(selectedKrs.id_krs, 'Disetujui')"
                  >
                    Setujui KRS
                  </button>
                  
                  <button 
                    class="krs-btn reject-btn" 
                    type="button" 
                    :disabled="loading || getKrsStatus(selectedKrs) === 'Ditolak'"
                    @click="updateKrsStatus(selectedKrs.id_krs, 'Ditolak')"
                  >
                    Tolak KRS
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- DAFTAR KRS -->
        <div v-else>
          <div class="krs-filter-row">
            <div class="search-box">
              <span>🔍</span>
              <input 
                v-model="krsSearchQuery" 
                type="text" 
                placeholder="Cari berdasarkan NIM atau Kelas..." 
              />
            </div>
            
            <button class="krs-refresh-btn" type="button" :disabled="krsLoading" @click="loadKrsData">
              {{ krsLoading ? 'Memuat...' : 'Refresh Data' }}
            </button>
          </div>

          <div v-if="krsLoading" class="krs-loading-state">
            <div class="spinner"></div>
            <p>Memuat data KRS mahasiswa...</p>
          </div>

          <div v-else-if="krsList.length === 0" class="krs-empty-state">
            <div class="empty-icon">📂</div>
            <h3>Tidak ada pengajuan KRS</h3>
            <p>Belum ada data rencana studi mahasiswa yang diajukan.</p>
          </div>

          <div v-else class="krs-grid">
            <div 
              v-for="krs in krsList.filter(item => !krsSearchQuery || item.nim.toLowerCase().includes(krsSearchQuery.toLowerCase()) || item.nama_kelas.toLowerCase().includes(krsSearchQuery.toLowerCase()))"
              :key="krs.id_krs"
              class="krs-card-item"
              @click="viewKrsDetail(krs.id_krs)"
            >
              <div class="krs-card-top">
                <div class="avatar-small">{{ krs.nim.charAt(krs.nim.length - 1) }}</div>
                <span :class="['krs-status-badge', getKrsStatus(krs).toLowerCase().replace(/\s+/g, '-')]">
                  {{ getKrsStatus(krs) }}
                </span>
              </div>

              <h3 class="student-name">{{ getStudentName(krs.nim) }}</h3>
              <p class="student-nim">NIM: {{ krs.nim }}</p>

              <div class="krs-meta-grid">
                <div>
                  <small>Kelas</small>
                  <strong>{{ krs.nama_kelas }}</strong>
                </div>
                <div>
                  <small>Semester</small>
                  <strong>{{ krs.semester }}</strong>
                </div>
                <div>
                  <small>Total SKS</small>
                  <strong>{{ calculateTotalSks(krs) }} SKS</strong>
                </div>
              </div>

              <div class="krs-card-footer">
                <span>Buka Detail KRS</span>
                <span class="arrow">→</span>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>

    <div v-if="qrModal.show" class="qr-modal-overlay" @click.self="tutupQrModal">
      <div class="qr-modal">
        <button class="qr-modal-close" type="button" @click="tutupQrModal">
          ✕
        </button>

        <h2>QR Presensi</h2>

        <p>{{ qrModal.nama }} — ID {{ qrModal.kelasId }}</p>

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
const logoUrl = '/assets/images/logo-poliban.png'
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../services/api'
import ENDPOINTS from '../services/endpoints'

const router = useRouter()

const props = defineProps({
  page: {
    type: String,
    default: 'dashboard',
  },
})

// Pastikan konten halaman mengikuti route aktif, sehingga 'Presensi Saya' tidak muncul di menu lain
const route = useRoute()
const page = computed(() => {
  const path = String(route.path || '')
  const seg = path.split('/')[2] || ''
  const key = seg || props.page || 'dashboard'
  // Normalisasi beberapa alias rute
  if (key === 'home') return 'dashboard'
  if (key === 'profil') return 'profil'
  if (key === 'kelas') return 'kelas'
  if (key === 'input-nilai') return 'nilai'
  if (key === 'nilai') return 'nilai'
  if (key === 'presensi') return 'presensi'
  if (key === 'dashboard') return 'dashboard'
  if (key === 'validasi-krs') return 'validasi-krs'
  return key
})

const loading = ref(false)
const message = ref({
  type: '',
  text: '',
})

function getStoredUser() {
  try {
    return JSON.parse(localStorage.getItem('simpadu_user') || '{}')
  } catch {
    return {}
  }
}

const user = ref(getStoredUser())

const profileForm = ref({
  nama: '',
  email: '',
  nip: '',
  jabatan: 'Dosen',
  alamat: '',
})

const kelasSaya = ref([])
const riwayatPresensi = ref([])
const daftarNilai = ref([])

const kelasId = ref('')
const statusPresensi = ref('H')
const keteranganPresensi = ref('')
const modePresensi = ref('masuk')

const isWeekday = computed(() => {
  const day = new Date().getDay()
  return day !== 0 && day !== 6
})
const presensiHariIni = ref(null)
const selectedKelasId = ref('')
const pertemuanKe = ref(1)

const NILAI_ID_KELAS = '1'
const NILAI_ID_MK = '1'

const NILAI_MAHASISWA_DEFAULT = [
  {
    nim: 'C001',
    nama: 'Budi',
    participation_score: 0,
    assignment_score: 0,
    quiz_score: 0,
    uts_score: 0,
    uas_score: 0,
    final_score: 0,
    grade: null,
  },
  {
    nim: 'C002',
    nama: 'Dessy',
    participation_score: 0,
    assignment_score: 0,
    quiz_score: 0,
    uts_score: 0,
    uas_score: 0,
    final_score: 0,
    grade: null,
  },
  {
    nim: 'C003',
    nama: 'Zaky',
    participation_score: 0,
    assignment_score: 0,
    quiz_score: 0,
    uts_score: 0,
    uas_score: 0,
    final_score: 0,
    grade: null,
  },
  {
    nim: 'C005',
    nama: 'Rahmat',
    participation_score: 0,
    assignment_score: 0,
    quiz_score: 0,
    uts_score: 0,
    uas_score: 0,
    final_score: 0,
    grade: null,
  },
  {
    nim: 'C006',
    nama: 'Halimah',
    participation_score: 0,
    assignment_score: 0,
    quiz_score: 0,
    uts_score: 0,
    uas_score: 0,
    final_score: 0,
    grade: null,
  },
]

const nilaiForm = ref({
  id_kelas: NILAI_ID_KELAS,
  id_mk: NILAI_ID_MK,
  nim: '',
  nama: '',
  participation_score: '',
  assignment_score: '',
  quiz_score: '',
  uts_score: '',
  uas_score: '',
})

const qrModal = ref({
  show: false,
  nama: '',
  kelasId: '',
  qrCode: '',
})

const adminKelasKey = 'simpadu_admin_kelas'

function asArray(value) {
  if (!value) return []
  if (Array.isArray(value)) return value
  if (typeof value === 'object') return [value]
  return []
}

function pickFirst(...values) {
  for (const value of values) {
    if (value === null || value === undefined) continue
    if (typeof value === 'string' && value.trim()) return value.trim()
    if (typeof value === 'number' && String(value).trim()) return String(value)
  }
  return ''
}

function formatJabatan(value) {
  if (!value) return 'Dosen'

  if (typeof value === 'string') {
    const clean = value.trim()
    if (!clean || clean === '[object Object]') return 'Dosen'
    return clean
  }

  if (Array.isArray(value)) {
    const names = value
      .map((item) => formatJabatan(item))
      .filter(Boolean)
      .filter((item) => item !== 'Dosen')

    return names.length ? [...new Set(names)].join(', ') : 'Dosen'
  }

  if (typeof value === 'object') {
    return pickFirst(
      value.nama_jabatan,
      value.NAMA_JABATAN,
      value.jabatan,
      value.nama,
      value.name,
      value.pivot?.nama_jabatan,
      value.pivot?.NAMA_JABATAN
    ) || 'Dosen'
  }

  return 'Dosen'
}

function getNestedProfile() {
  const stored = user.value || {}
  const nestedUser = stored.user || {}
  const pegawai = stored.pegawai || stored.data?.pegawai || {}
  const dosen = stored.dosen || stored.data?.dosen || {}

  return {
    stored,
    nestedUser,
    pegawai,
    dosen,
  }
}

function getCleanProfile() {
  const { stored, nestedUser, pegawai, dosen } = getNestedProfile()
  const jabatanSource =
    stored.jabatan ||
    pegawai.jabatan ||
    dosen.jabatan ||
    nestedUser.jabatan ||
    stored.posisi ||
    pegawai.posisi ||
    dosen.posisi

  return {
    nama: pickFirst(
      stored.NAMA_PEGAWAI,
      stored.nama_pegawai,
      dosen.nama_dosen,
      dosen.NAMA_DOSEN,
      pegawai.nama_pegawai,
      pegawai.NAMA_PEGAWAI,
      stored.nama,
      stored.name,
      nestedUser.name,
      nestedUser.nama,
      stored.email,
      stored.EMAIL
    ) || 'Dosen',
    email: pickFirst(
      stored.email,
      stored.EMAIL,
      nestedUser.email,
      nestedUser.EMAIL,
      dosen.email,
      dosen.EMAIL
    ),
    nip: pickFirst(
      stored.nip,
      stored.NIP,
      pegawai.nip,
      pegawai.NIP,
      dosen.nip,
      dosen.NIP,
      dosen.nidn,
      dosen.NIDN,
      dosen.nip_baru,
      stored.nidn,
      stored.NIDN,
      stored.username
    ),
    jabatan: formatJabatan(jabatanSource),
    alamat: pickFirst(
      stored.alamat,
      stored.ALAMAT,
      pegawai.alamat,
      pegawai.ALAMAT,
      dosen.alamat,
      dosen.ALAMAT
    ),
  }
}

const title = computed(() => {
  return {
    profil: 'Profil Saya',
    dashboard: 'Home',
    kelas: 'Jadwal Mengajar',
    nilai: 'Input Nilai',
    presensi: 'Presensi Saya',
    'validasi-krs': 'Validasi KRS',
  }[props.page] || 'Home'
})

const userName = computed(() => {
  return getCleanProfile().nama || 'Dosen'
})

const userProfile = computed(() => {
  const clean = getCleanProfile()

  return {
    nama: profileForm.value.nama || clean.nama || userName.value,
    email: profileForm.value.email || clean.email || '',
    nip: profileForm.value.nip || clean.nip || '',
    jabatan: formatJabatan(profileForm.value.jabatan || clean.jabatan),
    alamat: profileForm.value.alamat || clean.alamat || '',
  }
})

const userInitial = computed(() => {
  return String(userName.value || 'D').charAt(0).toUpperCase()
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

const kelasDipilih = computed(() => {
  return kelasSaya.value.find((kelas) => String(kelas.id) === String(kelasId.value))
})

const selectedKelasDetail = computed(() => {
  return kelasSaya.value.find((kelas) => {
    return String(kelas.id || kelas._key) === String(selectedKelasId.value)
  }) || null
})

const kelasNilaiDipilih = computed(() => {
  return kelasSaya.value.find((kelas) => String(kelas.id) === String(nilaiForm.value.id_kelas))
})

const pesertaNilai = computed(() => {
  const pesertaDariKelas = Array.isArray(kelasNilaiDipilih.value?.peserta)
    ? kelasNilaiDipilih.value.peserta
    : []

  const peserta = pesertaDariKelas.length > 0
    ? pesertaDariKelas
    : NILAI_MAHASISWA_DEFAULT

  return peserta.map((item, index) => ({
    ...item,
    _key: item._key || item.nim || `nilai-peserta-${index}`,
    nim: item.nim || item.NIM || '',
    nama: item.nama || item.nama_mahasiswa || item.name || `Mahasiswa ${index + 1}`,
    participation_score: Number(item.participation_score || 0),
    assignment_score: Number(item.assignment_score || 0),
    quiz_score: Number(item.quiz_score || 0),
    uts_score: Number(item.uts_score || 0),
    uas_score: Number(item.uas_score || 0),
    final_score: Number(item.final_score || 0),
    grade: item.grade || null,
  }))
})

const nilaiAkhir = computed(() => {
  const partisipasi = Number(nilaiForm.value.participation_score || 0)
  const tugas = Number(nilaiForm.value.assignment_score || 0)
  const quiz = Number(nilaiForm.value.quiz_score || 0)
  const uts = Number(nilaiForm.value.uts_score || 0)
  const uas = Number(nilaiForm.value.uas_score || 0)

  if (!partisipasi && !tugas && !quiz && !uts && !uas) return ''

  const finalScore =
    (partisipasi * 0.1) +
    (tugas * 0.2) +
    (quiz * 0.1) +
    (uts * 0.3) +
    (uas * 0.3)

  return Number(finalScore.toFixed(2))
})

const gradeNilai = computed(() => hitungGrade(nilaiAkhir.value))

function hitungGrade(score) {
  const nilai = Number(score || 0)

  if (!nilai) return ''
  if (nilai >= 91) return 'A'
  if (nilai >= 80) return 'AB'
  if (nilai >= 75) return 'B'
  if (nilai >= 65) return 'BC'
  if (nilai >= 55) return 'C'
  if (nilai >= 45) return 'D'

  return 'E'
}

function getDosenId() {
  return Number(
    user.value.id_dosen ||
      user.value.dosen_id ||
      user.value.DOSEN_ID ||
      user.value.id ||
      user.value.ID ||
      user.value.pegawai_id ||
      user.value.PEGAWAI_ID ||
      1
  )
}

function getIdMkFromKelas(kelas) {
  return String(
    kelas?.id_mk ||
      kelas?.mk_id ||
      kelas?.kode_mk ||
      kelas?.mata_kuliah_id ||
      kelas?.id_matkul ||
      kelas?.kode_matkul ||
      kelas?.id ||
      ''
  ).trim()
}

function getApiIdKelas(kelas) {
  return String(
    kelas?.id_kelas ||
      kelas?.kelas_id ||
      kelas?.id ||
      NILAI_ID_KELAS
  ).trim()
}

function getApiIdMk(kelas) {
  return String(
    kelas?.id_mk ||
      kelas?.mk_id ||
      kelas?.mata_kuliah_id ||
      kelas?.id_matkul ||
      NILAI_ID_MK
  ).trim()
}

function getApiKodePertemuan(kelas) {
  return Number(
    kelas?.kode_pertemuan ||
      kelas?.id_kelas_session ||
      kelas?.kelas_session_id ||
      kelas?.session_id ||
      kelas?.pertemuan ||
      1
  )
}

function getFileBaseName(file, fallback) {
  const name = String(file?.name || fallback || '').trim()
  return name.replace(/\.[^/.]+$/, '') || fallback
}

const totalHadir = computed(() => {
  return riwayatPresensi.value.filter((item) => ['hadir', 'h'].includes(normalizeStatus(item.status))).length
})

const totalIzinSakit = computed(() => {
  return riwayatPresensi.value.filter((item) => {
    return ['izin', 'sakit', 'i', 's'].includes(normalizeStatus(item.status))
  }).length
})

const totalTidakHadir = computed(() => {
  return riwayatPresensi.value.filter((item) => {
    return ['tidak_hadir', 'tidak hadir', 'alpha', 'alpa', 'a'].includes(normalizeStatus(item.status))
  }).length
})

const presensiLocalKey = computed(() => {
  return `simpadu_presensi_dosen_${userIdentity.value[0] || 'dosen'}`
})

const nilaiLocalKey = computed(() => {
  return `simpadu_nilai_dosen_${userIdentity.value[0] || 'dosen'}`
})

const PESERTA_KELAS_MK_ENDPOINTS = [
  'https://belajarapi.agussbn.my.id/api/pesertakelasmk',
  '/kelas-api/api/pesertakelasmk',
  '/kelas-api/pesertakelasmk',
  '/kelas-api/api/peserta-kelas-mk',
  '/kelas-api/api/peserta_kelas_mk',
]

const PRESENSI_MAHASISWA_ROSTER_ENDPOINTS = [
  'https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-mahasiswa/roster',
  '/api/absensi/roster',
]

const BATCH_ROLL_CALL_ENDPOINTS = [
  'https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-mahasiswa/batch-roll-call',
  '/api/absensi/manual',
]

const GENERATE_SESSION_ENDPOINTS = [
  'https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-sesi/generate',
  '/api/qr/generate',
  '/api/kelas/start',
]

const CLOSE_SESSION_ENDPOINTS = [
  'https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-sesi',
  '/api/kelas/end',
]

const NILAI_ENDPOINT = ENDPOINTS?.nilai?.index || '/api/nilai'

const manualStatusOptions = [
  { value: 'H', label: 'H', className: 'hadir' },
  { value: 'S', label: 'S', className: 'sakit' },
  { value: 'I', label: 'I', className: 'izin' },
  { value: 'A', label: 'A', className: 'alpha' },
]

function setMessage(type, text) {
  message.value = { type, text }

  if (text) {
    setTimeout(() => {
      message.value = { type: '', text: '' }
    }, 4500)
  }
}

function normalizeStatus(status) {
  return String(status || '').toLowerCase().trim()
}

function pillClass(status) {
  const clean = normalizeStatus(status)

  if (clean === 'hadir' || clean === 'h') return 'ok'
  if (clean === 'izin' || clean === 'sakit' || clean === 'i' || clean === 's') return 'warn'

  return 'danger'
}

function apiMessage(error, fallback) {
  const errors = error?.response?.data?.errors || {}
  const firstErrorKey = Object.keys(errors)[0]
  const firstError = firstErrorKey
    ? Array.isArray(errors[firstErrorKey])
      ? errors[firstErrorKey][0]
      : errors[firstErrorKey]
    : ''

  return (
    firstError ||
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
  if (Array.isArray(data.nilai)) return data.nilai
  if (Array.isArray(data.data)) return data.data

  return []
}

async function getRifkiToken() {
  const token = localStorage.getItem('rifki_api_token')
  const timestamp = Number(localStorage.getItem('rifki_token_timestamp') || '0')
  const now = Date.now()
  
  // 1500000ms is 25 minutes (token expires in 1800s/30 mins)
  if (token && (now - timestamp < 1500000)) {
    return token
  }
  
  const savedU = localStorage.getItem('simpadu_u')
  const savedP = localStorage.getItem('simpadu_p')
  if (savedU && savedP) {
    try {
      const response = await fetch('https://api-admin-4c.rifkiaja.my.id:9002/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ email: savedU, password: savedP })
      })
      if (response.ok) {
        const data = await response.json()
        const newToken = data?.token || data?.access_token || data?.data?.token || data?.data?.access_token || ''
        if (newToken) {
          localStorage.setItem('rifki_api_token', newToken)
          localStorage.setItem('rifki_token_timestamp', String(Date.now()))
          return newToken
        }
      }
    } catch (e) {
      console.error("Gagal refresh token Rifki:", e)
    }
  }
  return token || ''
}

function getNestedValue(obj, paths) {
  for (const path of paths) {
    const value = path.split('.').reduce((result, key) => {
      return result && result[key] !== undefined ? result[key] : undefined
    }, obj)

    if (value !== undefined && value !== null && String(value).trim() !== '') {
      return value
    }
  }

  return ''
}

async function requestKelasEndpoint(endpoint) {
  const response = await fetch(endpoint, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
    },
    credentials: 'omit',
  })

  const text = await response.text()
  let data = null

  try {
    data = text ? JSON.parse(text) : null
  } catch {
    data = text
  }

  if (!response.ok) {
    const error = new Error(`Endpoint ${endpoint} gagal dengan status ${response.status}`)
    error.response = { status: response.status, data }
    throw error
  }

  return { data }
}

async function requestKelasApiEndpoint(endpoint) {
  // Endpoint internal SIMPADU wajib lewat instance api agar Bearer token ikut terkirim.
  const response = await api.get(endpoint)
  return { data: response.data }
}

function ambilDataPesertaKelasMk(response) {
  const data = response?.data

  if (Array.isArray(data)) return data
  if (Array.isArray(data?.data)) return data.data
  if (Array.isArray(data?.pesertakelasmk)) return data.pesertakelasmk
  if (Array.isArray(data?.peserta_kelas_mk)) return data.peserta_kelas_mk
  if (Array.isArray(data?.pesertaKelasMk)) return data.pesertaKelasMk
  if (Array.isArray(data?.result)) return data.result
  if (Array.isArray(data?.items)) return data.items
  if (Array.isArray(data?.records)) return data.records
  if (Array.isArray(data?.jadwal)) return data.jadwal
  if (Array.isArray(data?.jadwal_mengajar)) return data.jadwal_mengajar
  if (Array.isArray(data?.kelas)) return data.kelas

  return []
}

function normalizePeserta(item, index = 0) {
  const nim = String(item?.nim || item?.NIM || item?.id || item?.mahasiswa_id || '').trim()
  const nama = String(item?.nama || item?.NAMA || item?.nama_mahasiswa || item?.name || '').trim()

  return {
    ...item,
    _key: String(nim || nama || index),
    nim,
    nama: nama || `Peserta ${nim || index + 1}`,
    manual_status: item?.manual_status || item?.status_manual || item?.status_presensi || item?.status || '',
  }
}

function parsePeserta(value) {
  if (Array.isArray(value)) return value.map(normalizePeserta)
  if (!value) return []

  return String(value)
    .split('\n')
    .map((line, index) => {
      const [nim = '', nama = ''] = line.split('|').map((part) => part.trim())
      return normalizePeserta({ nim, nama: nama || nim }, index)
    })
    .filter((item) => item.nim || item.nama)
}

function normalizeKelas(item) {
  const id = String(
    item.id ||
      item.kelas_id ||
      item.id_kelas ||
      item.kode_kelas ||
      item.kelas_mk_id ||
      item.id_kelas_mk ||
      ''
  ).trim()

  return {
    ...item,
    id,
    id_kelas: String(item.id_kelas || item.kelas_id || id || NILAI_ID_KELAS).trim(),
    id_mk: String(item.id_mk || item.mk_id || item.mata_kuliah_id || item.id_matkul || item.kode_mk || NILAI_ID_MK).trim(),
    id_kelas_session: item.id_kelas_session || item.kelas_session_id || item.session_id || '',
    kode_pertemuan: item.kode_pertemuan || item.pertemuan || 1,
    _key: String(id || item.nama || item.nama_kelas || item.mata_kuliah || Math.random()),
    nama:
      item.nama ||
      item.nama_kelas ||
      item.mata_kuliah ||
      item.nama_mk ||
      item.kelas ||
      `Kelas ${id || ''}`,
    semester: item.semester || '-',
    sks: item.sks || '-',
    dosen_id: String(item.dosen_id || item.id_dosen || item.pegawai_id || item.PEGAWAI_ID || item.NIP || item.nip || '').trim(),
    dosen_email: String(item.dosen_email || item.email_dosen || item.email || item.EMAIL || '').trim(),
    dosen_nama: String(item.dosen_nama || item.nama_dosen || item.NAMA_PEGAWAI || item.nama_pegawai || userName.value || '').trim(),
    ruang: item.ruang || item.ruangan || '',
    ruangan: item.ruangan || item.ruang || '',
    jadwal: item.jadwal || item.jam || item.waktu || '',
    status: item.status || 'tersedia',
    qrCode: item.qrCode || '',
    qrToken: item.qrToken || '',
    peserta: parsePeserta(item.peserta || item.mahasiswa || item.daftar_peserta || item.pesertaText),
    peserta_nim: item.peserta_nim || '',
    peserta_nama: item.peserta_nama || '',
    manual_mahasiswa_key: item.manual_mahasiswa_key || '',
    manual_nim: item.manual_nim || '',
    manual_nama: item.manual_nama || '',
    manual_status: item.manual_status || '',
    materi_file: null,
    tugas_file: null,
    materi_list: Array.isArray(item.materi_list) ? item.materi_list : [],
    tugas_list: Array.isArray(item.tugas_list) ? item.tugas_list : [],
  }
}

function normalizePresensi(item, index = 0) {
  return {
    ...item,
    _key:
      item._key ||
      item.id ||
      `${item.kelas_id || item.id_kelas || 'kelas'}-${item.created_at || item.tanggal || index}-${item.status || ''}`,
    tanggal: item.tanggal || item.created_at || new Date().toLocaleDateString('id-ID'),
    created_at: item.created_at || new Date().toLocaleString('id-ID'),
    kelas_id: item.kelas_id || item.id_kelas || '',
    nama_kelas: item.nama_kelas || item.mata_kuliah || item.kelas || '',
    status: item.status || '',
    keterangan: item.keterangan || item.catatan || '',
    waktu_masuk: item.waktu_masuk || item.jam_masuk || item.masuk || '',
    waktu_keluar: item.waktu_keluar || item.jam_keluar || item.keluar || '',
  }
}

function normalizeNilai(item, index = 0) {
  const finalScore =
    item.final_score ??
    item.nilai_akhir ??
    item.nilai ??
    item.total ??
    item.nilaiAkhir ??
    0

  return {
    ...item,
    _key: item._key || item.id || `${item.nim || 'nilai'}-${index}-${Date.now()}`,
    id_dosen: item.id_dosen || item.dosen_id || getDosenId(),
    id_kelas: item.id_kelas || item.kelas_id || NILAI_ID_KELAS,
    id_mk: item.id_mk || item.mk_id || item.kode_mk || NILAI_ID_MK,
    nama_kelas: item.nama_kelas || item.kelas || item.mata_kuliah || `Kelas ${NILAI_ID_KELAS}`,
    nim: item.nim || item.NIM || item.mahasiswa_nim || '',
    nama: item.nama || item.nama_mahasiswa || item.mahasiswa_nama || item.name || '',
    participation_score: Number(item.participation_score ?? item.partisipasi ?? 0),
    assignment_score: Number(item.assignment_score ?? item.nilai_tugas ?? item.tugas ?? item.tugas_nilai ?? 0),
    quiz_score: Number(item.quiz_score ?? item.kuis ?? item.quiz ?? 0),
    uts_score: Number(item.uts_score ?? item.nilai_uts ?? item.uts ?? item.uts_nilai ?? 0),
    uas_score: Number(item.uas_score ?? item.nilai_uas ?? item.uas ?? item.uas_nilai ?? 0),
    final_score: Number(finalScore || 0),
    grade: item.grade || hitungGrade(finalScore),
  }
}

function normalizePesertaKelasMkToKelas(list) {
  const map = new Map()

  list.forEach((item, index) => {
    const kelasId = String(
      getNestedValue(item, [
        'kelas_mk_id',
        'id_kelas_mk',
        'id_kelas_mata_kuliah',
        'kelas_mata_kuliah_id',
        'kelas_id',
        'id_kelas',
        'kode_kelas',
        'kelas.id',
        'kelas.kode_kelas',
        'kelas_mk.id',
        'kelas_mk.kode_kelas',
        'id',
      ]) || `KELAS-${index + 1}`
    ).trim()

    const namaMatkul = String(
      getNestedValue(item, [
        'nama_mk',
        'nama_matkul',
        'nama_mata_kuliah',
        'mata_kuliah',
        'matakuliah',
        'mk.nama',
        'mk.nama_mk',
        'mata_kuliah.nama',
        'kelas_mk.nama_mk',
        'kelas_mk.mata_kuliah.nama',
      ]) || `Mata Kuliah ${kelasId}`
    ).trim()

    const namaKelas = String(
      getNestedValue(item, [
        'nama_kelas',
        'kelas',
        'kelas.nama',
        'kelas.nama_kelas',
        'kelas_mk.kelas',
        'kelas_mk.nama_kelas',
        'kelas_mk.kelas.nama',
      ]) || ''
    ).trim()

    const namaDosen = String(
      getNestedValue(item, [
        'nama_dosen',
        'dosen_nama',
        'nama_pegawai',
        'NAMA_PEGAWAI',
        'dosen.nama',
        'dosen.nama_pegawai',
        'dosen.NAMA_PEGAWAI',
        'pegawai.nama',
        'pegawai.nama_pegawai',
        'pegawai.NAMA_PEGAWAI',
        'kelas_mk.nama_dosen',
        'kelas_mk.dosen.nama',
        'kelas_mk.pegawai.nama',
      ]) || userName.value
    ).trim()

    const ruang = String(
      getNestedValue(item, [
        'ruang',
        'ruangan',
        'kelas_mk.ruang',
        'kelas_mk.ruangan',
      ]) || '-'
    ).trim()

    const hari = String(getNestedValue(item, ['hari', 'kelas_mk.hari']) || '').trim()
    const jam = String(getNestedValue(item, ['jam', 'waktu', 'kelas_mk.jam', 'kelas_mk.waktu']) || '').trim()
    const jadwalRaw = String(getNestedValue(item, ['jadwal', 'kelas_mk.jadwal']) || '').trim()
    const jadwal = jadwalRaw || [hari, jam].filter(Boolean).join(', ') || '-'

    const semester = getNestedValue(item, ['semester', 'kelas_mk.semester', 'mata_kuliah.semester']) || '-'
    const sks = getNestedValue(item, ['sks', 'kelas_mk.sks', 'mata_kuliah.sks']) || '-'

    const nim = String(
      getNestedValue(item, [
        'nim',
        'NIM',
        'mahasiswa_nim',
        'mahasiswa.nim',
        'mahasiswa.NIM',
        'peserta.nim',
      ]) || ''
    ).trim()

    const namaMahasiswa = String(
      getNestedValue(item, [
        'nama_mahasiswa',
        'mahasiswa_nama',
        'nama',
        'mahasiswa.nama',
        'mahasiswa.nama_mahasiswa',
        'peserta.nama',
      ]) || ''
    ).trim()

    if (!map.has(kelasId)) {
      map.set(kelasId, {
        id: kelasId,
        nama: namaKelas ? `${namaMatkul} - ${namaKelas}` : namaMatkul,
        nama_kelas: namaKelas || namaMatkul,
        mata_kuliah: namaMatkul,
        semester,
        sks,
        ruang,
        ruangan: ruang,
        jadwal,
        status: 'tersedia',
        dosen_nama: namaDosen,
        jumlah_mahasiswa: 0,
        peserta: [],
      })
    }

    const kelas = map.get(kelasId)

    if (nim || namaMahasiswa) {
      const sudahAda = kelas.peserta.some((peserta) => {
        return String(peserta.nim || '') === String(nim || '')
      })

      if (!sudahAda) {
        kelas.peserta.push({
          _key: String(nim || namaMahasiswa || `${kelasId}-${index}`),
          nim,
          nama: namaMahasiswa || `Mahasiswa ${nim}`,
        })
      }
    }

    kelas.jumlah_mahasiswa = kelas.peserta.length
  })

  return Array.from(map.values()).map(normalizeKelas)
}

function getKelasDemoFallback() {
  return [
    {
      id: 'IF-301',
      nama: 'Basis Data Lanjut',
      semester: 2,
      sks: 3,
      ruang: 'A-205',
      jadwal: 'Senin, 08:00 - 10:30',
      status: 'tersedia',
      dosen_nama: userName.value,
      peserta: [
        { nim: '12345670', nama: 'Siti Aminah' },
        { nim: '12345671', nama: 'Budi Pratama' },
        { nim: '12345672', nama: 'Rina Sari' },
      ],
    },
    {
      id: 'IF-204',
      nama: 'Keamanan Jaringan',
      semester: 4,
      sks: 3,
      ruang: 'B-301',
      jadwal: 'Rabu, 13:30 - 15:00',
      status: 'tersedia',
      dosen_nama: userName.value,
      peserta: [
        { nim: '22345670', nama: 'Andi Saputra' },
        { nim: '22345671', nama: 'Maya Lestari' },
      ],
    },
    {
      id: 'IF-205',
      nama: 'Pemrograman Web',
      semester: 4,
      sks: 3,
      ruang: 'B-302',
      jadwal: 'Kamis, 13:30 - 15:00',
      status: 'tersedia',
      dosen_nama: userName.value,
      peserta: [
        { nim: '32345670', nama: 'Rizky Ramadhan' },
        { nim: '32345671', nama: 'Putri Anggraini' },
      ],
    },
  ].map(normalizeKelas)
}

function jumlahPesertaKelas(kelas) {
  if (Array.isArray(kelas?.peserta) && kelas.peserta.length) return kelas.peserta.length
  return kelas?.jumlah_mahasiswa || kelas?.total_mahasiswa || 0
}

function namaDosenKelas(kelas) {
  return kelas?.dosen_nama || kelas?.nama_dosen || kelas?.dosen_email || userName.value || '-'
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
  localStorage.setItem(presensiLocalKey.value, JSON.stringify(list.map(normalizePresensi)))
}

function ambilNilaiLokal() {
  try {
    const data = JSON.parse(localStorage.getItem(nilaiLocalKey.value) || '[]')
    return Array.isArray(data) ? data.map(normalizeNilai) : []
  } catch {
    return []
  }
}

function simpanNilaiLokal(list) {
  localStorage.setItem(nilaiLocalKey.value, JSON.stringify(list.map(normalizeNilai)))
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
  localStorage.setItem(adminKelasKey, JSON.stringify(list.map(normalizeKelas)))
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


function isKelasTerbuka(kelas) {
  return String(selectedKelasId.value) === String(kelas?.id || kelas?._key || '')
}

async function fetchRoster(kelas) {
  if (!kelas) return
  const idKelasMk = getApiIdKelas(kelas)
  if (!idKelasMk) return

  loading.value = true
  let success = false
  for (const endpoint of PRESENSI_MAHASISWA_ROSTER_ENDPOINTS) {
    try {
      const response = await api.get(endpoint, {
        params: {
          id_kelas_mk: idKelasMk,
          pertemuan_ke: pertemuanKe.value
        }
      })
      const rosterData = response?.data?.data || response?.data || []
      if (Array.isArray(rosterData) && rosterData.length > 0) {
        kelas.peserta = rosterData.map((m, idx) => ({
          _key: String(m.nim || m.id_kelas_master || idx),
          id_kelas_master: m.id_kelas_master,
          nim: m.nim,
          nama: m.nama_mahasiswa || `Mahasiswa ${m.nim}`,
          manual_status: m.status_presensi || 'H',
          metode: m.metode
        }))
        success = true
        break
      }
    } catch (e) {
      console.warn(`Roster fetch failed on ${endpoint}:`, e)
    }
  }
  loading.value = false
}

function bukaDetailKelas(kelas) {
  selectedKelasId.value = String(kelas?.id || kelas?._key || '')
  pertemuanKe.value = 1
  fetchRoster(kelas)
}

function toggleDetailKelas(kelas) {
  bukaDetailKelas(kelas)
}

function kembaliKeDaftarKelas() {
  selectedKelasId.value = ''
}

function pilihFileMateri(kelas, event) {
  const file = event?.target?.files?.[0] || null
  kelas.materi_file = file
}

function pilihFileTugas(kelas, event) {
  const file = event?.target?.files?.[0] || null
  kelas.tugas_file = file
}

function simpanUploadLokal(kelas, jenis, file, responseData = {}) {
  const key = jenis === 'materi' ? 'materi_list' : 'tugas_list'
  const item = {
    _key: `${jenis}-${kelas.id}-${Date.now()}`,
    nama: file?.name || responseData?.nama || responseData?.filename || `${jenis} kelas`,
    uploaded_at: new Date().toLocaleString('id-ID'),
    ...responseData,
  }

  const list = [item, ...(kelas[key] || [])]

  updateKelasLokal({
    ...kelas,
    [key]: list,
    [`${jenis}_file`]: null,
  })
}

async function uploadMateriKelas(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan.')
    return
  }

  if (!kelas.materi_file) {
    setMessage('error', 'Pilih file materi terlebih dahulu.')
    return
  }

  loading.value = true
  setMessage('', '')

  const formData = new FormData()
  formData.append('id_kelas', getApiIdKelas(kelas))
  formData.append('id_mk', getApiIdMk(kelas))

  if (kelas.id_kelas_session) {
    formData.append('id_kelas_session', String(kelas.id_kelas_session))
  }

  formData.append('judul', kelas.materi_judul || getFileBaseName(kelas.materi_file, 'Materi Pembelajaran'))
  formData.append('deskripsi', kelas.materi_deskripsi || `Materi untuk ${kelas.nama || 'kelas'}`)
  formData.append('file', kelas.materi_file)

  try {
    const endpoint = ENDPOINTS?.dosen?.uploadMateri || '/api/materi'
    const response = await api.post(endpoint, formData)

    simpanUploadLokal(kelas, 'materi', kelas.materi_file, response?.data?.data || {})
    setMessage('success', response?.data?.message || 'Materi berhasil diupload.')
  } catch (e) {
    simpanUploadLokal(kelas, 'materi', kelas.materi_file)
    setMessage('info', 'API upload materi belum bisa diakses. Materi disimpan sementara di browser.')
  } finally {
    loading.value = false
  }
}

async function uploadTugasKelas(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan.')
    return
  }

  if (!kelas.tugas_file) {
    setMessage('error', 'Pilih file tugas terlebih dahulu.')
    return
  }

  loading.value = true
  setMessage('', '')

  const formData = new FormData()
  formData.append('id_kelas', getApiIdKelas(kelas))
  formData.append('id_mk', getApiIdMk(kelas))
  formData.append('judul', kelas.tugas_judul || getFileBaseName(kelas.tugas_file, 'Tugas Mahasiswa'))
  formData.append('deskripsi', kelas.tugas_deskripsi || `Tugas untuk ${kelas.nama || 'kelas'}`)
  formData.append('deadline', kelas.tugas_deadline || '2026-05-30 23:59:59')
  formData.append('file', kelas.tugas_file)

  try {
    const endpoint = ENDPOINTS?.dosen?.uploadTugas || '/api/tugas'
    const response = await api.post(endpoint, formData)

    simpanUploadLokal(kelas, 'tugas', kelas.tugas_file, response?.data?.data || {})
    setMessage('success', response?.data?.message || 'Tugas berhasil diupload.')
  } catch (e) {
    simpanUploadLokal(kelas, 'tugas', kelas.tugas_file)
    setMessage('info', 'API upload tugas belum bisa diakses. Tugas disimpan sementara di browser.')
  } finally {
    loading.value = false
  }
}


function statusManualPeserta(peserta) {
  return String(peserta?.manual_status || peserta?.status_manual || peserta?.status_presensi || peserta?.status || '').toUpperCase()
}

function setStatusPresensiManual(kelas, peserta, status) {
  if (!kelas || !peserta) return

  const pesertaKey = peserta._key || String(peserta.nim || peserta.NIM || peserta.id || peserta.nama || '').trim()

  const pesertaList = (kelas.peserta || []).map((item, idx) => {
    const itemKey = item._key || String(item.nim || item.NIM || item.id || item.nama || idx).trim()

    if (String(itemKey) === String(pesertaKey)) {
      return normalizePeserta({
        ...item,
        manual_status: status,
        status_manual: status,
      }, idx)
    }

    return normalizePeserta(item, idx)
  })

  updateKelasLokal({
    ...kelas,
    peserta: pesertaList,
    jumlah_mahasiswa: pesertaList.length,
  })
}

function pilihMahasiswaPresensi(kelas) {
  const peserta = (kelas.peserta || []).find((item) => {
    return String(item._key) === String(kelas.manual_mahasiswa_key)
  })

  if (!peserta) {
    kelas.manual_nim = ''
    kelas.manual_nama = ''
    return
  }

  kelas.manual_nim = peserta.nim || ''
  kelas.manual_nama = peserta.nama || ''
}

function makeQrImageFromToken(token) {
  return `https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=${encodeURIComponent(token)}`
}

function buatQrDemo(kelas) {
  const tokenDemo = JSON.stringify({
    mode: 'demo_qr',
    kelas_id: kelas.id,
    nama_kelas: kelas.nama,
    dosen: userName.value,
    waktu: new Date().toISOString(),
  })

  return makeQrImageFromToken(tokenDemo)
}

function bukaQrModal(kelas) {
  if (!kelas?.qrCode) {
    setMessage('error', 'QR belum tersedia. Klik Mulai Kelas terlebih dahulu.')
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
  setMessage('error', 'Gambar QR gagal dimuat.')
}

async function ambilKelasSaya() {
  loading.value = true
  setMessage('', '')

  try {
    let response = null
    let lastError = null

    // 1. Prioritas Utama: Rifki's akademik/kelas
    try {
      const tokenRifki = await getRifkiToken()
      if (tokenRifki) {
        const fetchResponse = await fetch('https://api-admin-4c.rifkiaja.my.id:9002/api/akademik/kelas', {
          headers: {
            'Accept': 'application/json',
            'Authorization': `Bearer ${tokenRifki}`
          }
        })
        if (fetchResponse.ok) {
          const resJson = await fetchResponse.json()
          const rifkiClasses = resJson?.data || []
          if (Array.isArray(rifkiClasses) && rifkiClasses.length > 0) {
            // Map the rifkiClasses format to our normalized class structure with dummy details and students
            const normalized = rifkiClasses.map((item, index) => {
              const idKelas = item.id_kelas || `KELAS-${index + 1}`
              const kelasNama = item.kelas_nama || item.alias || `TI_2${String.fromCharCode(65 + index)}`
              return {
                id_kelas_mk: idKelas,
                id_kelas: idKelas,
                kelas_mk_id: idKelas,
                id: String(idKelas),
                nama: `Mata Kuliah ${index + 1} - ${kelasNama}`,
                nama_kelas: kelasNama,
                mata_kuliah: `Mata Kuliah ${index + 1}`,
                semester: item.semester || 1,
                sks: 3,
                ruang: 'Lab Komputer 1',
                hari: index % 2 === 0 ? 'Senin' : 'Rabu',
                jam: '08:00 - 10:30',
                jadwal: index % 2 === 0 ? 'Senin, 08:00 - 10:30' : 'Rabu, 13:30 - 15:00',
                status: 'tersedia',
                dosen_nama: userName.value,
                // Dummy student roster data as requested
                peserta: [
                  { id_kelas_master: 1, nim: `C03032100${index}1`, nama: 'Ahmad Dani', status_presensi: '' },
                  { id_kelas_master: 2, nim: `C03032100${index}2`, nama: 'Siti Aminah', status_presensi: '' },
                  { id_kelas_master: 3, nim: `C03032100${index}3`, nama: 'Budi Pratama', status_presensi: '' },
                  { id_kelas_master: 4, nim: `C03032100${index}4`, nama: 'Rina Sari', status_presensi: '' },
                  { id_kelas_master: 5, nim: `C03032100${index}5`, nama: 'Andi Saputra', status_presensi: '' }
                ]
              }
            })
            kelasSaya.value = normalized
            simpanSemuaKelasAdmin(normalized)
            return
          }
        } else {
          console.warn(`Rifki's kelas endpoint returned error status: ${fetchResponse.status}`)
        }
      }
    } catch (rifkiError) {
      console.warn("Gagal mengambil kelas dari API Rifki:", rifkiError)
    }

    // 2. Backup/Prioritas Kedua: data resmi dari Postman/API SIMPADU.
    const apiEndpointCandidates = [
      ENDPOINTS?.dashboard?.jadwalMengajar,
      ENDPOINTS?.kelas?.list,
    ].filter(Boolean)

    for (const endpoint of [...new Set(apiEndpointCandidates)]) {
      try {
        response = await requestKelasApiEndpoint(endpoint)
        break
      } catch (error) {
        lastError = error
      }
    }

    // 3. Fallback lama tetap dipertahankan supaya fitur yang sudah jalan tidak rusak.
    if (!response) {
      for (const endpoint of PESERTA_KELAS_MK_ENDPOINTS) {
        try {
          response = await requestKelasEndpoint(endpoint)
          break
        } catch (error) {
          lastError = error
        }
      }
    }

    if (!response) {
      throw lastError
    }

    const rawData = ambilDataPesertaKelasMk(response)
    const kelasDariApi = normalizePesertaKelasMkToKelas(rawData)

    if (kelasDariApi.length === 0) {
      const kelasLokal = ambilSemuaKelasAdmin()

      if (kelasLokal.length > 0) {
        kelasSaya.value = kelasLokal
        return
      }

      kelasSaya.value = getKelasDemoFallback()
      setMessage('info', 'Data kelas dari API kosong. Sistem menampilkan data sementara.')
      return
    }

    kelasSaya.value = kelasDariApi
    simpanSemuaKelasAdmin(kelasDariApi)
  } catch (e) {
    const kelasLokal = ambilSemuaKelasAdmin()
    kelasSaya.value = kelasLokal.length > 0 ? kelasLokal : getKelasDemoFallback()
    setMessage('info', 'Data kelas belum bisa dimuat dari API. Sistem menampilkan data sementara.')
  } finally {
    loading.value = false
  }
}

async function ambilRekapAbsensi(tampilkanPesan = false) {
  loading.value = true

  try {
    const endpoint = ENDPOINTS?.absensi?.rekapDosen || '/api/absensi/rekap'
    const response = await api.get(endpoint)

    const apiData = ambilArray(response).map((item, index) => normalizePresensi(item, index))
    const localData = ambilRiwayatPresensiLokal()

    riwayatPresensi.value = gabungPresensi(apiData, localData)
  } catch (e) {
    riwayatPresensi.value = ambilRiwayatPresensiLokal()

    if (tampilkanPesan && riwayatPresensi.value.length === 0) {
      setMessage('info', 'Riwayat dari API belum bisa diambil, tetapi presensi tetap bisa disimpan.')
    }
  } finally {
    loading.value = false
  }
}

async function ambilPresensiHariIni(tampilkanPesan = false) {
  try {
    const endpoint = ENDPOINTS?.absensi?.dosenHariIni || ENDPOINTS?.absensi?.pegawaiHariIni || '/api/pegawai/absensi/hari-ini'
    const response = await api.get(endpoint)
    const data = response?.data?.data || response?.data || null

    presensiHariIni.value = data
      ? {
          ...data,
          tanggal: data.tanggal || data.created_at || new Date().toLocaleDateString('id-ID'),
          waktu_masuk: data.waktu_masuk || data.jam_masuk || data.masuk || null,
          waktu_keluar: data.waktu_keluar || data.jam_keluar || data.keluar || null,
        }
      : null
  } catch (e) {
    // jangan fallback ke data random, cukup kosongkan biar UI jujur
    presensiHariIni.value = null
    if (tampilkanPesan) {
      setMessage('info', 'Status presensi hari ini belum bisa diambil dari API.')
    }
  }
}

async function ambilDaftarNilai(tampilkanPesan = false) {
  loading.value = true

  try {
    const response = await api.get(NILAI_ENDPOINT, {
      params: {
        id_kelas: NILAI_ID_KELAS,
        id_mk: NILAI_ID_MK,
      },
    })

    const apiData = ambilArray(response)
    const nilaiDariApi = apiData.length > 0 ? apiData : NILAI_MAHASISWA_DEFAULT

    daftarNilai.value = nilaiDariApi.map((item, index) => normalizeNilai(item, index))
  } catch (e) {
    const localData = ambilNilaiLokal()
    const nilaiFallback = localData.length > 0 ? localData : NILAI_MAHASISWA_DEFAULT

    daftarNilai.value = nilaiFallback.map((item, index) => normalizeNilai(item, index))

    if (tampilkanPesan && daftarNilai.value.length === 0) {
      setMessage('info', 'Data nilai dari API belum bisa dimuat.')
    }
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

  const idKelasMk = Number(getApiIdKelas(kelas))
  const payloadRifki = {
    ID_KELAS_MK: idKelasMk,
    PERTEMUAN_KE: Number(pertemuanKe.value),
    duration_minutes: 15,
  }

  try {
    let qrCode = ''
    let sessionToken = ''
    let sessionId = null
    let success = false

    // Try Rifki's generateSession first
    try {
      const response = await api.post('https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-sesi/generate', payloadRifki)
      const sesi = response?.data?.data || response?.data || {}
      sessionId = sesi.id || sesi.ID_SESI || sesi.ID_PRESENSI_SESI || null
      sessionToken = sesi.session_token || ''
      if (sessionToken) {
        qrCode = makeQrImageFromToken(sessionToken)
        success = true
      }
    } catch (e) {
      console.warn("Gagal membuat sesi QR di API Rifki, mencoba local start...", e)
    }

    // Fallback to local / standard start
    if (!success) {
      try {
        const endpoint = ENDPOINTS?.kelas?.start || '/api/kelas/start'
        await api.post(endpoint, {
          kelas_id: idKelasMk,
        })
        qrCode = buatQrDemo(kelas)
        success = true
      } catch (localError) {
        console.warn("Gagal memulai kelas di API lokal, menggunakan mode demo offline.", localError)
        qrCode = buatQrDemo(kelas)
      }
    }

    updateKelasLokal({
      ...kelas,
      status: 'berjalan',
      qrCode,
      qrToken: sessionToken || `QR-${kelas.id}-${Date.now()}`,
      qrSessionId: sessionId,
    })

    qrModal.value = {
      show: true,
      nama: kelas.nama || 'Kelas',
      kelasId: kelas.id || '-',
      qrCode,
    }

    setMessage('success', 'Kelas berhasil dimulai dan QR berhasil dibuat.')
  } catch (e) {
    setMessage('error', apiMessage(e, 'Gagal memulai kelas.'))
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
    const sessionId = kelas.qrSessionId

    if (sessionId) {
      try {
        await api.post(`https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-sesi/${sessionId}/close`)
      } catch (e) {
        console.warn("Gagal menutup sesi QR di API Rifki:", e)
      }
    }

    try {
      const endpoint = ENDPOINTS?.kelas?.end || '/api/kelas/end'
      await api.post(endpoint, {
        kelas_id: getApiIdKelas(kelas),
      })
    } catch (e) {
      console.warn("Gagal mengakhiri kelas di API lokal:", e)
    }

    updateKelasLokal({
      ...kelas,
      status: 'selesai',
      qrCode: '',
      qrToken: '',
      qrSessionId: null,
    })

    tutupQrModal()
    setMessage('success', 'Kelas berhasil diakhiri.')
  } catch (e) {
    setMessage('error', apiMessage(e, 'Gagal mengakhiri kelas.'))
  } finally {
    loading.value = false
  }
}

async function simpanPresensiManualMahasiswa(kelas) {
  if (!kelas?.id) {
    setMessage('error', 'ID kelas tidak ditemukan.')
    return
  }

  const pesertaList = Array.isArray(kelas.peserta) ? kelas.peserta : []

  if (pesertaList.length === 0) {
    setMessage('error', 'Belum ada mahasiswa untuk dipresensikan.')
    return
  }

  loading.value = true
  setMessage('', '')

  const payloadRifki = {
    presensi: pesertaList.map((peserta) => ({
      id_kelas_master: peserta.id_kelas_master || 1,
      id_kelas_mk: Number(getApiIdKelas(kelas)),
      nim: String(peserta.nim || '').trim(),
      pertemuan_ke: Number(pertemuanKe.value),
      status_presensi: statusManualPeserta(peserta) || 'H',
    })).filter((item) => item.nim),
  }

  const payloadLocal = {
    id_kelas: getApiIdKelas(kelas),
    id_mk: getApiIdMk(kelas),
    data: pesertaList.map((peserta) => ({
      nim: String(peserta.nim || '').trim(),
      status: statusManualPeserta(peserta) || 'H',
      kode_pertemuan: Number(pertemuanKe.value),
    })).filter((item) => item.nim),
  }

  try {
    let success = false
    let messageText = ''

    try {
      const response = await api.post('https://api-admin-4c.rifkiaja.my.id:9002/api/presensi-mahasiswa/batch-roll-call', payloadRifki)
      success = true
      messageText = response?.data?.message || 'Batch presensi berhasil disimpan ke API Rifki.'
    } catch (e) {
      console.warn("Gagal menyimpan ke API Rifki, mencoba fallback local...", e)
      
      const endpoint = ENDPOINTS?.absensi?.manual || '/api/absensi/manual'
      const response = await api.post(endpoint, payloadLocal)
      success = true
      messageText = response?.data?.message || 'Presensi manual disimpan menggunakan mode fallback.'
    }

    if (success) {
      updateKelasLokal({
        ...kelas,
        peserta: pesertaList.map((peserta) => normalizePeserta(peserta)),
      })
      setMessage('success', messageText)
    }
  } catch (e) {
    setMessage('error', apiMessage(e, 'Gagal menyimpan presensi manual mahasiswa.'))
  } finally {
    loading.value = false
  }
}

async function simpanPresensiDosen() {
  loading.value = true
  setMessage('', '')

  const hariIni = new Date().toLocaleDateString('id-ID')
  const waktuSekarang = new Date().toLocaleString('id-ID')

  const isPulang = modePresensi.value === 'pulang'

  try {
    const endpoint = isPulang
      ? (ENDPOINTS?.absensi?.dosenPulang || ENDPOINTS?.absensi?.pegawaiKeluar || '/api/pegawai/absensi/keluar')
      : (ENDPOINTS?.absensi?.dosenMasuk || ENDPOINTS?.absensi?.pegawaiMasuk || '/api/pegawai/absensi/masuk')

    const response = await api.post(endpoint)

    const data = response?.data?.data || {}

    // update status hari ini biar tombol & info langsung sinkron
    presensiHariIni.value = {
      ...(presensiHariIni.value || {}),
      ...data,
      tanggal: data.tanggal || presensiHariIni.value?.tanggal || hariIni,
      waktu_masuk: data.waktu_masuk || presensiHariIni.value?.waktu_masuk || null,
      waktu_keluar: data.waktu_keluar || presensiHariIni.value?.waktu_keluar || null,
    }

    const presensiBaru = normalizePresensi({
      _key: `dosen-${hariIni}`,
      tanggal: presensiHariIni.value.tanggal || hariIni,
      created_at: waktuSekarang,
      waktu_masuk: presensiHariIni.value.waktu_masuk,
      waktu_keluar: presensiHariIni.value.waktu_keluar,
      status: presensiHariIni.value.waktu_masuk
        ? (presensiHariIni.value.waktu_keluar ? 'Lengkap' : 'Belum pulang')
        : '',
      keterangan: keteranganPresensi.value || '',
    })

    // replace record hari ini di riwayat
    riwayatPresensi.value = [
      presensiBaru,
      ...riwayatPresensi.value.filter((item) => String(item.tanggal || '') !== String(presensiBaru.tanggal || hariIni)),
    ]

    simpanRiwayatPresensiLokal(riwayatPresensi.value)

    // jika sudah pulang, balikin mode ke datang biar UX konsisten
    if (isPulang) modePresensi.value = 'masuk'

    setMessage('success', response?.data?.message || (isPulang ? 'Presensi pulang berhasil.' : 'Presensi datang berhasil.'))
  } catch (e) {
    setMessage('error', apiMessage(e, isPulang ? 'Gagal presensi pulang.' : 'Gagal presensi datang.'))
  } finally {
    loading.value = false
  }
}

function pilihKelasNilai() {
  nilaiForm.value.id_kelas = NILAI_ID_KELAS
  nilaiForm.value.id_mk = NILAI_ID_MK
  nilaiForm.value.nim = ''
  nilaiForm.value.nama = ''
}

function pilihMahasiswaNilai() {
  const peserta = pesertaNilai.value.find((item) => String(item.nim) === String(nilaiForm.value.nim))

  if (peserta) {
    nilaiForm.value.nama = peserta.nama || ''
    nilaiForm.value.participation_score = Number(peserta.participation_score || 0)
    nilaiForm.value.assignment_score = Number(peserta.assignment_score || 0)
    nilaiForm.value.quiz_score = Number(peserta.quiz_score || 0)
    nilaiForm.value.uts_score = Number(peserta.uts_score || 0)
    nilaiForm.value.uas_score = Number(peserta.uas_score || 0)
  }
}

async function simpanNilaiMahasiswa() {
  if (!nilaiForm.value.nim) {
    setMessage('error', 'Pilih mahasiswa terlebih dahulu.')
    return
  }

  loading.value = true
  setMessage('', '')

  const nilaiItem = {
    nim: String(nilaiForm.value.nim || ''),
    participation_score: Number(nilaiForm.value.participation_score || 0),
    assignment_score: Number(nilaiForm.value.assignment_score || 0),
    quiz_score: Number(nilaiForm.value.quiz_score || 0),
    uts_score: Number(nilaiForm.value.uts_score || 0),
    uas_score: Number(nilaiForm.value.uas_score || 0),
  }

  const payload = {
    id_kelas: String(nilaiForm.value.id_kelas || NILAI_ID_KELAS),
    id_mk: String(nilaiForm.value.id_mk || NILAI_ID_MK),
    data: [nilaiItem],
  }

  try {
    const response = await api.post(ENDPOINTS?.nilai?.store || '/api/nilai', payload)

    const nilaiBaru = normalizeNilai({
      _key: `nilai-${nilaiItem.nim}-${Date.now()}`,
      ...nilaiItem,
      id_kelas: payload.id_kelas,
      id_mk: payload.id_mk,
      final_score: Number(nilaiAkhir.value || 0),
      grade: gradeNilai.value || null,
      nama: nilaiForm.value.nama || '',
      nama_kelas: `Kelas ${NILAI_ID_KELAS}`,
      ...(response?.data?.data || {}),
    })

    daftarNilai.value = [
      nilaiBaru,
      ...daftarNilai.value.filter((item) => String(item.nim) !== String(nilaiItem.nim)),
    ]

    simpanNilaiLokal(daftarNilai.value)
    resetNilaiForm()

    setMessage('success', response?.data?.message || 'Nilai mahasiswa berhasil disimpan.')
  } catch (e) {
    const nilaiBaru = normalizeNilai({
      _key: `nilai-local-${nilaiItem.nim}-${Date.now()}`,
      ...nilaiItem,
      id_kelas: payload.id_kelas,
      id_mk: payload.id_mk,
      final_score: Number(nilaiAkhir.value || 0),
      grade: gradeNilai.value || null,
      nama: nilaiForm.value.nama || '',
      nama_kelas: `Kelas ${NILAI_ID_KELAS}`,
      created_at: new Date().toLocaleString('id-ID'),
    })

    daftarNilai.value = [
      nilaiBaru,
      ...daftarNilai.value.filter((item) => String(item.nim) !== String(nilaiItem.nim)),
    ]

    simpanNilaiLokal(daftarNilai.value)
    resetNilaiForm()

    setMessage('info', 'API nilai belum bisa diakses. Nilai disimpan sementara di browser.')
  } finally {
    loading.value = false
  }
}

// State KRS
const krsList = ref([])
const krsLoading = ref(false)
const selectedKrs = ref(null)
const krsDetailLoading = ref(false)
const krsSearchQuery = ref('')
const krsStatuses = ref(JSON.parse(localStorage.getItem('simpadu_krs_statuses') || '{}'))

// Mock names dictionary to make the mockup list premium and realistic
const MOCK_NAMES_BY_NIM = {
  'C030322001': 'Achmad Fauzi',
  'C030322005': 'Rizky Ramadhan',
  'C030322012': 'Siti Aminah',
  'C001': 'Budi Santoso',
  'C002': 'Dessy Ratnasari',
  'C003': 'Zaky Alfarisi',
  'C005': 'Rahmat Hidayat',
  'C006': 'Halimah Tusadiah'
}

function getStudentName(nim) {
  return MOCK_NAMES_BY_NIM[nim] || `Mahasiswa (${nim})`
}

const KRS_DEMO_FALLBACK = [
  {
    id_krs: "krs-001",
    nim: "C030322001",
    nama_kelas: "TI - 4A",
    semester: "4",
    created_at: "2026-06-01T08:00:00Z",
    updated_at: "2026-06-01T08:30:00Z",
    mata_kuliahs: [
      { id_mk: "MK01", nama_mk: "Pemrograman Web Lanjut", sks: 3 },
      { id_mk: "MK02", nama_mk: "Basis Data Terdistribusi", sks: 3 },
      { id_mk: "MK03", nama_mk: "Analisis & Desain Sistem", sks: 3 },
      { id_mk: "MK04", nama_mk: "Kecerdasan Buatan", sks: 3 },
      { id_mk: "MK05", nama_mk: "Bahasa Inggris Profesi", sks: 2 },
      { id_mk: "MK06", nama_mk: "Proyek Akhir 1", sks: 4 }
    ]
  },
  {
    id_krs: "krs-002",
    nim: "C030322005",
    nama_kelas: "TI - 4B",
    semester: "4",
    created_at: "2026-06-02T09:15:00Z",
    updated_at: "2026-06-02T10:00:00Z",
    mata_kuliahs: [
      { id_mk: "MK01", nama_mk: "Pemrograman Web Lanjut", sks: 3 },
      { id_mk: "MK02", nama_mk: "Basis Data Terdistribusi", sks: 3 },
      { id_mk: "MK03", nama_mk: "Analisis & Desain Sistem", sks: 3 },
      { id_mk: "MK04", nama_mk: "Kecerdasan Buatan", sks: 3 },
      { id_mk: "MK07", nama_mk: "Keamanan Jaringan", sks: 3 }
    ]
  },
  {
    id_krs: "krs-003",
    nim: "C030322012",
    nama_kelas: "TI - 4A",
    semester: "4",
    created_at: "2026-06-03T14:20:00Z",
    updated_at: "2026-06-03T15:10:00Z",
    mata_kuliahs: [
      { id_mk: "MK01", nama_mk: "Pemrograman Web Lanjut", sks: 3 },
      { id_mk: "MK02", nama_mk: "Basis Data Terdistribusi", sks: 3 },
      { id_mk: "MK03", nama_mk: "Analisis & Desain Sistem", sks: 3 }
    ]
  }
]

// Fetch KRS List
async function loadKrsData() {
  krsLoading.value = true
  setMessage('', '')
  const activeToken = localStorage.getItem('rifki_api_token') || localStorage.getItem('simpadu_token') || import.meta.env.VITE_KRS_JWT_TOKEN || 'haei-anteque-anteque-async-embehgweh-bwemwanfwat'
  
  try {
    const response = await api.get('https://api-admin-4c.rifkiaja.my.id:9002/api/akademik/krs', {
      headers: {
        Authorization: `Bearer ${activeToken}`
      }
    })
    const rawData = response.data?.data || response.data || []
    
    if (Array.isArray(rawData) && rawData.length > 0) {
      krsList.value = rawData
    } else {
      krsList.value = KRS_DEMO_FALLBACK
    }
  } catch (error) {
    console.error('Error fetching KRS from API, falling back to mock data:', error)
    krsList.value = KRS_DEMO_FALLBACK
    setMessage('info', 'Microservice API belum aktif atau token kadaluarsa. Menampilkan data demo.')
  } finally {
    krsLoading.value = false
  }
}

// Fetch Single KRS
async function viewKrsDetail(id) {
  krsDetailLoading.value = true
  setMessage('', '')
  const activeToken = localStorage.getItem('rifki_api_token') || localStorage.getItem('simpadu_token') || import.meta.env.VITE_KRS_JWT_TOKEN || 'haei-anteque-anteque-async-embehgweh-bwemwanfwat'

  if (String(id).startsWith('krs-')) {
    const found = krsList.value.find(item => String(item.id_krs) === String(id))
    selectedKrs.value = found ? JSON.parse(JSON.stringify(found)) : null
    krsDetailLoading.value = false
    return
  }

  try {
    const response = await api.get(`https://api-admin-4c.rifkiaja.my.id:9002/api/akademik/krs/${id}`, {
      headers: {
        Authorization: `Bearer ${activeToken}`
      }
    })
    selectedKrs.value = response.data?.data || response.data || null
  } catch (error) {
    console.error('Error fetching KRS detail:', error)
    const found = krsList.value.find(item => String(item.id_krs) === String(id))
    selectedKrs.value = found ? JSON.parse(JSON.stringify(found)) : null
    setMessage('info', 'Gagal memuat rincian dari API. Menampilkan rincian data demo.')
  } finally {
    krsDetailLoading.value = false
  }
}

// Get validation status for a KRS
function getKrsStatus(krs) {
  if (krsStatuses.value[krs.id_krs]) {
    return krsStatuses.value[krs.id_krs]
  }
  return krs.status || 'Menunggu Persetujuan'
}

// Update validation status
async function updateKrsStatus(id_krs, newStatus) {
  loading.value = true
  setMessage('', '')
  const activeToken = localStorage.getItem('rifki_api_token') || localStorage.getItem('simpadu_token') || import.meta.env.VITE_KRS_JWT_TOKEN || 'haei-anteque-anteque-async-embehgweh-bwemwanfwat'
  
  try {
    await api.put(`https://api-admin-4c.rifkiaja.my.id:9002/api/akademik/krs/${id_krs}`, {
      status: newStatus
    }, {
      headers: {
        Authorization: `Bearer ${activeToken}`
      }
    })
    
    krsStatuses.value[id_krs] = newStatus
    localStorage.setItem('simpadu_krs_statuses', JSON.stringify(krsStatuses.value))
    
    if (selectedKrs.value && String(selectedKrs.value.id_krs) === String(id_krs)) {
      selectedKrs.value.status = newStatus
    }
    
    setMessage('success', `Status KRS berhasil diperbarui ke: ${newStatus}`)
  } catch (error) {
    console.warn('API update not supported, updating status locally:', error)
    
    krsStatuses.value[id_krs] = newStatus
    localStorage.setItem('simpadu_krs_statuses', JSON.stringify(krsStatuses.value))
    
    if (selectedKrs.value && String(selectedKrs.value.id_krs) === String(id_krs)) {
      selectedKrs.value.status = newStatus
    }
    
    setMessage('success', `Status KRS berhasil diperbarui (lokal) ke: ${newStatus === 'Disetujui' ? 'Disetujui ✅' : 'Ditolak ❌'}`)
  } finally {
    loading.value = false
  }
}

function calculateTotalSks(krs) {
  if (!krs || !Array.isArray(krs.mata_kuliahs)) return 0
  return krs.mata_kuliahs.reduce((sum, item) => sum + Number(item.sks || 0), 0)
}

function closeKrsDetail() {
  selectedKrs.value = null
}

function resetNilaiForm() {
  nilaiForm.value.id_kelas = NILAI_ID_KELAS
  nilaiForm.value.id_mk = NILAI_ID_MK
  nilaiForm.value.nim = ''
  nilaiForm.value.nama = ''
  nilaiForm.value.participation_score = ''
  nilaiForm.value.assignment_score = ''
  nilaiForm.value.quiz_score = ''
  nilaiForm.value.uts_score = ''
  nilaiForm.value.uas_score = ''
}

async function refreshData() {
  if (props.page === 'profil') {
    return
  }

  if (props.page === 'kelas') {
    await ambilKelasSaya()
    return
  }

  if (props.page === 'dashboard') {
    await ambilKelasSaya()
    await ambilRekapAbsensi(false)
    return
  }

  if (props.page === 'nilai') {
    await ambilKelasSaya()
    await ambilDaftarNilai(false)
    return
  }

  if (props.page === 'presensi') {
    await ambilKelasSaya()
    await ambilPresensiHariIni(false)
    await ambilRekapAbsensi(false)
    return
  }

  if (props.page === 'validasi-krs') {
    await loadKrsData()
  }
}

function initProfileForm() {
  const clean = getCleanProfile()

  profileForm.value = {
    nama: clean.nama || '',
    email: clean.email || '',
    nip: clean.nip || '',
    jabatan: formatJabatan(clean.jabatan),
    alamat: clean.alamat || '',
  }
}

async function saveProfile() {
  const updatedUser = {
    ...user.value,
    email: profileForm.value.email,
    EMAIL: profileForm.value.email,
    alamat: profileForm.value.alamat,
    ALAMAT: profileForm.value.alamat,
    role: 'dosen',
    tipe: 'dosen',
  }

  user.value = updatedUser
  localStorage.setItem('simpadu_user', JSON.stringify(updatedUser))

  try {
    await api.put(ENDPOINTS.pegawai.updateProfile, {
      alamat: profileForm.value.alamat || '',
      jenis_kelamin: user.value.jk || user.value.jenis_kelamin || user.value.JENIS_KELAMIN || 'L',
    })
    setMessage('success', 'Profil berhasil diperbarui. Email dan alamat berhasil disimpan.')
  } catch {
    setMessage('info', 'Profil tersimpan di browser. API profil belum bisa menerima perubahan.')
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

onMounted(() => {
  initProfileForm()
  loadData()
})

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

.dashboard-layout {
  min-height: 100vh;
  display: flex;
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.08), transparent 28%),
    linear-gradient(135deg, #f8fafc 0%, #eef2f7 100%);
  color: #111827;
  font-family: Inter, "Segoe UI", Arial, sans-serif;
}

/* SIDEBAR - dibuat mirip Admin */
.side-nav {
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

.mini-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  margin-bottom: 28px;
  text-decoration: none;
  color: inherit;
  cursor: pointer;
}

.mini-brand img {
  width: 46px;
  height: 46px;
  border-radius: 15px;
  object-fit: contain;
  background: #ffffff;
  padding: 6px;
}

.mini-brand h3 {
  margin: 0;
  line-height: 1;
  font-size: 24px;
  font-weight: 900;
  letter-spacing: -0.6px;
}

.mini-brand span {
  display: block;
  margin-top: 5px;
  color: #c7d2fe;
  font-size: 11px;
  font-weight: 700;
}

.side-nav nav {
  display: grid;
  gap: 10px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 46px;
  padding: 12px 15px;
  color: #e5eefb;
  text-decoration: none;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 800;
  transition: 0.2s ease;
}

.menu-item:hover,
.menu-item.router-link-active,
.menu-item.router-link-exact-active {
  background: #ffd21e;
  color: #06152b;
  transform: translateX(2px);
}

.user-chip {
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
}

.avatar {
  width: 42px;
  height: 42px;
  border-radius: 16px;
  display: grid;
  place-items: center;
  flex: 0 0 42px;
  background: #ffd21e;
  color: #06152b;
  font-weight: 900;
}

.user-chip strong {
  display: block;
  color: #ffffff;
  font-size: 13px;
  font-weight: 900;
}

.user-chip small {
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
  transition: 0.2s ease;
}

.logout-btn:hover {
  background: #f8fafc;
  transform: translateY(-1px);
}

/* MAIN AREA */
.workspace {
  flex: 1;
  min-width: 0;
  padding: 28px;
  background: transparent;
}

.workspace-top {
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

.workspace-top h1 {
  margin: 0;
  color: #111827;
  font-size: 24px;
  font-weight: 900;
  letter-spacing: -0.5px;
}

.workspace-top p {
  margin: 6px 0 0;
  color: #64748b;
  font-size: 14px;
  font-weight: 600;
}

.top-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
  flex: 0 0 auto;
}


.refresh-btn {
  border: none;
  border-radius: 14px;
  padding: 12px 18px;
  font-weight: 900;
  cursor: pointer;
  background: #062b49;
  color: #ffffff;
  box-shadow: 0 12px 24px rgba(6, 43, 73, 0.16);
  transition: transform 0.2s ease, box-shadow 0.2s ease, opacity 0.2s ease;
}

.refresh-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 16px 28px rgba(6, 43, 73, 0.2);
}

.refresh-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}


.top-action-btn {
  height: 42px;
  padding: 0 16px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #ffffff;
  border: 1px solid #d8e2ef;
  color: #062b49;
  border-radius: 14px;
  font-weight: 800;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.02);
}

.top-action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 18px rgba(15, 23, 42, 0.06);
}


.top-action-btn:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.page-section {
  padding: 26px 0 44px;
}

.loading-text {
  margin: 18px 0 0;
  color: #64748b;
  font-weight: 700;
}

.app-message {
  margin-top: 18px;
  padding: 13px 16px;
  border-radius: 16px;
  font-weight: 800;
  font-size: 14px;
}

.app-message.success {
  background: #dcfce7;
  color: #166534;
}

.app-message.error {
  background: #fee2e2;
  color: #991b1b;
}

.app-message.info {
  background: #dbeafe;
  color: #1e40af;
}

/* SHARED CARDS */
.white-card,
.welcome-card,
.profile-hero-card,
.profile-form-card,
.presensi-panel,
.empty-kelas,
.qr-modal {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06);
}

.white-card,
.presensi-panel {
  padding: 24px;
}

.white-card h3,
.presensi-panel h2,
.profile-form-card h3 {
  margin: 0 0 16px;
  color: #111827;
  font-size: 18px;
  font-weight: 900;
}

.eyebrow {
  margin: 0 0 8px;
  color: #0b4b84;
  font-size: 12px;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

/* PROFILE */
.profile-page {
  max-width: 920px;
}

.profile-hero-card {
  padding: 28px;
  margin-bottom: 22px;
  display: flex;
  align-items: center;
  gap: 22px;
}

.profile-avatar {
  width: 96px;
  height: 96px;
  border-radius: 28px;
  display: grid;
  place-items: center;
  background: #ffd21e;
  color: #06152b;
  font-size: 42px;
  font-weight: 900;
}

.profile-hero-card h2 {
  margin: 0 0 6px;
  font-size: 28px;
  font-weight: 900;
  color: #111827;
}

.profile-hero-card p {
  color: #64748b;
}

.profile-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 12px;
}

.profile-meta span {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 999px;
  padding: 8px 12px;
  color: #64748b;
  font-size: 12px;
  font-weight: 800;
}

.profile-form-card {
  padding: 24px;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18px;
}

.form-grid label,
.nilai-grid label {
  display: grid;
  gap: 8px;
}

.form-grid label.full {
  grid-column: 1 / -1;
}

.form-grid span,
.nilai-grid span {
  color: #475569;
  font-size: 12px;
  font-weight: 900;
}

.form-grid input,
.form-grid textarea,
.nilai-grid input,
.nilai-grid textarea,
.nilai-input,
.kelas-select,
.presensi-panel textarea,
.kelas-textarea,
.peserta-add-grid input,
.manual-field input,
.manual-field select {
  width: 100%;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 12px 14px;
  outline: none;
  background: #ffffff;
  color: #111827;
  transition: 0.2s ease;
}

.form-grid input:focus,
.form-grid textarea:focus,
.nilai-grid input:focus,
.nilai-input:focus,
.kelas-select:focus,
.presensi-panel textarea:focus,
.kelas-textarea:focus,
.peserta-add-grid input:focus,
.manual-field input:focus,
.manual-field select:focus {
  border-color: #0b55a0;
  box-shadow: 0 0 0 4px rgba(11, 85, 160, 0.12);
}

.form-grid textarea,
.nilai-grid textarea,
.presensi-panel textarea,
.kelas-textarea {
  min-height: 92px;
  resize: none;
}

.form-actions {
  margin-top: 22px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.primary-btn,
.refresh-btn,
.save-nilai-btn,
.save-presensi,
.start-btn,
.manual-presensi-btn {
  border: none;
  border-radius: 14px;
  padding: 12px 18px;
  background: #062b49;
  color: #ffffff;
  font-weight: 900;
  cursor: pointer;
  transition: 0.2s ease;
  box-shadow: 0 12px 24px rgba(6, 43, 73, 0.16);
}

.primary-btn:hover,
.refresh-btn:hover,
.save-nilai-btn:hover,
.save-presensi:hover,
.start-btn:hover,
.manual-presensi-btn:hover {
  background: #0a3b63;
  transform: translateY(-1px);
}

.primary-btn:disabled,
.refresh-btn:disabled,
.save-nilai-btn:disabled,
.save-presensi:disabled,
.start-btn:disabled,
.manual-presensi-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

/* DASHBOARD */
.welcome-card {
  padding: 28px;
  margin-bottom: 22px;
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.18), transparent 34%),
    #ffffff;
}

.welcome-card h2 {
  margin: 0;
  color: #111827;
  font-size: 30px;
  font-weight: 900;
  letter-spacing: -0.7px;
}

.welcome-card p {
  margin: 8px 0 0;
  color: #64748b;
  font-size: 15px;
}

.stats-row {
  display: grid;
  gap: 18px;
  margin-bottom: 22px;
}

.stats-row.four {
  grid-template-columns: repeat(4, minmax(160px, 1fr));
}

.metric-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 24px;
  padding: 20px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.05);
}

.metric-card small {
  display: block;
  color: #64748b;
  font-size: 12px;
  font-weight: 900;
}

.metric-card strong {
  display: block;
  margin-top: 8px;
  color: #111827;
  font-size: 34px;
  line-height: 1;
  font-weight: 900;
}

.green-text strong {
  color: #059669;
}

.orange-text strong {
  color: #d97706;
}

.red-text strong {
  color: #dc2626;
}

.split-grid,
.nilai-layout,
.presensi-layout {
  display: grid;
  grid-template-columns: minmax(520px, 680px) minmax(420px, 520px);
  gap: 24px;
  align-items: start;
  max-width: 1140px;
  margin: 0 auto;
}

.presensi-panel,
.history-card {
  width: 100%;
}

@media (max-width: 1100px) {
  .presensi-layout {
    grid-template-columns: 1fr;
    max-width: 680px;
  }
}

/* Biar card Presensi & Riwayat sejajar (tinggi sama) */
.presensi-panel,
.history-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.history-list {
  flex: 1;
  overflow: auto;
  padding-right: 4px;
}

@media (max-width: 980px) {
  .presensi-panel,
  .history-card {
    height: auto;
  }
}


.schedule-item,
.history-item,
.nilai-item {
  padding: 14px;
  border-radius: 18px;
  background: #f8fafc;
  border: 1px solid #edf2f7;
  margin-bottom: 12px;
}

.schedule-item {
  display: grid;
  grid-template-columns: 110px 1fr auto;
  gap: 12px;
  align-items: center;
}

.schedule-item b,
.history-item strong,
.nilai-info strong {
  display: block;
  color: #111827;
  font-size: 14px;
  font-weight: 900;
}

.schedule-item span,
.history-item p,
.nilai-info p {
  color: #64748b;
  font-size: 12px;
}

.schedule-item em {
  font-style: normal;
  background: #eef6ff;
  color: #062b49;
  border-radius: 999px;
  padding: 7px 12px;
  font-size: 12px;
  font-weight: 900;
}

/* KELAS */
.kelas-header,
.content-header,
.presensi-page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  margin-bottom: 22px;
}

.kelas-header h2,
.content-header h2,
.presensi-page-header h2 {
  margin: 0;
  color: #111827;
  font-size: 24px;
  font-weight: 900;
}

.kelas-header p,
.content-header p,
.presensi-page-header p {
  margin: 6px 0 0;
  color: #64748b;
}

.kelas-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(280px, 1fr));
  gap: 22px;
}

.kelas-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  padding: 22px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06);
}

.kelas-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.kelas-icon {
  width: 42px;
  height: 42px;
  border-radius: 15px;
  background: #eff6ff;
  display: grid;
  place-items: center;
}

.kelas-status {
  border-radius: 999px;
  padding: 7px 12px;
  background: #eef6ff;
  color: #062b49;
  font-size: 12px;
  font-weight: 900;
}

.kelas-status.active {
  background: #dcfce7;
  color: #166534;
}

.kelas-card h3 {
  margin: 0;
  color: #111827;
  font-size: 20px;
  font-weight: 900;
}

.kelas-code {
  margin: 6px 0 16px;
  color: #64748b;
  font-size: 13px;
  font-weight: 700;
}

.kelas-info {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  padding: 14px;
  border-radius: 18px;
  background: #f8fafc;
  border: 1px solid #edf2f7;
  margin-bottom: 16px;
}

.kelas-info small {
  display: block;
  color: #64748b;
  font-size: 11px;
  font-weight: 900;
}

.kelas-info strong {
  display: block;
  margin-top: 4px;
  color: #111827;
  font-size: 14px;
  font-weight: 900;
}

.kelas-detail {
  display: grid;
  gap: 8px;
  margin-bottom: 14px;
}

.kelas-detail p {
  margin: 0;
  color: #64748b;
  font-size: 13px;
}

.kelas-detail b {
  color: #111827;
}

.kelas-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin: 14px 0;
}

.end-btn {
  border: none;
  border-radius: 14px;
  padding: 12px 18px;
  background: #ef4444;
  color: #ffffff;
  font-weight: 900;
  cursor: pointer;
  transition: 0.2s ease;
}

.end-btn:hover {
  background: #dc2626;
  transform: translateY(-1px);
}

.qr-demo-btn {
  grid-column: 1 / -1;
  border: none;
  border-radius: 14px;
  padding: 12px 18px;
  background: #ffd21e;
  color: #06152b;
  font-weight: 900;
  cursor: pointer;
}

/* PESERTA & MANUAL */
.peserta-kelas-card,
.manual-presensi-card {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 20px;
  padding: 16px;
  margin-top: 14px;
}

.peserta-kelas-head,
.manual-presensi-head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.peserta-kelas-head h4,
.manual-presensi-head h4 {
  margin: 0;
  color: #111827;
  font-size: 15px;
  font-weight: 900;
}

.peserta-kelas-head p,
.manual-presensi-head p {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 12px;
}

.peserta-list {
  display: grid;
  gap: 10px;
}

.peserta-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  background: #ffffff;
  border: 1px solid #edf2f7;
  border-radius: 14px;
  padding: 10px 12px;
}

.peserta-item strong {
  display: block;
  color: #111827;
  font-size: 13px;
  font-weight: 900;
}

.peserta-item small {
  color: #64748b;
  font-size: 12px;
}

.peserta-item button {
  border: none;
  background: #fee2e2;
  color: #991b1b;
  border-radius: 10px;
  padding: 8px 10px;
  font-weight: 900;
  cursor: pointer;
}

.peserta-add-grid {
  display: grid;
  grid-template-columns: 1fr 1fr auto;
  gap: 10px;
  margin-top: 14px;
}

.peserta-add-grid button {
  border: none;
  border-radius: 12px;
  background: #062b49;
  color: #ffffff;
  padding: 11px 14px;
  font-weight: 900;
  cursor: pointer;
}

.manual-presensi-card {
  display: grid;
  gap: 14px;
}

.manual-field {
  display: grid;
  gap: 6px;
}

.manual-field label {
  color: #475569;
  font-size: 11px;
  font-weight: 900;
}

.manual-presensi-grid {
  display: grid;
  grid-template-columns: 0.85fr 1fr 0.9fr;
  gap: 10px;
}

.manual-field input[readonly] {
  background: #f1f5f9;
  color: #64748b;
  cursor: not-allowed;
}

.manual-presensi-btn {
  width: 100%;
}


/* PRESENSI MANUAL MAHASISWA - MOBILE STYLE */
.manual-mobile-card {
  overflow: hidden;
  margin-top: 16px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 0 0 26px 26px;
  box-shadow: 0 14px 28px rgba(15, 23, 42, 0.06);
}

.manual-mobile-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 18px 28px;
  border-bottom: 1px solid #e5e7eb;
  background: #ffffff;
}

.manual-mobile-head h4 {
  margin: 0;
  color: #202124;
  font-size: 25px;
  font-weight: 900;
  letter-spacing: -0.5px;
}

.manual-mobile-head span {
  white-space: nowrap;
  color: #9ca3af;
  font-size: 20px;
  font-weight: 900;
}

.manual-student-row {
  padding: 28px;
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
}

.manual-student-info {
  display: grid;
  gap: 8px;
  margin-bottom: 22px;
}

.manual-student-info strong {
  color: #202124;
  font-size: 23px;
  line-height: 1.1;
  font-weight: 900;
}

.manual-student-info small {
  color: #9ca3af;
  font-size: 19px;
  font-weight: 700;
}

.manual-status-row {
  display: grid;
  grid-template-columns: repeat(4, 66px);
  justify-content: space-between;
  align-items: center;
  gap: 18px;
}

.manual-status-pill {
  width: 66px;
  height: 54px;
  border: 1px solid #dedede !important;
  border-radius: 999px;
  background: #f5f5f5 !important;
  color: #777777 !important;
  font-size: 18px;
  font-weight: 900;
  cursor: pointer;
  transition: 0.18s ease;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.65);
}

.manual-status-pill:hover {
  transform: translateY(-1px);
}

.manual-status-pill.active {
  background: #062b49 !important;
  color: #ffffff !important;
  border-color: #062b49 !important;
  box-shadow: 0 8px 18px rgba(6, 43, 73, 0.22) !important;
}

.manual-empty-text {
  margin: 0;
  padding: 24px 28px;
  color: #9ca3af;
  font-weight: 800;
}

.manual-mobile-footer {
  padding: 30px 28px 28px;
  background: #ffffff;
}

.manual-save-mobile-btn {
  width: 100%;
  min-height: 76px;
  border: none;
  border-radius: 14px;
  background: #062b49;
  color: #ffffff;
  font-size: 23px;
  font-weight: 900;
  cursor: pointer;
  box-shadow: 0 4px 8px rgba(6, 43, 73, 0.2);
  transition: 0.18s ease;
}

.manual-save-mobile-btn:hover {
  background: #0b4b84;
  transform: translateY(-1px);
}

.manual-save-mobile-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

@media (max-width: 720px) {
  .manual-mobile-head {
    padding: 14px 18px;
  }

  .manual-mobile-head h4 {
    font-size: 20px;
  }

  .manual-mobile-head span {
    font-size: 15px;
  }

  .manual-student-row {
    padding: 22px 18px;
  }

  .manual-status-row {
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
  }

  .manual-status-pill {
    width: 100%;
    height: 50px;
  }

  .manual-save-mobile-btn {
    min-height: 62px;
    font-size: 18px;
  }
}

/* INPUT NILAI */
.nilai-layout {
  grid-template-columns: minmax(360px, 0.95fr) minmax(440px, 1.05fr);
}

.nilai-id-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 16px;
}

.nilai-id-grid label {
  display: grid;
  gap: 8px;
}

.nilai-id-grid span,
.nilai-label {
  color: #475569;
  font-size: 12px;
  font-weight: 900;
}

.nilai-id-grid input {
  width: 100%;
  height: 46px;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 0 14px;
  background: #f3f4f6;
  color: #475569;
  font-weight: 900;
}

.nilai-label {
  display: block;
  margin: 16px 0 8px;
}

.nilai-input {
  height: 48px;
}

.nilai-grid {
  margin-top: 18px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.nilai-grid input:disabled,
.nilai-grid input[readonly] {
  background: #f3f4f6;
  color: #475569;
  font-weight: 900;
  cursor: not-allowed;
}

.save-nilai-btn {
  width: 100%;
  margin-top: 20px;
}

.nilai-item {
  display: grid;
  grid-template-columns: 1fr auto;
  grid-template-areas:
    "info final"
    "scores scores";
  gap: 14px;
  align-items: center;
  padding: 16px;
}

.nilai-info {
  grid-area: info;
  min-width: 0;
}

.nilai-breakdown {
  grid-area: scores;
  display: grid;
  grid-template-columns: repeat(5, minmax(70px, 1fr));
  gap: 10px;
}

.nilai-breakdown div {
  min-height: 58px;
  background: #ffffff;
  border: 1px solid #dbe6f2;
  border-radius: 14px;
  padding: 9px 8px;
  text-align: center;
  display: grid;
  align-content: center;
}

.nilai-breakdown small {
  display: block;
  color: #64748b;
  font-size: 9px;
  font-weight: 900;
  line-height: 1.1;
  text-transform: uppercase;
}

.nilai-breakdown b {
  display: block;
  margin-top: 5px;
  color: #111827;
  font-size: 18px;
  line-height: 1;
  font-weight: 900;
}

.nilai-score {
  grid-area: final;
  min-width: 88px;
  text-align: center;
  background: #e0f2fe;
  color: #062b49;
  border-radius: 18px;
  padding: 12px 14px;
}

.nilai-score small {
  display: block;
  font-size: 10px;
  font-weight: 900;
}

.nilai-score b {
  display: block;
  margin-top: 4px;
  font-size: 30px;
  line-height: 1;
  font-weight: 900;
}

.nilai-score span {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  min-width: 36px;
  margin-top: 8px;
  padding: 5px 10px;
  border-radius: 999px;
  background: #062b49;
  color: #ffffff;
  font-size: 12px;
  font-weight: 900;
}

/* PRESENSI */
.presensi-layout {
  grid-template-columns: minmax(360px, 0.95fr) minmax(420px, 1.05fr);
}

.presensi-icon {
  width: 54px;
  height: 54px;
  border-radius: 18px;
  background: #dcfce7;
  display: grid;
  place-items: center;
  font-size: 24px;
  margin-bottom: 14px;
}

.presensi-subtitle {
  margin: 8px 0 20px;
  color: #64748b;
}

.presensi-label {
  display: block;
  margin: 16px 0 8px;
  color: #475569;
  font-size: 12px;
  font-weight: 900;
}

.attendance-buttons {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 10px;
}

.attendance-buttons button {
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 12px 8px;
  background: #ffffff;
  color: #111827;
  font-weight: 900;
  cursor: pointer;
  transition: 0.2s ease;
}

.attendance-buttons button:hover {
  border-color: #062b49;
  background: #f8fafc;
}

.attendance-buttons button.active {
  background: #062b49;
  color: #ffffff;
  border-color: #062b49;
}

.attendance-buttons button span {
  display: block;
  margin-top: 4px;
  font-size: 11px;
}

.presensi-summary {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin: 18px 0;
}

.presensi-summary div {
  background: #f8fafc;
  border: 1px solid #edf2f7;
  border-radius: 16px;
  padding: 12px;
}

.presensi-summary small {
  display: block;
  color: #64748b;
  font-size: 11px;
  font-weight: 900;
}

.presensi-summary strong {
  display: block;
  margin-top: 4px;
  color: #111827;
  font-size: 13px;
}

.save-presensi {
  width: 100%;
  background: #059669;
}

.save-presensi:hover {
  background: #047857;
}

.history-item {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  align-items: center;
}

.pill {
  border-radius: 999px;
  padding: 7px 12px;
  font-size: 12px;
  font-weight: 900;
}

.pill.ok {
  background: #dcfce7;
  color: #166534;
}

.pill.warn {
  background: #fef3c7;
  color: #92400e;
}

.pill.danger {
  background: #fee2e2;
  color: #991b1b;
}

.empty-history,
.empty-peserta {
  margin: 0;
  color: #64748b;
  font-size: 13px;
  font-weight: 700;
}

.empty-kelas {
  padding: 42px;
  text-align: center;
}

.empty-kelas div {
  font-size: 44px;
}

.empty-kelas h3 {
  margin: 10px 0 4px;
  color: #111827;
  font-size: 22px;
  font-weight: 900;
}

.empty-kelas p {
  color: #64748b;
}

/* QR MODAL */
.qr-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  padding: 20px;
  display: grid;
  place-items: center;
  background: rgba(15, 23, 42, 0.55);
}

.qr-modal {
  width: min(420px, 100%);
  padding: 26px;
  text-align: center;
  position: relative;
}

.qr-modal-close {
  position: absolute;
  top: 14px;
  right: 14px;
  border: none;
  background: #f3f4f6;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  cursor: pointer;
  font-weight: 900;
}

.qr-modal h2 {
  margin: 0;
  color: #111827;
  font-size: 24px;
  font-weight: 900;
}

.qr-modal-box {
  margin: 20px auto;
  width: 280px;
  height: 280px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  display: grid;
  place-items: center;
}

.qr-modal-box img {
  max-width: 250px;
  max-height: 250px;
}

.qr-modal-note {
  color: #64748b;
  font-size: 13px;
}

/* RESPONSIVE */
@media (max-width: 1280px) {
  .kelas-grid {
    grid-template-columns: repeat(2, minmax(280px, 1fr));
  }

  .stats-row.four {
    grid-template-columns: repeat(2, minmax(160px, 1fr));
  }

  .split-grid,
  .nilai-layout,
  .presensi-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 860px) {
  .dashboard-layout {
    flex-direction: column;
  }

  .side-nav {
    width: 100%;
    min-height: auto;
    position: relative;
  }

  .workspace {
    padding: 18px;
  }

  .workspace-top,
  .kelas-header,
  .content-header,
  .presensi-page-header,
  .profile-hero-card {
    align-items: flex-start;
    flex-direction: column;
  }

  .kelas-grid,
  .stats-row.four,
  .form-grid,
  .nilai-grid,
  .nilai-id-grid,
  .peserta-add-grid,
  .manual-presensi-grid,
  .attendance-buttons,
  .presensi-summary {
    grid-template-columns: 1fr;
  }

  .schedule-item {
    grid-template-columns: 1fr;
  }

  .nilai-item {
    grid-template-columns: 1fr;
    grid-template-areas:
      "info"
      "scores"
      "final";
  }

  .nilai-score {
    width: 100%;
  }

  .nilai-breakdown {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .profile-hero-card {
    text-align: left;
  }
}

@media (max-width: 520px) {
  .workspace {
    padding: 14px;
  }

  .white-card,
  .profile-hero-card,
  .profile-form-card,
  .presensi-panel,
  .kelas-card {
    border-radius: 22px;
    padding: 18px;
  }

  .welcome-card h2 {
    font-size: 24px;
  }

  .workspace-top h1 {
    font-size: 21px;
  }
}


/* PRESENSI HEADER - dibuat mirip dashboard dosen */
.presensi-welcome-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 28px;
  margin-bottom: 22px;
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.18), transparent 34%),
    #ffffff !important;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06);
}

.presensi-welcome-card h2 {
  margin: 0;
  color: #111827;
  font-size: 30px;
  font-weight: 900;
  letter-spacing: -0.7px;
}

.presensi-welcome-card p {
  margin: 8px 0 0;
  color: #64748b;
  font-size: 15px;
  font-weight: 700;
}

.presensi-welcome-card .refresh-btn {
  flex: 0 0 auto;
}

/* Pastikan header presensi tidak menggunakan style biru lama */
.presensi-page-header {
  background: transparent !important;
  color: inherit !important;
}

@media (max-width: 840px) {
  .presensi-welcome-card {
    align-items: flex-start;
    flex-direction: column;
  }
}



/* =========================================================
   CLEAN UI OVERRIDE - DOSEN
   Catatan: bagian ini hanya mengubah tampilan.
   Tidak mengubah <script setup>
const logoUrl = '/assets/images/logo-poliban.png', function, endpoint, atau logic.
   ========================================================= */

.dashboard-layout {
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.10), transparent 28%),
    linear-gradient(135deg, #f8fafc 0%, #eef2f7 100%) !important;
  color: #111827 !important;
  font-family: Inter, "Segoe UI", Arial, sans-serif !important;
}

/* SIDEBAR */
.side-nav {
  width: 260px !important;
  background: #062b49 !important;
  color: #ffffff !important;
  padding: 26px 18px 18px !important;
  box-shadow: 18px 0 42px rgba(15, 23, 42, 0.12) !important;
}

.mini-brand {
  padding: 12px !important;
  border-radius: 22px !important;
  background: rgba(255, 255, 255, 0.08) !important;
  border: 1px solid rgba(255, 255, 255, 0.12) !important;
  margin-bottom: 28px !important;
}

.mini-brand img {
  width: 46px !important;
  height: 46px !important;
  border-radius: 15px !important;
  object-fit: contain !important;
  background: #ffffff !important;
  padding: 6px !important;
}

.mini-brand h3 {
  font-size: 24px !important;
  font-weight: 900 !important;
  letter-spacing: -0.6px !important;
}

.mini-brand span {
  color: #c7d2fe !important;
  font-size: 11px !important;
  font-weight: 700 !important;
}

.side-nav nav {
  gap: 10px !important;
}

.menu-item {
  min-height: 46px !important;
  padding: 12px 15px !important;
  color: #e5eefb !important;
  border-radius: 999px !important;
  font-size: 14px !important;
  font-weight: 800 !important;
  transition: 0.2s ease !important;
}

.menu-item:hover,
.menu-item.router-link-active,
.menu-item.router-link-exact-active {
  background: #ffd21e !important;
  color: #06152b !important;
  transform: translateX(2px) !important;
}

.user-chip {
  width: 100% !important;
  margin-top: auto !important;
  padding: 12px !important;
  border-radius: 20px !important;
  border: 1px solid rgba(255, 255, 255, 0.16) !important;
  background: rgba(255, 255, 255, 0.08) !important;
  gap: 12px !important;
}

.user-chip strong {
  color: #ffffff !important;
  font-size: 13px !important;
  font-weight: 900 !important;
}

.user-chip small {
  color: #dbeafe !important;
  font-size: 11px !important;
  font-weight: 700 !important;
}

.avatar,
.profile-avatar,
.profile-avatar,
.kelas-icon {
  background: #ffd21e !important;
  color: #06152b !important;
  font-weight: 900 !important;
}

.logout-btn {
  width: 100% !important;
  margin-top: 12px !important;
  border: none !important;
  border-radius: 14px !important;
  padding: 11px 14px !important;
  background: #ffffff !important;
  color: #062b49 !important;
  font-weight: 900 !important;
  cursor: pointer !important;
  transition: 0.2s ease !important;
}

.logout-btn:hover {
  background: #f8fafc !important;
  transform: translateY(-1px) !important;
}

/* MAIN LAYOUT */
.workspace {
  background: transparent !important;
  flex: 1 !important;
  min-width: 0 !important;
}

.workspace-top {
  min-height: 78px !important;
  margin: 28px 28px 0 !important;
  padding: 18px 22px !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 26px !important;
  background: rgba(255, 255, 255, 0.92) !important;
  backdrop-filter: blur(14px) !important;
  box-shadow: 0 18px 36px rgba(15, 23, 42, 0.06) !important;
}

.workspace-top h1 {
  color: #111827 !important;
  font-size: 24px !important;
  font-weight: 900 !important;
  letter-spacing: -0.5px !important;
}

.workspace-top p {
  color: #64748b !important;
  font-size: 14px !important;
  font-weight: 600 !important;
}

.top-actions {
  background: #ffffff !important;
  border: 1px solid #e5e7eb !important;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.08) !important;
}

.page-section {
  padding: 26px 28px 44px !important;
}

.loading-text {
  color: #64748b !important;
  font-weight: 800 !important;
}

.app-message {
  margin: 18px 28px 0 !important;
  border-radius: 16px !important;
  font-weight: 800 !important;
  box-shadow: 0 12px 26px rgba(15, 23, 42, 0.05) !important;
}

/* SHARED CARDS */
.welcome-card,
.white-card,
.profile-hero-card,
.profile-form-card,
.kelas-card,
.empty-kelas,
.presensi-panel,
.qr-modal,
.profile-form,
.nilai-form-card,
.nilai-list-card,
.history-card {
  background: #ffffff !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 26px !important;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06) !important;
}

.welcome-card,
.presensi-welcome-card {
  padding: 28px !important;
  margin-bottom: 22px !important;
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.18), transparent 34%),
    #ffffff !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 26px !important;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06) !important;
}

.welcome-card h2,
.presensi-welcome-card h2 {
  margin: 0 !important;
  color: #111827 !important;
  font-size: 30px !important;
  font-weight: 900 !important;
  letter-spacing: -0.7px !important;
}

.welcome-card p,
.presensi-welcome-card p {
  margin: 8px 0 0 !important;
  color: #64748b !important;
  font-size: 15px !important;
  font-weight: 700 !important;
}

/* BUTTONS */
.primary-btn,
.refresh-btn,
.start-btn,
.manual-presensi-btn,
.save-presensi,
.save-nilai-btn {
  border: none !important;
  border-radius: 14px !important;
  background: #062b49 !important;
  color: #ffffff !important;
  font-weight: 900 !important;
  cursor: pointer !important;
  box-shadow: 0 12px 24px rgba(6, 43, 73, 0.16) !important;
  transition: 0.2s ease !important;
}

.primary-btn:hover,
.refresh-btn:hover,
.start-btn:hover,
.manual-presensi-btn:hover,
.save-presensi:hover,
.save-nilai-btn:hover {
  background: #0a3b63 !important;
  transform: translateY(-1px) !important;
}

.end-btn {
  background: #ef4444 !important;
  box-shadow: 0 12px 24px rgba(239, 68, 68, 0.16) !important;
}

.end-btn:hover {
  background: #dc2626 !important;
}

.qr-demo-btn {
  background: #ffd21e !important;
  color: #06152b !important;
  box-shadow: 0 12px 24px rgba(255, 210, 30, 0.18) !important;
}

/* DASHBOARD */
.stats-row {
  gap: 18px !important;
  margin-bottom: 22px !important;
}

.metric-card {
  background: #ffffff !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 24px !important;
  padding: 22px !important;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.05) !important;
}

.metric-card small {
  color: #64748b !important;
  font-size: 12px !important;
  font-weight: 900 !important;
}

.metric-card strong {
  margin-top: 8px !important;
  color: #111827 !important;
  font-size: 34px !important;
  font-weight: 900 !important;
}

.green-text strong {
  color: #059669 !important;
}

.orange-text strong {
  color: #d97706 !important;
}

.red-text strong {
  color: #dc2626 !important;
}

.split-grid {
  gap: 22px !important;
}

.white-card {
  padding: 24px !important;
}

.white-card h3,
.nilai-form-card h3,
.nilai-list-card h3,
.history-card h3,
.presensi-panel h2 {
  color: #111827 !important;
  font-weight: 900 !important;
}

.schedule-item,
.history-item,
.nilai-item,
.peserta-item,
.list-row {
  background: #f8fafc !important;
  border: 1px solid #edf2f7 !important;
  border-radius: 18px !important;
}

/* PROFILE */
.profile-page {
  max-width: 920px !important;
}

.profile-hero-card {
  padding: 28px !important;
}

.profile-avatar {
  width: 96px !important;
  height: 96px !important;
  border-radius: 28px !important;
  font-size: 42px !important;
}

.profile-hero-card h2 {
  color: #111827 !important;
  font-size: 28px !important;
  font-weight: 900 !important;
}

.profile-meta {
  color: #64748b !important;
}

.form-grid span,
.nilai-grid span,
.nilai-id-grid span,
.manual-field label,
.presensi-label,
.nilai-label,
.profile-form-card label {
  color: #475569 !important;
  font-size: 12px !important;
  font-weight: 900 !important;
}

.form-grid input,
.form-grid textarea,
.nilai-grid input,
.nilai-input,
.nilai-id-grid input,
.manual-field input,
.manual-field select,
.kelas-select,
.presensi-panel textarea,
.peserta-add-grid input,
.manual-presensi-card textarea,
.kelas-textarea {
  border: 1px solid #d8e2ef !important;
  border-radius: 14px !important;
  background: #ffffff !important;
  color: #111827 !important;
  outline: none !important;
  transition: 0.2s ease !important;
}

.form-grid input:focus,
.form-grid textarea:focus,
.nilai-grid input:focus,
.nilai-input:focus,
.manual-field input:focus,
.manual-field select:focus,
.kelas-select:focus,
.presensi-panel textarea:focus,
.peserta-add-grid input:focus,
.kelas-textarea:focus {
  border-color: #0b55a0 !important;
  box-shadow: 0 0 0 4px rgba(11, 85, 160, 0.12) !important;
}

/* KELAS */
.kelas-header,
.content-header,
.presensi-page-header {
  margin-bottom: 22px !important;
}

.kelas-header h2,
.content-header h2,
.presensi-page-header h2 {
  color: #111827 !important;
  font-size: 24px !important;
  font-weight: 900 !important;
}

.kelas-header p,
.content-header p,
.presensi-page-header p {
  color: #64748b !important;
  font-weight: 600 !important;
}

.kelas-grid {
  gap: 22px !important;
}

.kelas-card {
  border-top: 0 !important;
  padding: 22px !important;
  overflow: hidden !important;
}

.kelas-card-top {
  margin-bottom: 16px !important;
}

.kelas-icon {
  width: 44px !important;
  height: 44px !important;
  border-radius: 16px !important;
}

.kelas-status {
  background: #eef6ff !important;
  color: #062b49 !important;
  font-weight: 900 !important;
}

.kelas-status.active {
  background: #dcfce7 !important;
  color: #166534 !important;
}

.kelas-card h3 {
  color: #111827 !important;
  font-weight: 900 !important;
}

.kelas-code,
.kelas-detail p,
.peserta-kelas-head p,
.manual-presensi-head p {
  color: #64748b !important;
}

.kelas-info,
.peserta-kelas-card,
.manual-presensi-card {
  background: #f8fafc !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 18px !important;
}

.peserta-kelas-head h4,
.manual-presensi-head h4 {
  color: #111827 !important;
  font-weight: 900 !important;
}

.peserta-add-grid button,
.peserta-item button {
  border-radius: 12px !important;
  font-weight: 900 !important;
}

/* NILAI */
.nilai-layout {
  gap: 24px !important;
}

.nilai-item {
  padding: 16px !important;
}

.nilai-info strong {
  color: #111827 !important;
  font-weight: 900 !important;
}

.nilai-info p {
  color: #64748b !important;
}

.nilai-breakdown div {
  background: #ffffff !important;
  border: 1px solid #dbe6f2 !important;
  border-radius: 14px !important;
}

.nilai-breakdown small {
  color: #64748b !important;
  font-weight: 900 !important;
}

.nilai-breakdown b {
  color: #111827 !important;
  font-weight: 900 !important;
}

.nilai-score {
  background: #e0f2fe !important;
  color: #062b49 !important;
  border-radius: 18px !important;
}

/* PRESENSI */
.presensi-layout {
  gap: 24px !important;
}

.presensi-panel {
  padding: 26px !important;
}

.presensi-icon {
  background: #dcfce7 !important;
  border-radius: 18px !important;
}

.presensi-subtitle {
  color: #64748b !important;
  font-weight: 600 !important;
}

.attendance-buttons {
  gap: 10px !important;
}

.attendance-buttons button {
  border: 1px solid #d8e2ef !important;
  background: #ffffff !important;
  color: #111827 !important;
  border-radius: 16px !important;
  font-weight: 900 !important;
  transition: 0.2s ease !important;
}

.attendance-buttons button:hover {
  border-color: #062b49 !important;
  background: #f8fafc !important;
}

.attendance-buttons button.active {
  border-color: #ffd21e !important;
  background: #fff7cc !important;
  color: #06152b !important;
}

.presensi-summary div {
  background: #f8fafc !important;
  border: 1px solid #edf2f7 !important;
  border-radius: 16px !important;
}

.presensi-summary small {
  color: #64748b !important;
  font-weight: 900 !important;
}

.presensi-summary strong {
  color: #111827 !important;
  font-weight: 900 !important;
}

.pill {
  border-radius: 999px !important;
  padding: 7px 12px !important;
  font-size: 12px !important;
  font-weight: 900 !important;
}

.pill.ok {
  background: #dcfce7 !important;
  color: #166534 !important;
}

.pill.warn {
  background: #fef3c7 !important;
  color: #92400e !important;
}

.pill.danger {
  background: #fee2e2 !important;
  color: #991b1b !important;
}

/* EMPTY & MODAL */
.empty-history,
.empty-peserta,
.empty-kelas p {
  color: #64748b !important;
  font-weight: 700 !important;
}

.empty-kelas h3 {
  color: #111827 !important;
  font-weight: 900 !important;
}

.qr-modal-overlay {
  background: rgba(15, 23, 42, 0.55) !important;
  backdrop-filter: blur(5px) !important;
}

.qr-modal {
  border: 1px solid #e5e7eb !important;
}

.qr-modal h2 {
  color: #111827 !important;
  font-weight: 900 !important;
}

/* RESPONSIVE */
@media (max-width: 1180px) {
  .stats-row.four {
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
  }

  .kelas-grid {
    grid-template-columns: repeat(2, minmax(260px, 1fr)) !important;
  }

  .split-grid,
  .nilai-layout,
  .presensi-layout {
    grid-template-columns: 1fr !important;
  }
}

@media (max-width: 860px) {
  .dashboard-layout {
    flex-direction: column !important;
  }

  .side-nav {
    width: 100% !important;
    min-height: auto !important;
    position: relative !important;
  }

  .workspace-top {
    margin: 18px 18px 0 !important;
  }

  .page-section {
    padding: 22px 18px 36px !important;
  }

  .kelas-grid,
  .stats-row.four,
  .form-grid,
  .nilai-grid,
  .nilai-id-grid,
  .manual-presensi-grid,
  .attendance-buttons,
  .presensi-summary {
    grid-template-columns: 1fr !important;
  }

  .kelas-header,
  .content-header,
  .presensi-page-header,
  .presensi-welcome-card,
  .profile-hero-card {
    align-items: flex-start !important;
    flex-direction: column !important;
  }

  .schedule-item {
    grid-template-columns: 1fr !important;
  }
}



/* UPDATE: profile dipindah ke pojok kiri bawah */
.user-chip {
  text-decoration: none;
  cursor: pointer;
}

.user-chip:hover {
  background: rgba(255, 210, 30, 0.16);
  border-color: rgba(255, 210, 30, 0.45);
  transform: translateY(-1px);
}

/* UPDATE: Presensi dosen harian, bukan per kelas */
.daily-presensi-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin: 18px 0;
}

.daily-presensi-info div {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  padding: 14px;
}

.daily-presensi-info small {
  display: block;
  color: #64748b;
  font-size: 11px;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.daily-presensi-info strong {
  display: block;
  margin-top: 6px;
  color: #111827;
  font-size: 14px;
  font-weight: 900;
}

.presensi-summary {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

@media (max-width: 720px) {
  .daily-presensi-info,
  .presensi-summary {
    grid-template-columns: 1fr;
  }
}



/* =========================================================
   CLEAN UI FINAL DOSEN
   Catatan: CSS ini hanya merapikan tampilan.
   Bagian <script setup>
const logoUrl = '/assets/images/logo-poliban.png' dan semua function tidak diubah.
========================================================= */

.dashboard-layout {
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.08), transparent 28%),
    linear-gradient(135deg, #f8fafc 0%, #eef2f7 100%) !important;
}

.side-nav {
  width: 260px !important;
  background: #062b49 !important;
  padding: 26px 18px 18px !important;
  box-shadow: 18px 0 42px rgba(15, 23, 42, 0.12) !important;
}

.mini-brand {
  padding: 12px !important;
  border-radius: 22px !important;
  background: rgba(255, 255, 255, 0.08) !important;
  border: 1px solid rgba(255, 255, 255, 0.12) !important;
  margin-bottom: 28px !important;
}

.mini-brand img {
  width: 46px !important;
  height: 46px !important;
  border-radius: 15px !important;
  background: #ffffff !important;
  padding: 6px !important;
}

.mini-brand h3 {
  font-size: 24px !important;
  letter-spacing: -0.6px !important;
}

.mini-brand span {
  color: #c7d2fe !important;
  font-size: 11px !important;
  font-weight: 700 !important;
}

.menu-item {
  min-height: 46px !important;
  padding: 12px 15px !important;
  border-radius: 999px !important;
  color: #e5eefb !important;
  font-size: 14px !important;
  font-weight: 800 !important;
}

.menu-item:hover,
.menu-item.router-link-active,
.menu-item.router-link-exact-active {
  background: #ffd21e !important;
  color: #06152b !important;
  transform: translateX(2px);
}

.user-chip {
  margin-top: auto !important;
  border: 1px solid rgba(255, 255, 255, 0.16) !important;
  background: rgba(255, 255, 255, 0.08) !important;
  border-radius: 20px !important;
  padding: 12px !important;
  text-decoration: none !important;
  transition: 0.2s ease !important;
}

.user-chip:hover {
  background: rgba(255, 210, 30, 0.16) !important;
  border-color: rgba(255, 210, 30, 0.45) !important;
  transform: translateY(-1px);
}

.avatar,
.profile-avatar {
  background: #ffd21e !important;
  color: #06152b !important;
  font-weight: 900 !important;
}

.logout-btn {
  border-radius: 14px !important;
  background: #ffffff !important;
  color: #062b49 !important;
  font-weight: 900 !important;
}

.workspace {
  padding: 28px !important;
  background: transparent !important;
}

.workspace-top {
  min-height: 78px !important;
  background: rgba(255, 255, 255, 0.92) !important;
  backdrop-filter: blur(14px) !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 26px !important;
  padding: 18px 22px !important;
  box-shadow: 0 18px 36px rgba(15, 23, 42, 0.06) !important;
}

.workspace-top h1 {
  color: #111827 !important;
  font-size: 24px !important;
  font-weight: 900 !important;
  letter-spacing: -0.5px !important;
}

.workspace-top p {
  color: #64748b !important;
  font-size: 14px !important;
  font-weight: 600 !important;
}

.page-section {
  padding: 26px 0 44px !important;
}

.welcome-card,
.white-card,
.profile-hero-card,
.profile-form-card,
.kelas-card,
.empty-kelas,
.presensi-panel,
.qr-modal {
  background: #ffffff !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 26px !important;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06) !important;
}

.welcome-card,
.presensi-welcome-card {
  position: relative !important;
  padding: 28px !important;
  margin-bottom: 22px !important;
  overflow: hidden !important;
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.18), transparent 34%),
    #ffffff !important;
  color: #111827 !important;
}

.welcome-card::after {
  display: none !important;
}

.welcome-card h2,
.presensi-welcome-card h2 {
  margin: 0 !important;
  color: #111827 !important;
  font-size: 30px !important;
  font-weight: 900 !important;
  letter-spacing: -0.7px !important;
}

.welcome-card p,
.presensi-welcome-card p {
  margin: 8px 0 0 !important;
  color: #64748b !important;
  font-size: 15px !important;
  font-weight: 700 !important;
}

.refresh-btn,
.primary-btn,
.start-btn,
.end-btn,
.manual-presensi-btn,
.save-nilai-btn,
.save-presensi {
  border-radius: 14px !important;
  padding: 12px 18px !important;
  font-weight: 900 !important;
  box-shadow: 0 12px 24px rgba(6, 43, 73, 0.16) !important;
  transition: 0.2s ease !important;
}

.refresh-btn,
.primary-btn,
.start-btn,
.manual-presensi-btn,
.save-nilai-btn,
.upload-btn,
.manual-save-mobile-btn,
.qr-demo-btn {
  background: #062b49 !important;
  color: #ffffff !important;
  box-shadow: 0 12px 24px rgba(6, 43, 73, 0.16) !important;
}

.refresh-btn:hover,
.primary-btn:hover,
.start-btn:hover,
.manual-presensi-btn:hover,
.save-nilai-btn:hover,
.upload-btn:hover,
.manual-save-mobile-btn:hover,
.qr-demo-btn:hover {
  background: #0a3b63 !important;
  transform: translateY(-1px) !important;
}

.end-btn {
  background: #ef4444 !important;
  color: #ffffff !important;
}

.end-btn:hover {
  background: #dc2626 !important;
  transform: translateY(-1px);
}

.save-presensi {
  background: #059669 !important;
  color: #ffffff !important;
}

.save-presensi:hover {
  background: #047857 !important;
  transform: translateY(-1px);
}

.stats-row {
  gap: 18px !important;
  margin-bottom: 22px !important;
}

.metric-card {
  background: #ffffff !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 24px !important;
  padding: 20px !important;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.05) !important;
}

.metric-card small {
  color: #64748b !important;
  font-size: 12px !important;
  font-weight: 900 !important;
}

.metric-card strong {
  margin-top: 8px !important;
  font-size: 32px !important;
  line-height: 1 !important;
  font-weight: 900 !important;
}

.split-grid,
.presensi-layout {
  gap: 22px !important;
  align-items: start !important;
}

.schedule-item,
.history-item,
.nilai-item,
.peserta-item {
  padding: 14px !important;
  border-radius: 18px !important;
  background: #f8fafc !important;
  border: 1px solid #edf2f7 !important;
  margin-bottom: 12px !important;
}

.schedule-item em,
.pill {
  border-radius: 999px !important;
  padding: 7px 12px !important;
  font-size: 12px !important;
  font-weight: 900 !important;
}

.kelas-header,
.content-header {
  margin-bottom: 22px !important;
}

.kelas-header h2,
.content-header h2 {
  color: #111827 !important;
  font-size: 24px !important;
  font-weight: 900 !important;
}

.kelas-header p,
.content-header p {
  color: #64748b !important;
  font-weight: 600 !important;
}

.kelas-grid {
  gap: 22px !important;
}

.kelas-card {
  padding: 22px !important;
  border-top: 5px solid #3b82f6 !important;
}

.kelas-icon {
  width: 46px !important;
  height: 46px !important;
  border-radius: 16px !important;
  background: #eef6ff !important;
}

.kelas-info,
.peserta-kelas-card,
.manual-presensi-card,
.daily-presensi-info div,
.presensi-summary div {
  background: #f8fafc !important;
  border: 1px solid #edf2f7 !important;
  border-radius: 18px !important;
}

.peserta-item {
  background: #ffffff !important;
}

.nilai-layout {
  gap: 22px !important;
}

.nilai-id-grid input,
.nilai-grid input:disabled,
.nilai-grid input[readonly] {
  background: #f3f4f6 !important;
  color: #475569 !important;
  font-weight: 900 !important;
  cursor: not-allowed !important;
}

.nilai-item {
  display: grid !important;
  grid-template-columns: 1fr auto !important;
  grid-template-areas:
    "info score"
    "breakdown breakdown" !important;
  gap: 14px !important;
  align-items: center !important;
}

.nilai-info {
  grid-area: info !important;
}

.nilai-breakdown {
  grid-area: breakdown !important;
  display: grid !important;
  grid-template-columns: repeat(5, minmax(66px, 1fr)) !important;
  gap: 10px !important;
}

.nilai-breakdown div {
  min-height: 58px !important;
  background: #ffffff !important;
  border: 1px solid #dbe6f2 !important;
  border-radius: 14px !important;
  padding: 9px 8px !important;
  text-align: center !important;
}

.nilai-score {
  grid-area: score !important;
  min-width: 96px !important;
  text-align: center !important;
  background: #e0f2fe !important;
  color: #062b49 !important;
  border-radius: 18px !important;
  padding: 12px 14px !important;
}

.nilai-score b {
  font-size: 28px !important;
  line-height: 1 !important;
  font-weight: 900 !important;
}

.presensi-panel {
  padding: 26px !important;
}

.presensi-icon {
  width: 54px !important;
  height: 54px !important;
  border-radius: 18px !important;
  background: #dcfce7 !important;
}

.presensi-panel h2 {
  color: #111827 !important;
  font-size: 24px !important;
  font-weight: 900 !important;
}

.presensi-subtitle {
  color: #64748b !important;
  font-weight: 700 !important;
}

.attendance-buttons button {
  border: 1px solid #d8e2ef !important;
  background: #ffffff !important;
  border-radius: 14px !important;
  color: #111827 !important;
  font-weight: 900 !important;
}

.attendance-buttons button:hover {
  border-color: #062b49 !important;
  background: #f8fafc !important;
}

.attendance-buttons button.active {
  border-color: #ffd21e !important;
  background: #fff7cc !important;
  color: #06152b !important;
}

.form-grid input,
.form-grid textarea,
.nilai-grid input,
.nilai-input,
.nilai-id-grid input,
.kelas-textarea,
.manual-field input,
.manual-field select,
.presensi-panel textarea,
.kelas-select {
  border: 1px solid #d8e2ef !important;
  border-radius: 14px !important;
  background: #ffffff !important;
  color: #111827 !important;
}

.form-grid input:focus,
.form-grid textarea:focus,
.nilai-grid input:focus,
.nilai-input:focus,
.kelas-textarea:focus,
.manual-field input:focus,
.manual-field select:focus,
.presensi-panel textarea:focus {
  border-color: #0b55a0 !important;
  box-shadow: 0 0 0 4px rgba(11, 85, 160, 0.12) !important;
}

@media (max-width: 1280px) {
  .kelas-grid {
    grid-template-columns: repeat(2, minmax(280px, 1fr)) !important;
  }

  .nilai-layout,
  .presensi-layout {
    grid-template-columns: 1fr !important;
  }
}

@media (max-width: 980px) {
  .stats-row.four,
  .split-grid {
    grid-template-columns: 1fr 1fr !important;
  }

  .attendance-buttons {
    grid-template-columns: repeat(3, 1fr) !important;
  }
}

@media (max-width: 840px) {
  .dashboard-layout {
    flex-direction: column !important;
  }

  .side-nav {
    width: 100% !important;
    min-height: auto !important;
    position: relative !important;
  }

  .workspace {
    padding: 18px !important;
  }

  .workspace-top,
  .kelas-header,
  .content-header,
  .presensi-welcome-card,
  .profile-hero-card {
    align-items: flex-start !important;
    flex-direction: column !important;
  }

  .kelas-grid,
  .stats-row.four,
  .split-grid,
  .form-grid,
  .nilai-grid,
  .nilai-id-grid,
  .daily-presensi-info,
  .presensi-summary,
  .kelas-info,
  .manual-presensi-grid,
  .peserta-add-grid,
  .attendance-buttons {
    grid-template-columns: 1fr !important;
  }

  .schedule-item,
  .nilai-item {
    grid-template-columns: 1fr !important;
    grid-template-areas: unset !important;
  }

  .nilai-info,
  .nilai-breakdown,
  .nilai-score {
    grid-area: unset !important;
  }

  .nilai-breakdown {
    grid-template-columns: repeat(2, 1fr) !important;
  }

  .profile-hero-card {
    text-align: center !important;
  }

  .profile-meta {
    justify-content: center !important;
  }
}



/* FIX: hilangkan kotak kosong pada card statistik dashboard */
.metric-card::before,
.metric-card::after,
.stat-card::before,
.stat-card::after {
  display: none !important;
  content: none !important;
  width: 0 !important;
  height: 0 !important;
  opacity: 0 !important;
  visibility: hidden !important;
  background: transparent !important;
  box-shadow: none !important;
}

.metric-card {
  position: relative !important;
  overflow: hidden !important;
}

.metric-card small,
.metric-card strong {
  position: relative !important;
  z-index: 1 !important;
}


/* PATCH FITUR DOSEN: detail kelas, upload materi/tugas, profile readonly, presensi H/S/A/I */
.kelas-card {
  cursor: pointer;
}

.kelas-card.expanded {
  border-top-color: #062b49 !important;
}

.kelas-card-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.kelas-toggle {
  border-radius: 999px;
  padding: 7px 12px;
  background: #f8fafc;
  border: 1px solid #d8e2ef;
  color: #062b49;
  font-size: 12px;
  font-weight: 900;
}

.kelas-click-hint {
  margin: 12px 0 0;
  padding: 12px 14px;
  border-radius: 14px;
  background: #f8fafc;
  border: 1px dashed #d8e2ef;
  color: #64748b;
  font-size: 12px;
  font-weight: 800;
}

.kelas-expanded {
  margin-top: 16px;
  display: grid;
  gap: 14px;
  cursor: default;
}

.kelas-upload-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
}

.upload-card {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
  padding: 16px;
  display: grid;
  gap: 12px;
}

.upload-card h4 {
  margin: 0;
  color: #111827;
  font-size: 15px;
  font-weight: 900;
}

.upload-card p {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 12px;
  line-height: 1.4;
}

.upload-card input[type="file"] {
  width: 100%;
  border: 1px solid #d8e2ef;
  border-radius: 14px;
  padding: 10px;
  background: #ffffff;
  color: #111827;
}

.upload-btn {
  border: none;
  border-radius: 14px;
  padding: 12px 16px;
  background: #062b49;
  color: #ffffff;
  font-weight: 900;
  cursor: pointer;
}

.upload-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.upload-list {
  display: grid;
  gap: 8px;
}

.upload-list span {
  display: block;
  padding: 10px 12px;
  border-radius: 12px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  color: #475569;
  font-size: 12px;
  font-weight: 800;
}

.selected-student-card {
  margin-top: 12px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.selected-student-card div {
  background: #ffffff;
  border: 1px solid #dbe6f2;
  border-radius: 14px;
  padding: 12px;
}

.selected-student-card small {
  display: block;
  color: #64748b;
  font-size: 11px;
  font-weight: 900;
}

.selected-student-card strong {
  display: block;
  margin-top: 4px;
  color: #111827;
  font-size: 14px;
  font-weight: 900;
}

.manual-presensi-grid-compact {
  grid-template-columns: 1fr !important;
}

.attendance-buttons-four {
  grid-template-columns: repeat(4, 1fr) !important;
}

.profile-note {
  margin: 0 0 18px;
  padding: 13px 16px;
  border-radius: 14px;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  color: #1e3a8a;
  font-size: 13px;
  font-weight: 800;
  line-height: 1.45;
}

.form-grid input[readonly] {
  background: #f3f4f6 !important;
  color: #64748b !important;
  cursor: not-allowed !important;
}

@media (max-width: 840px) {
  .kelas-upload-grid,
  .selected-student-card,
  .attendance-buttons-four {
    grid-template-columns: 1fr !important;
  }
}


/* PATCH DETAIL KELAS SEPERTI PAGE BARU */
.kelas-card-clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.kelas-card-clickable:hover {
  transform: translateY(-3px);
  box-shadow: 0 22px 44px rgba(15, 23, 42, 0.1) !important;
  border-color: #bfdbfe !important;
}

.kelas-open-row {
  margin-top: 16px;
  padding: 13px 14px;
  border-radius: 14px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  color: #062b49;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  font-weight: 900;
}

.kelas-detail-page {
  display: grid;
  gap: 18px;
}

.back-to-classes {
  width: fit-content;
  border: 1px solid #d8e2ef;
  background: #ffffff;
  color: #062b49;
  border-radius: 14px;
  padding: 11px 16px;
  font-weight: 900;
  cursor: pointer;
  transition: 0.2s ease;
}

.back-to-classes:hover {
  background: #f8fafc;
  transform: translateY(-1px);
}

.kelas-detail-hero {
  background:
    radial-gradient(circle at top right, rgba(255, 210, 30, 0.2), transparent 32%),
    #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  padding: 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06);
}

.kelas-detail-hero h2 {
  margin: 0;
  color: #111827;
  font-size: 30px;
  font-weight: 900;
  letter-spacing: -0.7px;
}

.kelas-detail-hero span:not(.kelas-status) {
  display: block;
  margin-top: 8px;
  color: #64748b;
  font-weight: 800;
}

.kelas-detail-summary {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.kelas-detail-summary div {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 20px;
  padding: 18px;
  box-shadow: 0 14px 30px rgba(15, 23, 42, 0.05);
}

.kelas-detail-summary small {
  display: block;
  color: #64748b;
  font-size: 12px;
  font-weight: 900;
}

.kelas-detail-summary strong {
  display: block;
  margin-top: 8px;
  color: #111827;
  font-size: 20px;
  font-weight: 900;
}

.kelas-detail-layout {
  display: grid;
  grid-template-columns: minmax(420px, 1.15fr) minmax(340px, 0.85fr);
  gap: 22px;
  align-items: start;
}

.detail-main-column,
.detail-side-column {
  display: grid;
  gap: 22px;
}

.detail-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  padding: 24px;
  box-shadow: 0 18px 38px rgba(15, 23, 42, 0.06);
}

.detail-card-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.detail-card-head h3 {
  margin: 0;
  color: #111827;
  font-size: 18px;
  font-weight: 900;
}

.detail-card-head p {
  margin: 6px 0 0;
  color: #64748b;
  font-size: 13px;
  font-weight: 700;
}

.kelas-detail-list {
  display: grid;
  gap: 12px;
}

.kelas-detail-list p {
  margin: 0;
  padding: 14px;
  border-radius: 16px;
  background: #f8fafc;
  border: 1px solid #edf2f7;
  color: #475569;
  font-size: 13px;
}

.kelas-detail-list b {
  color: #111827;
}

.detail-actions {
  margin-top: 18px;
}

.qr-preview-card,
.qr-empty-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px;
  border-radius: 18px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  margin-bottom: 16px;
}

.qr-preview-card img {
  width: 96px;
  height: 96px;
  border-radius: 14px;
  background: #ffffff;
  padding: 8px;
  object-fit: contain;
}

.qr-preview-card strong,
.qr-empty-card strong {
  display: block;
  color: #111827;
  font-weight: 900;
}

.qr-preview-card p,
.qr-empty-card p {
  margin: 5px 0 0;
  color: #64748b;
  font-size: 13px;
  font-weight: 700;
}

.detail-upload-grid {
  grid-template-columns: 1fr;
}

.manual-presensi-detail {
  margin-top: 16px;
}

.peserta-list-detail {
  max-height: 360px;
  overflow: auto;
  padding-right: 4px;
}

.peserta-add-detail {
  grid-template-columns: 1fr;
}

@media (max-width: 1180px) {
  .kelas-detail-layout {
    grid-template-columns: 1fr;
  }

  .kelas-detail-summary {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 720px) {
  .kelas-detail-hero,
  .detail-card-head,
  .qr-preview-card,
  .qr-empty-card {
    align-items: flex-start;
    flex-direction: column;
  }

  .kelas-detail-summary {
    grid-template-columns: 1fr;
  }
}


/* PATCH: profil tanpa teks biru dan presensi dosen hanya Hadir */
.profile-note {
  display: none !important;
}

.profile-meta span {
  background: #f8fafc !important;
  border-color: #e2e8f0 !important;
  color: #475569 !important;
}

.profile-meta b {
  color: #111827 !important;
}

.attendance-buttons-single {
  grid-template-columns: 1fr !important;
}

.attendance-buttons-single button {
  min-height: 58px;
  border-color: #16a34a !important;
  background: #dcfce7 !important;
  color: #166534 !important;
}

.attendance-buttons-single button span {
  font-size: 13px !important;
  font-weight: 900 !important;
}



.profile-role-text {
  margin-top: 6px;
  max-width: 680px;
  color: #64748b;
  font-size: 14px;
  line-height: 1.5;
  word-break: normal;
}


/* ===== Presensi (samakan feel dengan admin pegawai) ===== */
.presensi-mode-toggle{
  display:flex;
  gap:10px;
  margin: 14px 0 12px;
  background: rgba(0,0,0,0.03);
  padding: 6px;
  border-radius: 14px;
}
.mode-btn{
  flex:1;
  border: 1px solid rgba(0,0,0,0.10);
  background: transparent;
  padding: 10px 12px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
}
.mode-btn.active{
  background: #fff;
  box-shadow: 0 6px 18px rgba(0,0,0,0.06);
}
.mode-btn:disabled{
  opacity: 0.55;
  cursor: not-allowed;
}
.today-status{
  margin-top: 10px;
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 14px;
  padding: 12px 14px;
  background: rgba(255,255,255,0.75);
}
.today-row{
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding: 6px 0;
}
.today-label{ font-size: 12px; opacity: 0.75; }
.today-value{ font-size: 14px; }
.history-list{ display:flex; flex-direction:column; gap:10px; }
.history-main{ display:flex; flex-direction:column; gap:4px; }
.history-sub{ margin:0; font-size: 12px; opacity:0.75; }
.hint{
  margin-top: 10px;
  font-size: 12px;
  opacity: 0.75;
}

/* ===== VALIDASI KRS STYLES ===== */
.krs-page {
  display: grid;
  gap: 20px;
}

.krs-filter-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 8px;
}

.search-box {
  flex: 1;
  max-width: 420px;
  display: flex;
  align-items: center;
  gap: 10px;
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  padding: 0 16px;
  height: 48px;
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.02);
}

.search-box input {
  width: 100%;
  border: none;
  outline: none;
  font-size: 14px;
  color: #1e293b;
  font-weight: 500;
  background: transparent;
}

.krs-refresh-btn {
  height: 48px;
  padding: 0 20px;
  background: #ffffff;
  border: 1px solid #d8e2ef;
  color: #062b49;
  border-radius: 14px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.02);
}

.krs-refresh-btn:hover {
  background: #f8fafc;
  border-color: #cbd5e1;
}

.krs-loading-state, .krs-empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 26px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(6, 43, 73, 0.1);
  border-left-color: #062b49;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.krs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.krs-card-item {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 24px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
  display: flex;
  flex-direction: column;
}

.krs-card-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
  border-color: #cbd5e1;
}

.krs-card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.avatar-small {
  width: 38px;
  height: 38px;
  border-radius: 12px;
  background: #eff6ff;
  color: #1d4ed8;
  display: grid;
  place-items: center;
  font-weight: 800;
  font-size: 16px;
  border: 1px solid #dbeafe;
}

.avatar-large {
  width: 58px;
  height: 58px;
  border-radius: 18px;
  background: #eff6ff;
  color: #1d4ed8;
  display: grid;
  place-items: center;
  font-weight: 800;
  font-size: 24px;
  border: 1px solid #dbeafe;
}

.krs-status-badge {
  padding: 6px 12px;
  border-radius: 9999px;
  font-size: 11px;
  font-weight: 800;
}

.krs-status-badge.menunggu-persetujuan {
  background: #fef3c7;
  color: #d97706;
  border: 1px solid #fde68a;
}

.krs-status-badge.disetujui {
  background: #dcfce7;
  color: #15803d;
  border: 1px solid #bbf7d0;
}

.krs-status-badge.ditolak {
  background: #fee2e2;
  color: #b91c1c;
  border: 1px solid #fecaca;
}

.student-name {
  margin: 0 0 4px;
  color: #1e293b;
  font-size: 16px;
  font-weight: 800;
}

.student-nim {
  margin: 0 0 16px;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

.krs-meta-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  background: #f8fafc;
  padding: 12px;
  border-radius: 16px;
  border: 1px solid #f1f5f9;
  margin-bottom: 16px;
}

.krs-meta-grid div {
  text-align: center;
}

.krs-meta-grid small {
  display: block;
  color: #64748b;
  font-size: 10px;
  font-weight: 700;
  margin-bottom: 4px;
}

.krs-meta-grid strong {
  display: block;
  color: #1e293b;
  font-size: 13px;
  font-weight: 800;
}

.krs-card-footer {
  margin-top: auto;
  border-top: 1px solid #f1f5f9;
  padding-top: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #062b49;
  font-size: 12px;
  font-weight: 800;
}

.krs-card-footer .arrow {
  transition: transform 0.2s ease;
}

.krs-card-item:hover .krs-card-footer .arrow {
  transform: translateX(4px);
}

/* KRS DETAIL STYLES */
.krs-detail-view {
  display: grid;
  gap: 20px;
}

.back-to-krs {
  width: fit-content;
  border: 1px solid #d8e2ef;
  background: #ffffff;
  color: #062b49;
  border-radius: 14px;
  padding: 11px 18px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.02);
}

.back-to-krs:hover {
  background: #f8fafc;
  transform: translateY(-1px);
}

.krs-detail-hero {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 26px;
  padding: 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.krs-hero-main {
  display: flex;
  align-items: center;
  gap: 16px;
}

.krs-eyebrow {
  margin: 0;
  font-size: 11px;
  font-weight: 900;
  color: #1d4ed8;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.krs-detail-hero h2 {
  margin: 4px 0;
  font-size: 24px;
  font-weight: 900;
  color: #1e293b;
  letter-spacing: -0.5px;
}

.krs-sub {
  margin: 0;
  font-size: 13px;
  color: #64748b;
  font-weight: 500;
}

.krs-sub b {
  color: #1e293b;
  font-weight: 700;
}

.krs-detail-layout {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: 20px;
  align-items: start;
}

.krs-card {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 26px;
  padding: 24px;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.krs-card-head {
  margin-bottom: 20px;
}

.krs-card-head h3 {
  margin: 0 0 6px;
  color: #1e293b;
  font-size: 18px;
  font-weight: 900;
}

.krs-card-head p {
  margin: 0;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

.krs-table-wrapper {
  overflow-x: auto;
  border: 1px solid #e2e8f0;
  border-radius: 18px;
}

.krs-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
  font-size: 14px;
}

.krs-table th {
  background: #f8fafc;
  padding: 14px 16px;
  color: #475569;
  font-weight: 800;
  font-size: 12px;
  text-transform: uppercase;
  border-bottom: 1px solid #e2e8f0;
}

.krs-table td {
  padding: 16px;
  border-bottom: 1px solid #e2e8f0;
  color: #334155;
  font-weight: 600;
}

.krs-table tr:last-child td {
  border-bottom: none;
}

.krs-table code {
  background: #f1f5f9;
  padding: 4px 8px;
  border-radius: 8px;
  color: #0f172a;
  font-weight: 700;
  font-family: Menlo, Monaco, Consolas, Courier New, monospace;
  font-size: 12px;
}

.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.font-semibold {
  font-weight: 700;
}

.font-bold {
  font-weight: 800;
}

.total-sks {
  color: #1d4ed8 !important;
  font-size: 15px;
}

.krs-table tfoot td {
  background: #f8fafc;
  padding: 16px;
  border-top: 2px solid #e2e8f0;
  color: #1e293b;
}

/* PERSETUJUAN ACTION CARD */
.krs-action-card h3 {
  margin: 0 0 8px;
  color: #1e293b;
  font-size: 18px;
  font-weight: 900;
}

.krs-action-card p {
  margin: 0 0 20px;
  color: #64748b;
  font-size: 13px;
  line-height: 1.5;
  font-weight: 600;
}

.krs-action-status-box {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 14px 16px;
  margin-bottom: 20px;
}

.krs-action-status-box small {
  display: block;
  color: #64748b;
  font-size: 11px;
  font-weight: 700;
  margin-bottom: 4px;
}

.krs-action-status-box strong {
  display: block;
  color: #1e293b;
  font-size: 16px;
  font-weight: 800;
}

.krs-action-buttons {
  display: grid;
  gap: 12px;
}

.krs-btn {
  width: 100%;
  height: 48px;
  border: none;
  border-radius: 14px;
  font-size: 14px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s ease;
}

.approve-btn {
  background: #16a34a;
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.2);
}

.approve-btn:hover:not(:disabled) {
  background: #15803d;
  transform: translateY(-1px);
}

.reject-btn {
  background: #dc2626;
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
}

.reject-btn:hover:not(:disabled) {
  background: #b91c1c;
  transform: translateY(-1px);
}

.krs-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

@media (max-width: 992px) {
  .krs-detail-layout {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 576px) {
  .krs-detail-hero {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .krs-filter-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-box {
    max-width: none;
  }
}

/* Scroll adjustments for Input Nilai student list */
.nilai-list-card {
  max-height: calc(100vh - 190px) !important;
  display: flex !important;
  flex-direction: column !important;
  padding: 24px !important;
}

.nilai-list-scroll {
  overflow-y: auto !important;
  flex: 1 !important;
  padding-right: 8px !important;
  margin-top: 12px;
}

/* Custom scrollbar styling for a premium aesthetic */
.nilai-list-scroll::-webkit-scrollbar {
  width: 6px;
}

.nilai-list-scroll::-webkit-scrollbar-track {
  background: transparent;
}

.nilai-list-scroll::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 10px;
}

.nilai-list-scroll::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.2);
}

/* Align presensi layout and add vertical scrolling to history card */
.presensi-layout {
  display: grid !important;
  grid-template-columns: 1fr 1fr !important;
  align-items: stretch !important;
  gap: 24px !important;
}

.presensi-layout > div.white-card {
  height: 520px !important;
  display: flex !important;
  flex-direction: column !important;
  margin: 0 !important;
  box-sizing: border-box !important;
}

.history-list {
  flex: 1 !important;
  overflow-y: auto !important;
  padding-right: 6px;
}

/* Custom premium scrollbar for history list */
.history-list::-webkit-scrollbar {
  width: 5px;
}

.history-list::-webkit-scrollbar-track {
  background: transparent;
}

.history-list::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 10px;
}

.history-list::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.2);
}

/* Custom premium scrollbar for manual student list */
.manual-scroll-list::-webkit-scrollbar {
  width: 5px;
}

.manual-scroll-list::-webkit-scrollbar-track {
  background: transparent;
}

.manual-scroll-list::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 10px;
}

.manual-scroll-list::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.2);
}

</style>
