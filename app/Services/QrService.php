<?php

namespace App\Services;

use App\Models\QrSession;
use App\Models\Dosen;
use App\Models\PesertaKelasMk;
use App\Services\KelasSessionService;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class QrService
{
    private function validateKelasOwnership($dosen, $kelasId, $mkId)
    {
        $owned = PesertaKelasMk::where('id_kelas', (string) $kelasId)
            ->where('id_mk', (string) $mkId)
            ->where('id_pegawai', (int) $dosen->id_pegawai)
            ->exists();

        if (!$owned) {
            throw new \Exception("Anda tidak memiliki akses ke kelas dan mata kuliah ini");
        }
    }

    public function generate($kelasId, $mkId)
    {
        // =========================
        // Validate dosen ownership
        // =========================

        $user = Auth::user();

        $dosen = Dosen::where('id_user', $user->id)->first();

        if (!$dosen) {
            throw new \Exception("Dosen tidak ditemukan");
        }

        $this->validateKelasOwnership($dosen, $kelasId, $mkId);

        // =========================
        // Check active kelas session
        // =========================

        $kelasSession = (new KelasSessionService())
            ->getActive($kelasId, $mkId);

        if (!$kelasSession) {
            throw new \Exception("Kelas belum dimulai");
        }

        $kodePertemuan = $kelasSession->KODE_PERTEMUAN;

        // =========================
        // Expire previous active QR
        // =========================

        QrSession::where('KELAS_ID', $kelasId)
            ->where('ID_MK', $mkId)
            ->where('EXPIRED_AT', '>', now())
            ->update([
                'EXPIRED_AT' => now()
            ]);

        // =========================
        // Create new QR session
        // =========================

        $qr = QrSession::create([
            'KELAS_ID' => $kelasId,
            'ID_MK' => $mkId,
            'KODE_PERTEMUAN' => $kodePertemuan,
            'TOKEN' => Str::random(40),
            'EXPIRED_AT' => now()->addMinutes(5)
        ]);

        // =========================
        // Return response
        // =========================

        return [
            'message' => 'QR berhasil dibuat',
            'id_kelas' => $kelasId,
            'id_mk' => $mkId,
            'kode_pertemuan' => $kodePertemuan,
            'token' => $qr->TOKEN,
            'expired_at' => $qr->EXPIRED_AT
        ];
    }
}