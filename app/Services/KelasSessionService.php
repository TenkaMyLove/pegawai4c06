<?php

namespace App\Services;

use App\Models\KelasSession;
use App\Models\Dosen;
use App\Models\PesertaKelasMk;
use Illuminate\Support\Facades\Auth;

class KelasSessionService
{
    private function getDosen()
    {
        $user = Auth::user();

        return Dosen::where('id_user', $user->id)->firstOrFail();
    }

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

    public function start($kelasId, $mkId)
    {
        $dosen = $this->getDosen();

        $this->validateKelasOwnership($dosen, $kelasId, $mkId);

        $active = KelasSession::where('KELAS_ID', $kelasId)
            ->where('ID_MK', $mkId)
            ->where('IS_ACTIVE', true)
            ->exists();

        if ($active) {
            throw new \Exception("Kelas masih berlangsung");
        }

        $last = KelasSession::where('KELAS_ID', $kelasId)
            ->where('ID_MK', $mkId)
            ->max('KODE_PERTEMUAN');

        $next = $last ? $last + 1 : 1;

        return KelasSession::create([
            'KELAS_ID' => $kelasId,
            'ID_MK' => $mkId,
            'KODE_PERTEMUAN' => $next,
            'STARTED_AT' => now(),
            'IS_ACTIVE' => true
        ]);
    }

    public function end($kelasId, $mkId)
    {
        $dosen = $this->getDosen();

        $this->validateKelasOwnership($dosen, $kelasId, $mkId);

        $session = KelasSession::where('KELAS_ID', $kelasId)
            ->where('ID_MK', $mkId)
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

    public function getActive($kelasId, $mkId)
    {
        return KelasSession::where('KELAS_ID', $kelasId)
            ->where('ID_MK', $mkId)
            ->where('IS_ACTIVE', true)
            ->first();
    }
}