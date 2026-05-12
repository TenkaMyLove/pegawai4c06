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
            'kelas_id' => 'required',
            'kode_pertemuan' => 'required'
        ]);

        return $service->getRekap(
            $request->kelas_id,
            $request->kode_pertemuan
        );
    }
}