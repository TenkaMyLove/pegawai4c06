<?php

namespace App\Services;

use App\Models\Dosen;
use App\Models\PesertaKelasMk;
use App\Models\Mahasiswa\AbsensiMahasiswa;
use Illuminate\Support\Facades\Auth;

class AbsensiMahasiswaService
{
    private function getDosen()
    {
        return Dosen::where('id_user', Auth::id())->firstOrFail();
    }

    private function validateKelasOwnership($dosen, $idKelas, $idMk)
    {
        $owned = PesertaKelasMk::where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->where('id_pegawai', (int) $dosen->id_pegawai)
            ->exists();

        if (!$owned) {
            throw new \Exception("Anda tidak memiliki akses ke kelas dan mata kuliah ini");
        }
    }

    private function validateMahasiswaInClass($nim, $idKelas, $idMk)
    {
        $exists = PesertaKelasMk::where('nim', $nim)
            ->where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->exists();

        if (!$exists) {
            throw new \Exception("Mahasiswa {$nim} tidak terdaftar di kelas dan mata kuliah ini");
        }
    }

    public function manual($idKelas, $idMk, array $data)
    {
        $dosen = $this->getDosen();

        $this->validateKelasOwnership($dosen, $idKelas, $idMk);

        $results = [];

        foreach ($data as $item) {
            $nim = $item['nim'];
            $status = $item['status'];
            $kodePertemuan = $item['kode_pertemuan'];

            $this->validateMahasiswaInClass($nim, $idKelas, $idMk);

            $absen = AbsensiMahasiswa::updateOrCreate(
                [
                    'NIM' => $nim,
                    'KELAS_ID' => $idKelas,
                    'ID_MK' => $idMk,
                    'KODE_PERTEMUAN' => $kodePertemuan,
                ],
                [
                    'TANGGAL' => now()->toDateString(),
                    'STATUS' => $status,
                    'METODE' => 'MANUAL',
                ]
            );

            $results[] = $absen;
        }

        return [
            'message' => 'Absensi manual berhasil disimpan',
            'data' => $results,
        ];
    }
}