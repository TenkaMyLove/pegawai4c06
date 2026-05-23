<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\JadwalMengajarService;
use Illuminate\Http\Request;

class JadwalMengajarController extends Controller
{
    public function index(Request $request, JadwalMengajarService $service)
    {
        return response()->json([
            'data' => $service->getJadwal($request->user()->id)
        ]);
    }
}