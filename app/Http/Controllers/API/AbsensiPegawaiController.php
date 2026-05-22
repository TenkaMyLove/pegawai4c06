<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\AbsensiPegawaiService;
use Illuminate\Http\Request;

class AbsensiPegawaiController extends Controller
{
    public function masuk(Request $request, AbsensiPegawaiService $service)
    {
        $result = $service->masuk(
            $request->user()->id,
            $request->keterangan
        );

        return response()->json([
            'message' => $result['message'],
            'data' => $result['data'],
        ], $result['status']);
    }

    public function keluar(Request $request, AbsensiPegawaiService $service)
    {
        $result = $service->keluar($request->user()->id);

        return response()->json([
            'message' => $result['message'],
            'data' => $result['data'],
        ], $result['status']);
    }

    public function hariIni(Request $request, AbsensiPegawaiService $service)
    {
        return response()->json([
            'data' => $service->hariIni($request->user()->id),
        ]);
    }

    public function rekap(Request $request, AbsensiPegawaiService $service)
    {
        return response()->json([
            'data' => $service->rekap(
                $request->user()->id,
                $request->bulan,
                $request->tanggal_mulai,
                $request->tanggal_selesai
            ),
        ]);
    }
}