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
        $pegawai = Pegawai::create($data);

        // Cari ID Jabatan yang cocok berdasarkan unit_kerja
        if (!empty($pegawai->unit_kerja)) {
            $jabatan = \App\Models\Jabatan::where('nama_jabatan', 'like', '%' . $pegawai->unit_kerja . '%')
                ->orWhere('id_jabatan', $pegawai->unit_kerja)
                ->first();

            if ($jabatan && !empty($pegawai->nip)) {
                \App\Models\Memiliki::updateOrCreate([
                    'nip' => $pegawai->nip,
                    'id_jabatan' => $jabatan->id_jabatan
                ]);
            }
        }

        app(\App\Services\AdminActivityLogService::class)->log(
            auth()->id(),
            'CREATE',
            'pegawai',
            $pegawai->id_pegawai,
            "Menambahkan pegawai baru: {$pegawai->nama_pegawai} (NIP: {$pegawai->nip})"
        );

        return $pegawai;
    }

    public function update($id, $data)
    {
        $pegawai = Pegawai::where('id_pegawai', $id)->firstOrFail();
        $oldNip = $pegawai->nip;

        $pegawai->update($data);

        // Jika unit_kerja diubah, update juga relasi di tabel memiliki
        if (isset($data['unit_kerja'])) {
            $jabatan = \App\Models\Jabatan::where('nama_jabatan', 'like', '%' . $pegawai->unit_kerja . '%')
                ->orWhere('id_jabatan', $pegawai->unit_kerja)
                ->first();

            if ($jabatan && !empty($pegawai->nip)) {
                // Hapus relasi memiliki yang lama
                if (!empty($oldNip)) {
                    \App\Models\Memiliki::where('nip', $oldNip)->delete();
                }

                \App\Models\Memiliki::updateOrCreate([
                    'nip' => $pegawai->nip,
                    'id_jabatan' => $jabatan->id_jabatan
                ]);
            }
        }

        app(\App\Services\AdminActivityLogService::class)->log(
            auth()->id(),
            'UPDATE',
            'pegawai',
            $pegawai->id_pegawai,
            "Memperbarui pegawai: {$pegawai->nama_pegawai} (NIP: {$pegawai->nip})"
        );

        return $pegawai;
    }

    public function delete($id)
    {
        $pegawai = Pegawai::where('id_pegawai', $id)->firstOrFail();

        // Bersihkan data pivot jika ada
        if (!empty($pegawai->nip)) {
            \App\Models\Memiliki::where('nip', $pegawai->nip)->delete();
        }

        $pegawai->delete();

        app(\App\Services\AdminActivityLogService::class)->log(
            auth()->id(),
            'DELETE',
            'pegawai',
            $pegawai->id_pegawai,
            "Menghapus pegawai: {$pegawai->nama_pegawai} (NIP: {$pegawai->nip})"
        );

        return ['message' => 'Deleted'];
    }
}