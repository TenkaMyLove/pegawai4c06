<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\{
    AuthController,
    QrController,
    QrScanController,
    AbsensiMahasiswaController,
    KelasSessionController,
    DosenController,
    RekapAbsensiController,
    DashboardController,
    PegawaiController,
    AbsensiPegawaiController,
    TugasKelasController,
    MateriKelasController,
    ProfilPegawaiController,
    JadwalMengajarController,
    AdminActivityLogController
};

Route::post('/login', [AuthController::class, 'login']);
Route::post('/qr/scan', [QrScanController::class, 'scan']);

Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/pegawai/profile', [ProfilPegawaiController::class, 'show']);
    Route::put('/pegawai/profile', [ProfilPegawaiController::class, 'update']);    
    Route::post('/pegawai/absensi/masuk', [AbsensiPegawaiController::class, 'masuk']);
    Route::post('/pegawai/absensi/keluar', [AbsensiPegawaiController::class, 'keluar']);
    Route::get('/pegawai/absensi/hari-ini', [AbsensiPegawaiController::class, 'hariIni']);
    Route::get('/pegawai/absensi/rekap', [AbsensiPegawaiController::class, 'rekap']);
});

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/admin/activity-logs', [AdminActivityLogController::class, 'index']);
    Route::get('/dashboard/pegawai', [DashboardController::class, 'pegawai']);
    Route::get('/dosen', [DosenController::class, 'index']);
    Route::get('/dosen/{id}', [DosenController::class, 'show']);
    Route::post('/dosen', [DosenController::class, 'store']);
    Route::put('/dosen/{id}', [DosenController::class, 'update']);
    Route::delete('/dosen/{id}', [DosenController::class, 'destroy']);

    Route::get('/pegawai', [PegawaiController::class, 'index']);
    Route::post('/pegawai', [PegawaiController::class, 'store']);
    Route::get('/pegawai/{id}', [PegawaiController::class, 'show']);
    Route::put('/pegawai/{id}', [PegawaiController::class, 'update']);
    Route::delete('/pegawai/{id}', [PegawaiController::class, 'destroy']);
});

Route::middleware(['auth:sanctum', 'dosen'])->group(function () {
    Route::get('/jadwal-mengajar', [JadwalMengajarController::class, 'index']);
    Route::get('/dashboard/dosen', [DashboardController::class, 'dosen']);
    Route::apiResource('/materi', MateriKelasController::class);
    Route::apiResource('/tugas', TugasKelasController::class);
    Route::get('/absensi/rekap', [RekapAbsensiController::class, 'index']);
    Route::post('/kelas/start', [KelasSessionController::class, 'start']);
    Route::post('/kelas/end', [KelasSessionController::class, 'end']);
    Route::post('/qr/generate', [QrController::class, 'generate']);
    Route::post('/absensi/manual', [AbsensiMahasiswaController::class, 'manual']);
});

Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);