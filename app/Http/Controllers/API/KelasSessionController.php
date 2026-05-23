<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\KelasSessionService;

class KelasSessionController extends Controller
{
    public function start(Request $request, KelasSessionService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
        ]);

        try {
            return response()->json([
                'message' => 'Sesi kelas berhasil dimulai',
                'data' => $service->start(
                    $request->id_kelas,
                    $request->id_mk
                )
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }

    public function end(Request $request, KelasSessionService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
        ]);

        try {
            return response()->json([
                'message' => 'Sesi kelas berhasil diakhiri',
                'data' => $service->end(
                    $request->id_kelas,
                    $request->id_mk
                )
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }
}