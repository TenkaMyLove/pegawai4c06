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
            'kelas_id' => 'required'
        ]);

        try {
            return $service->start($request->kelas_id);
        } catch (\Throwable $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    public function end(Request $request, KelasSessionService $service)
    {
        $request->validate([
            'kelas_id' => 'required'
        ]);

        try {
            return $service->end($request->kelas_id);
        } catch (\Throwable $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}