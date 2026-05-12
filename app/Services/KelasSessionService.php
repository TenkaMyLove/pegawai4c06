<?php

namespace App\Services;

use App\Models\KelasSession;
use App\Models\Dosen;
use App\Models\Kelas;
use Illuminate\Support\Facades\Auth;

class KelasSessionService
{
    public function start($kelasId)
    {
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

        $active = KelasSession::where('KELAS_ID', $kelasId)
            ->where('IS_ACTIVE', true)
            ->exists();

        if ($active) {
            throw new \Exception("Kelas masih berlangsung");
        }

        $last = KelasSession::where('KELAS_ID', $kelasId)
            ->max('KODE_PERTEMUAN');

        $next = $last ? $last + 1 : 1;

        return KelasSession::create([
            'KELAS_ID' => $kelasId,
            'KODE_PERTEMUAN' => $next,
            'STARTED_AT' => now(),
            'IS_ACTIVE' => true
        ]);
    }

    public function end($kelasId)
    {
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

        $session = KelasSession::where('KELAS_ID', $kelasId)
            ->where('IS_ACTIVE', true)
            ->first();

        if (!$session) {
            throw new \Exception("Tidak ada sesi aktif");
        }

        $session->update([
            'IS_ACTIVE' => false,
            'ENDED_AT' => now()
        ]);

        return $session;
    }

    public function getActive($kelasId)
    {
        return KelasSession::where('KELAS_ID', $kelasId)
            ->where('IS_ACTIVE', true)
            ->first();
    }
}