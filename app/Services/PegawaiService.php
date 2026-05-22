<?php

namespace App\Services;

use App\Models\Pegawai;

class PegawaiService
{
    public function getAll()
    {
        return Pegawai::with(['jabatan', 'absensi'])->get();
    }

    public function getById($id)
    {
        return Pegawai::with(['jabatan', 'absensi'])
            ->where('id_pegawai', $id)
            ->firstOrFail();
    }

    public function getByNip($nip)
    {
        return Pegawai::with(['jabatan', 'absensi'])
            ->where('nip', $nip)
            ->firstOrFail();
    }

    public function create($data)
    {
        return Pegawai::create($data);
    }

    public function update($id, $data)
    {
        $pegawai = Pegawai::where('id_pegawai', $id)->firstOrFail();

        $pegawai->update($data);

        return $pegawai;
    }

    public function delete($id)
    {
        $pegawai = Pegawai::where('id_pegawai', $id)->firstOrFail();

        $pegawai->delete();

        return ['message' => 'Deleted'];
    }
}