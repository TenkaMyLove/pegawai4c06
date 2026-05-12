<?php

namespace App\Services;

use App\Models\Pegawai;

class PegawaiService
{
    public function getAll()
    {
        return Pegawai::all();
    }

    public function create($data)
    {
        return Pegawai::create($data);
    }

    public function update($id, $data)
    {
        $pegawai = Pegawai::where('NIP', $id)->firstOrFail();
        $pegawai->update($data);

        return $pegawai;
    }

    public function delete($id)
    {
        Pegawai::destroy($id);

        return ['message' => 'Deleted'];
    }
}