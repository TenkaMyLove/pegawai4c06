<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\PegawaiService;
use Illuminate\Http\Request;

class PegawaiController extends Controller
{
    public function index(PegawaiService $service)
    {
        return response()->json([
            'data' => $service->getAll()
        ]);
    }

    public function show($id, PegawaiService $service)
    {
        return response()->json([
            'data' => $service->getById($id)
        ]);
    }

    public function store(Request $request, PegawaiService $service)
    {
        return response()->json([
            'message' => 'Pegawai berhasil ditambahkan',
            'data' => $service->create($request->all())
        ], 201);
    }

    public function update($id, Request $request, PegawaiService $service)
    {
        return response()->json([
            'message' => 'Pegawai berhasil diperbarui',
            'data' => $service->update($id, $request->all())
        ]);
    }

    public function destroy($id, PegawaiService $service)
    {
        return response()->json($service->delete($id));
    }
}