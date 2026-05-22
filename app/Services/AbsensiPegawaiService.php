<?php

namespace App\Services;

use App\Models\Pegawai;
use App\Models\AbsensiPegawai;
use Carbon\Carbon;

class AbsensiPegawaiService
{
    public function masuk($userId, $keterangan = null)
    {
        $pegawai = Pegawai::where('id_user', $userId)->firstOrFail();
        $today = Carbon::today()->toDateString();

        $absensi = AbsensiPegawai::where('id_pegawai', $pegawai->id_pegawai)
            ->where('tanggal', $today)
            ->first();

        if ($absensi && $absensi->waktu_masuk) {
            return [
                'status' => 409,
                'message' => 'Sudah presensi masuk hari ini',
                'data' => $absensi,
            ];
        }

        $absensi = AbsensiPegawai::create([
            'id_pegawai' => $pegawai->id_pegawai,
            'tanggal' => $today,
            'waktu_masuk' => Carbon::now()->format('H:i:s'),
            'keterangan' => $keterangan,
        ]);

        return [
            'status' => 200,
            'message' => 'Presensi masuk berhasil',
            'data' => $absensi,
        ];
    }

    public function keluar($userId)
    {
        $pegawai = Pegawai::where('id_user', $userId)->firstOrFail();
        $today = Carbon::today()->toDateString();

        $absensi = AbsensiPegawai::where('id_pegawai', $pegawai->id_pegawai)
            ->where('tanggal', $today)
            ->firstOrFail();

        if ($absensi->waktu_keluar) {
            return [
                'status' => 409,
                'message' => 'Sudah presensi keluar hari ini',
                'data' => $absensi,
            ];
        }

        $absensi->update([
            'waktu_keluar' => Carbon::now()->format('H:i:s'),
        ]);

        return [
            'status' => 200,
            'message' => 'Presensi keluar berhasil',
            'data' => $absensi,
        ];
    }

    public function hariIni($userId)
    {
        $pegawai = Pegawai::where('id_user', $userId)->firstOrFail();

        return AbsensiPegawai::where('id_pegawai', $pegawai->id_pegawai)
            ->where('tanggal', Carbon::today()->toDateString())
            ->first();
    }

    public function rekap($userId, $bulan = null, $tanggalMulai = null, $tanggalSelesai = null)
    {
        $pegawai = Pegawai::where('id_user', $userId)->firstOrFail();

        $query = AbsensiPegawai::where('id_pegawai', $pegawai->id_pegawai);

        if ($bulan) {
            $query->whereMonth('tanggal', $bulan);
        }

        if ($tanggalMulai) {
            $query->whereDate('tanggal', '>=', $tanggalMulai);
        }

        if ($tanggalSelesai) {
            $query->whereDate('tanggal', '<=', $tanggalSelesai);
        }

        return $query
            ->orderBy('tanggal', 'desc')
            ->get();
    }
}