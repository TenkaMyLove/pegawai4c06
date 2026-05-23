<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\QrService;

class QrController extends Controller
{
    public function generate(Request $request, QrService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
        ]);

        try {
            return response()->json([
                'data' => $service->generate(
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