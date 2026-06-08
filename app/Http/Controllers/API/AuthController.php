<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Pegawai;
use App\Models\Dosen;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        $localSuccess = $user && Hash::check($request->password, $user->password);

        if (!$localSuccess) {
            try {
                $rifkiResponse = Http::timeout(10)->post('https://api-admin-4c.rifkiaja.my.id:9002/api/auth/login', [
                    'email' => $request->email,
                    'password' => $request->password,
                ]);

                if ($rifkiResponse->successful()) {
                    $rifkiData = $rifkiResponse->json();
                    $wrapper = $rifkiData['data'] ?? $rifkiData ?? [];
                    $baseUser = $rifkiData['user'] ?? $wrapper['user'] ?? $wrapper;

                    $email = $baseUser['email'] ?? $request->email;
                    $name = $baseUser['name'] ?? $baseUser['nama'] ?? $baseUser['nama_pegawai'] ?? $baseUser['nama_dosen'] ?? 'Dosen Rifki';

                    // Find or create local user
                    $user = User::where('email', $email)->first();
                    if (!$user) {
                        $user = new User();
                        $user->email = $email;
                    }
                    $user->name = $name;
                    $user->password = Hash::make($request->password);
                    $user->role = 'dosen';
                    $user->save();

                    // Find or create local Pegawai
                    $pegawai = Pegawai::where('id_user', $user->id)->first();
                    if (!$pegawai) {
                        $pegawai = new Pegawai();
                        $pegawai->id_user = $user->id;
                    }
                    $pegawai->nip = $baseUser['nip'] ?? $baseUser['NIP'] ?? '1999999999';
                    $pegawai->nama_pegawai = $name;
                    $pegawai->status_aktif = 1;
                    $pegawai->save();

                    // Find or create local Dosen
                    $dosen = Dosen::where('id_user', $user->id)->first();
                    if (!$dosen) {
                        $dosen = new Dosen();
                        $dosen->id_user = $user->id;
                        $dosen->id_pegawai = $pegawai->id_pegawai;
                    }
                    $dosen->nama_dosen = $name;
                    $dosen->email = $email;
                    $dosen->status_aktif = 1;
                    $dosen->save();

                    $localSuccess = true;
                }
            } catch (\Exception $e) {
                // Fallback to local failed behavior
            }
        }

        if (!$localSuccess) {
            return response()->json([
                'error' => 'Login gagal'
            ], 401);
        }

        $pegawai = Pegawai::with('jabatan')
            ->where('id_user', $user->id)
            ->first();

        $dosen = Dosen::where('id_user', $user->id)
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