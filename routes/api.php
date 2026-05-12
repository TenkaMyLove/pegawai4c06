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
    DashboardController
};

Route::post('/login', [AuthController::class, 'login']);
Route::post('/qr/scan', [QrScanController::class, 'scan']);

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/dosen', [DosenController::class, 'index']);
    Route::post('/dosen', [DosenController::class, 'store']);
    Route::put('/dosen/{id}', [DosenController::class, 'update']);
    Route::delete('/dosen/{id}', [DosenController::class, 'destroy']);

});

Route::middleware(['auth:sanctum', 'dosen'])->group(function () {
    Route::get('/dashboard/dosen', [DashboardController::class, 'dosen']);
    Route::get('/absensi/rekap', [RekapAbsensiController::class, 'index']);
    Route::post('/kelas/start', [KelasSessionController::class, 'start']);
    Route::post('/kelas/end', [KelasSessionController::class, 'end']);
    Route::post('/qr/generate', [QrController::class, 'generate']);
    Route::post('/absensi/manual', [AbsensiMahasiswaController::class, 'manual']);
});