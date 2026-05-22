<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;

class DashboardController extends Controller
{
    public function dosen(DashboardService $service)
    {
        return response()->json([
            'data' => $service->dosen()
        ]);
    }

    public function pegawai(DashboardService $service)
    {
        return response()->json([
            'data' => $service->pegawai()
        ]);
    }
}