<?php

namespace App\Services;

use App\Models\Dosen;
use App\Models\PesertaKelasMk;
use Illuminate\Support\Facades\DB;

class JadwalMengajarService
{
    public function getJadwal($userId)
    {
        $dosen = Dosen::where('id_user', $userId)->firstOrFail();

        return PesertaKelasMk::select(
                'id_kelas',
                'id_mk',
                DB::raw('COUNT(nim) as jumlah_mahasiswa')
            )
            ->where('id_pegawai', $dosen->id_pegawai)
            ->groupBy('id_kelas', 'id_mk')
            ->orderBy('id_kelas')
            ->orderBy('id_mk')
            ->get();
    }
}