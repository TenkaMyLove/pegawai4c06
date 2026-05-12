<?php

namespace App\Services;

use App\Models\QrSession;
use App\Models\Dosen;
use App\Models\Kelas;
use App\Services\KelasSessionService;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class QrService
{
    public function generate($kelasId)
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
        // Check active kelas session
        // =========================

        $kelasSession = (new KelasSessionService())
            ->getActive($kelasId);

        if (!$kelasSession) {
            throw new \Exception("Kelas belum dimulai");
        }

        $kodePertemuan = $kelasSession->KODE_PERTEMUAN;

        // =========================
        // Expire previous active QR
        // =========================

        QrSession::where('KELAS_ID', $kelasId)
            ->where('EXPIRED_AT', '>', now())
            ->update([
                'EXPIRED_AT' => now()
            ]);

        // =========================
        // Create new QR session
        // =========================

        $qr = QrSession::create([
            'KELAS_ID' => $kelasId,
            'KODE_PERTEMUAN' => $kodePertemuan,
            'TOKEN' => Str::random(40),
            'EXPIRED_AT' => now()->addSeconds(10)
        ]);

        // =========================
        // Return response
        // =========================

        return [
            'message' => 'QR berhasil dibuat',
            'kelas_id' => $kelasId,
            'kode_pertemuan' => $kodePertemuan,
            'token' => $qr->TOKEN,
            'expired_at' => $qr->EXPIRED_AT
        ];
    }
}