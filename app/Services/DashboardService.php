<?php

namespace App\Services;

use App\Models\Pegawai;
use App\Models\Kelas;
use App\Models\KelasSession;
use App\Models\Mahasiswa\AbsensiMahasiswa;
use Illuminate\Support\Facades\Auth;

class DashboardService
{
    public function dosen()
    {
        $user = Auth::user();

        $pegawai = Pegawai::where('ID_USER', $user->id)->first();

        if (!$pegawai) {
            throw new \Exception("Pegawai tidak ditemukan");
        }

        $jumlahKelas = Kelas::where('NIP_DOSEN', $pegawai->NIP)
            ->count();

        $kelasAktif = KelasSession::where('IS_ACTIVE', true)
            ->whereIn(
                'KELAS_ID',
                Kelas::where('NIP_DOSEN', $pegawai->NIP)
                    ->pluck('ID_KELAS')
            )
            ->count();

        $totalAbsensi = AbsensiMahasiswa::whereIn(
            'KELAS_ID',
            Kelas::where('NIP_DOSEN', $pegawai->NIP)
                ->pluck('ID_KELAS')
        )->count();

        return [
            'nama_dosen' => $pegawai->NAMA_PEGAWAI,
            'jumlah_kelas' => $jumlahKelas,
            'kelas_aktif' => $kelasAktif,
            'total_absensi' => $totalAbsensi
        ];
    }
}