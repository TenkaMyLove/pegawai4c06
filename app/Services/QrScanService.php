<?php

namespace App\Services;

use App\Models\QrSession;
use App\Models\KelasSession;
use App\Models\Mahasiswa\Mahasiswa;
use App\Models\Mahasiswa\AbsensiMahasiswa;

class QrScanService
{
    public function scan($nim, $token)
    {
        try {
            // 1. Check QR
            $session = QrSession::where('TOKEN', $token)->first();

            if (!$session) {
                throw new \Exception("QR tidak valid");
            }

            // 2. Check expired
            if (now()->greaterThan($session->EXPIRED_AT)) {
                throw new \Exception("QR sudah expired");
            }

            // 3. Check active class session
            $kelasSession = KelasSession::where('KELAS_ID', $session->KELAS_ID)
                ->where('IS_ACTIVE', true)
                ->first();

            if (!$kelasSession) {
                throw new \Exception("Kelas tidak aktif");
            }

            // 4. Ensure pertemuan matches
            if ($kelasSession->KODE_PERTEMUAN !== $session->KODE_PERTEMUAN) {
                throw new \Exception("QR tidak sesuai sesi aktif");
            }

            // 5. Check mahasiswa
            $mahasiswa = Mahasiswa::where('NIM', $nim)->first();

            if (!$mahasiswa) {
                throw new \Exception("Mahasiswa tidak ditemukan");
            }

            if ($mahasiswa->KODE_KELAS !== $session->KELAS_ID) {
                throw new \Exception("Mahasiswa tidak terdaftar di kelas ini");
            }

            // 6. Prevent duplicate
            $exists = AbsensiMahasiswa::where([
                'NIM' => $nim,
                'KELAS_ID' => $session->KELAS_ID,
                'KODE_PERTEMUAN' => $session->KODE_PERTEMUAN
            ])->exists();

            if ($exists) {
                throw new \Exception("Sudah absen di pertemuan ini");
            }

            // 7. Save
            $absen = AbsensiMahasiswa::create([
                'NIM' => $nim,
                'KELAS_ID' => $session->KELAS_ID,
                'KODE_PERTEMUAN' => $session->KODE_PERTEMUAN,
                'TANGGAL' => now()->toDateString(),
                'STATUS' => 'H',
                'METODE' => 'QR'
            ]);

            return [
                'success' => true,
                'data' => $absen
            ];

        } catch (\Throwable $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}