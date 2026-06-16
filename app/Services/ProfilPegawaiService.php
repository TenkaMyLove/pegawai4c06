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
            'email' => $data['email'] ?? $pegawai->email,
        ]);

        if ($pegawai->dosen) {
            $pegawai->dosen->update([
                'alamat' => $data['alamat'] ?? $pegawai->dosen->alamat,
                'jk' => $data['jenis_kelamin'] ?? $pegawai->dosen->jk,
                'email' => $data['email'] ?? $pegawai->dosen->email,
            ]);
        }

        // Also update the User model email so their login credential stays in sync
        $user = \App\Models\User::find($userId);
        if ($user && isset($data['email'])) {
            $user->update([
                'email' => $data['email']
            ]);
        }

        return $pegawai;
    }
}