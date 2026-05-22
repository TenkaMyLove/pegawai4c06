<?php

namespace App\Services;

use App\Models\Pegawai;
use App\Models\Dosen;
use App\Models\Jabatan;
use App\Models\AbsensiPegawai;
use App\Models\Kelas;
use App\Models\KelasSession;
use App\Models\Mahasiswa\AbsensiMahasiswa;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class DashboardService
{
    public function dosen()
    {
        $user = Auth::user();

        $dosen = Dosen::where('id_user', $user->id)->first();

        if (!$dosen) {
            throw new \Exception("Dosen tidak ditemukan");
        }

        $jumlahKelas = Kelas::where('NIP_DOSEN', $dosen->nip_baru)
            ->count();

        $kelasIds = Kelas::where('NIP_DOSEN', $dosen->nip_baru)
            ->pluck('ID_KELAS');

        $kelasAktif = KelasSession::where('IS_ACTIVE', true)
            ->whereIn('KELAS_ID', $kelasIds)
            ->count();

        $totalAbsensi = AbsensiMahasiswa::whereIn('KELAS_ID', $kelasIds)
            ->count();

        return [
            'nama_dosen' => $dosen->nama_dosen,
            'jumlah_kelas' => $jumlahKelas,
            'kelas_aktif' => $kelasAktif,
            'total_absensi' => $totalAbsensi,
        ];
    }

    public function pegawai()
    {
        $today = Carbon::today()->toDateString();

        $totalPegawai = Pegawai::count();
        $totalDosen = Dosen::count();
        $totalJabatan = Jabatan::count();

        $presensiHariIni = AbsensiPegawai::where('tanggal', $today)->count();

        $sudahMasuk = AbsensiPegawai::where('tanggal', $today)
            ->whereNotNull('waktu_masuk')
            ->count();

        $sudahPulang = AbsensiPegawai::where('tanggal', $today)
            ->whereNotNull('waktu_keluar')
            ->count();

        $belumPresensi = max($totalPegawai - $sudahMasuk, 0);

        return [
            'total_pegawai' => $totalPegawai,
            'total_dosen' => $totalDosen,
            'total_jabatan' => $totalJabatan,
            'presensi_hari_ini' => $presensiHariIni,
            'pegawai_sudah_masuk' => $sudahMasuk,
            'pegawai_sudah_pulang' => $sudahPulang,
            'pegawai_belum_presensi' => $belumPresensi,
        ];
    }
}