<?php

namespace App\Services;

use App\Models\Dosen;
use App\Models\PesertaKelasMk;
use App\Models\Mahasiswa\AbsensiMahasiswa;
use Illuminate\Support\Facades\Auth;

class RekapAbsensiService
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

    public function index($idKelas, $idMk, $kodePertemuan)
    {
        $dosen = $this->getDosen();

        $this->validateKelasOwnership($dosen, $idKelas, $idMk);

        $peserta = PesertaKelasMk::where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->orderBy('no_urut')
            ->get();

        $absensi = AbsensiMahasiswa::where('KELAS_ID', (string) $idKelas)
            ->where('ID_MK', (string) $idMk)
            ->where('KODE_PERTEMUAN', (int) $kodePertemuan)
            ->get()
            ->keyBy('NIM');

        $summary = [
            'H' => 0,
            'I' => 0,
            'S' => 0,
            'A' => 0,
        ];

        $data = $peserta->map(function ($mhs) use ($absensi, &$summary) {
            $absen = $absensi->get($mhs->nim);

            $status = $absen ? $absen->STATUS : 'A';
            $metode = $absen ? $absen->METODE : null;

            if (isset($summary[$status])) {
                $summary[$status]++;
            }

            return [
                'nim' => $mhs->nim,
                'nama' => $mhs->nama,
                'status' => $status,
                'metode' => $metode,
            ];
        });

        return [
            'id_kelas' => (string) $idKelas,
            'id_mk' => (string) $idMk,
            'kode_pertemuan' => (int) $kodePertemuan,
            'summary' => $summary,
            'data' => $data,
        ];
    }
}