<?php

namespace App\Services;

use App\Models\QrSession;
use App\Models\KelasSession;
use App\Models\PesertaKelasMk;
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
                ->where('ID_MK', $session->ID_MK)
                ->where('IS_ACTIVE', true)
                ->first();

            if (!$kelasSession) {
                throw new \Exception("Kelas tidak aktif");
            }

            // 4. Ensure pertemuan matches
            if ((int) $kelasSession->KODE_PERTEMUAN !== (int) $session->KODE_PERTEMUAN) {
                throw new \Exception("QR tidak sesuai sesi aktif");
            }

            // 5. Check mahasiswa registered in kelas + mk
            $peserta = PesertaKelasMk::where('nim', $nim)
                ->where('id_kelas', (string) $session->KELAS_ID)
                ->where('id_mk', (string) $session->ID_MK)
                ->first();

            if (!$peserta) {
                throw new \Exception("Mahasiswa tidak terdaftar di kelas dan mata kuliah ini");
            }

            // 6. Prevent duplicate
            $exists = AbsensiMahasiswa::where([
                'NIM' => $nim,
                'KELAS_ID' => $session->KELAS_ID,
                'KODE_PERTEMUAN' => $session->KODE_PERTEMUAN
            ])
            ->where('ID_MK', $session->ID_MK)
            ->exists();

            if ($exists) {
                throw new \Exception("Sudah absen di pertemuan ini");
            }

            // 7. Save
            $absen = AbsensiMahasiswa::create([
                'NIM' => $nim,
                'KELAS_ID' => $session->KELAS_ID,
                'ID_MK' => $session->ID_MK,
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