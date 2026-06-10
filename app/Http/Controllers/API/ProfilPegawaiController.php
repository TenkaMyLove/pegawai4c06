<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\ProfilPegawaiService;
use Illuminate\Http\Request;

class ProfilPegawaiController extends Controller
{
    public function show(Request $request, ProfilPegawaiService $service)
    {
        return response()->json([
            'data' => $service->getProfile($request->user()->id)
        ]);
    }

    public function update(Request $request, ProfilPegawaiService $service)
    {
        $request->validate([
            'alamat' => 'nullable|string|max:255',
            'jenis_kelamin' => 'nullable|in:L,P',
            'nik' => 'nullable|string|max:255',
        ]);

        $user = $request->user();
        $isAdmin = strtolower($user->role ?? '') === 'admin';

        $allowedFields = ['alamat', 'nik'];

        return response()->json([
            'message' => 'Profil berhasil diperbarui',
            'data' => $service->updateProfile(
                $user->id,
                $request->only($allowedFields)
            )
        ]);
    }
}