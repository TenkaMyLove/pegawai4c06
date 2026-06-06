<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Pegawai;
use App\Models\Dosen;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'error' => 'Login gagal'
            ], 401);
        }

        $pegawai = Pegawai::with('jabatan')
            ->where('id_user', $user->id)
            ->first();

        $dosen = Dosen::where('id_user', $user->id)
            ->where('id_user', $user->id)
            ->first();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'pegawai' => $pegawai,
            'dosen' => $dosen,
            'permissions' => [
                'is_admin' => in_array($user->role, ['admin', 'super_admin', 'admin_akademik', 'admin_pegawai']),
                'is_pegawai' => $pegawai !== null,
                'is_dosen' => $dosen !== null,
            ],
        ]);
    }
    public function logout(Request $request)
{
    $request->user()->currentAccessToken()->delete();

    return response()->json([
        'message' => 'Logout berhasil'
    ]);
}
}