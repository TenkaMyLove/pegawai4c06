<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\GradeService;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    public function index(Request $request, GradeService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
        ]);

        try {
            return response()->json([
                'data' => $service->index($request->id_kelas, $request->id_mk)
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }

    public function store(Request $request, GradeService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
            'data' => 'required|array',
            'data.*.nim' => 'required|string',
            'data.*.participation_score' => 'nullable|numeric|min:0|max:100',
            'data.*.assignment_score' => 'nullable|numeric|min:0|max:100',
            'data.*.quiz_score' => 'nullable|numeric|min:0|max:100',
            'data.*.uts_score' => 'nullable|numeric|min:0|max:100',
            'data.*.uas_score' => 'nullable|numeric|min:0|max:100',
        ]);

        try {
            return response()->json([
                'message' => 'Nilai berhasil disimpan',
                'data' => $service->store($request->all())
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }

    public function getSettings(Request $request, GradeService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
        ]);

        try {
            return response()->json([
                'data' => $service->getSettings($request->id_kelas, $request->id_mk)
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }

    public function updateSettings(Request $request, GradeService $service)
    {
        $request->validate([
            'id_kelas' => 'required|string',
            'id_mk' => 'required|string',
            'participation' => 'required|numeric|min:0|max:100',
            'assignment' => 'required|numeric|min:0|max:100',
            'quiz' => 'required|numeric|min:0|max:100',
            'uts' => 'required|numeric|min:0|max:100',
            'uas' => 'required|numeric|min:0|max:100',
        ]);

        try {
            return response()->json([
                'message' => 'Pengaturan nilai berhasil diperbarui',
                'data' => $service->updateSettings(
                    $request->id_kelas,
                    $request->id_mk,
                    $request->only([
                        'participation',
                        'assignment',
                        'quiz',
                        'uts',
                        'uas',
                    ])
                )
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }
}