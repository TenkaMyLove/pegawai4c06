<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\RekapAbsensiService;

class RekapAbsensiController extends Controller
{
    public function index(Request $request, RekapAbsensiService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
            'kode_pertemuan' => 'required|integer',
        ]);

        try {
            return response()->json(
                $service->index(
                    $request->id_kelas,
                    $request->id_mk,
                    $request->kode_pertemuan
                )
            );
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }
}