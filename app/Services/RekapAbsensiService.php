<?php

namespace App\Services;

use App\Models\Mahasiswa\AbsensiMahasiswa;
use App\Models\Mahasiswa\Mahasiswa;
use App\Models\Dosen;
use App\Models\Kelas;
use App\Models\KelasSession;
use Illuminate\Support\Facades\Auth;

class RekapAbsensiService
{
    public function getRekap($kelasId, $kodePertemuan = null)
    {
        // =========================
        // Validate dosen ownership
        // =========================

        $user = Auth::user();

        $dosen = Dosen::where('ID_USER', $user->id)->first();

        if (!$dosen) {
            throw new \Exception("Dosen tidak ditemukan");
        }

        $kelas = Kelas::where('ID_KELAS', $kelasId)
            ->where('NIP_DOSEN', $dosen->NIP_DOSEN)
            ->first();

        if (!$kelas) {
            throw new \Exception("Anda tidak memiliki akses ke kelas ini");
        }

        // =========================
        // Auto latest pertemuan
        // =========================

        if (!$kodePertemuan) {

            $latestSession = KelasSession::where('KELAS_ID', $kelasId)
                ->latest('KODE_PERTEMUAN')
                ->first();

            if (!$latestSession) {
                return [
                    'error' => 'Belum ada sesi kelas'
                ];
            }

            $kodePertemuan = $latestSession->KODE_PERTEMUAN;
        }

        // =========================
        // Get attendance
        // =========================

        $absensi = AbsensiMahasiswa::where('KELAS_ID', $kelasId)
            ->where('KODE_PERTEMUAN', $kodePertemuan)
            ->get();

        $summary = [
            'H' => 0,
            'I' => 0,
            'S' => 0,
            'A' => 0
        ];

        $data = [];

        foreach ($absensi as $item) {

            $mahasiswa = Mahasiswa::find($item->NIM);

            $summary[$item->STATUS]++;

            $data[] = [
                'nim' => $item->NIM,
                'nama' => $mahasiswa?->MAHASISWA_NAMA ?? 'Unknown',
                'status' => $item->STATUS,
                'metode' => $item->METODE
            ];
        }

        return [
            'kelas_id' => $kelasId,
            'kode_pertemuan' => $kodePertemuan,
            'summary' => $summary,
            'data' => $data
        ];
    }
}