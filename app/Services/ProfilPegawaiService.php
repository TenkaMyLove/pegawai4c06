<?php

namespace App\Services;

use App\Models\Pegawai;

class ProfilPegawaiService
{
    public function getProfile($userId)
    {
        return Pegawai::with(['jabatan', 'dosen'])
            ->where('id_user', $userId)
            ->firstOrFail();
    }

    public function updateProfile($userId, array $data)
    {
        $pegawai = Pegawai::where('id_user', $userId)->firstOrFail();

        $pegawai->update([
            'alamat' => $data['alamat'] ?? $pegawai->alamat,
            'jenis_kelamin' => $data['jenis_kelamin'] ?? $pegawai->jenis_kelamin,
        ]);

        return $pegawai;
    }
}