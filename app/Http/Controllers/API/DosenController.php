<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Dosen;

class DosenController extends Controller
{
    public function index()
    {
        return response()->json(
            Dosen::with(['pegawai', 'user'])->get()
        );
    }

    public function show($id)
    {
        return response()->json(
            Dosen::with(['pegawai', 'user'])->findOrFail($id)
        );
    }

    public function store(Request $request)
    {
        $dosen = Dosen::create($request->all());

        app(\App\Services\AdminActivityLogService::class)->log(
            auth()->id(),
            'CREATE',
            'dosen',
            $dosen->id_dosen,
            "Menambahkan dosen baru: {$dosen->nama_dosen}"
        );

        return response()->json($dosen, 201);
    }

    public function update($id, Request $request)
    {
        $dosen = Dosen::findOrFail($id);

        $dosen->update($request->all());

        app(\App\Services\AdminActivityLogService::class)->log(
            auth()->id(),
            'UPDATE',
            'dosen',
            $dosen->id_dosen,
            "Memperbarui dosen: {$dosen->nama_dosen}"
        );

        return response()->json($dosen);
    }

    public function destroy($id)
    {
        $dosen = Dosen::findOrFail($id);

        $dosen->delete();

        app(\App\Services\AdminActivityLogService::class)->log(
            auth()->id(),
            'DELETE',
            'dosen',
            $dosen->id_dosen,
            "Menghapus dosen: {$dosen->nama_dosen}"
        );

        return response()->json([
            'message' => 'Dosen deleted'
        ]);
    }
}