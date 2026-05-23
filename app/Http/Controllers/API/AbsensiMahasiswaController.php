<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\AbsensiMahasiswaService;

class AbsensiMahasiswaController extends Controller
{
    public function manual(Request $request, AbsensiMahasiswaService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
            'data' => 'required|array',
            'data.*.nim' => 'required|string',
            'data.*.status' => 'required|in:H,S,I,A',
            'data.*.kode_pertemuan' => 'required|integer|min:1|max:16'
        ]);

        try {
            return response()->json(
                $service->manual(
                    $request->id_kelas,
                    $request->id_mk,
                    $request->data
                )
            );
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }
}