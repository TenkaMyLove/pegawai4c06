<?php

namespace App\Services;

use App\Models\Dosen;
use App\Models\Grade;
use App\Models\GradeSetting;
use App\Models\PesertaKelasMk;
use Illuminate\Support\Facades\Auth;

class GradeService
{
    private function getDosen()
    {
        return Dosen::where('id_user', Auth::id())->firstOrFail();
    }

    private function validateOwnership($dosen, $idKelas, $idMk)
    {
        $owned = PesertaKelasMk::where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->where('id_pegawai', (int) $dosen->id_pegawai)
            ->exists();

        if (!$owned) {
            throw new \Exception('Anda tidak memiliki akses ke kelas dan mata kuliah ini');
        }
    }

    private function validateStudent($nim, $idKelas, $idMk)
    {
        $exists = PesertaKelasMk::where('nim', $nim)
            ->where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->exists();

        if (!$exists) {
            throw new \Exception("Mahasiswa {$nim} tidak terdaftar di kelas dan mata kuliah ini");
        }
    }

    private function getSetting($dosen, $idKelas, $idMk)
    {
        return GradeSetting::firstOrCreate(
            [
                'id_dosen' => $dosen->id_dosen,
                'id_kelas' => (string) $idKelas,
                'id_mk' => (string) $idMk,
            ],
            [
                'participation' => 10,
                'assignment' => 20,
                'quiz' => 10,
                'uts' => 30,
                'uas' => 30,
            ]
        );
    }

    private function calculateFinal($data, $setting)
    {
        return round(
            (($data['participation_score'] ?? 0) * $setting->participation / 100) +
            (($data['assignment_score'] ?? 0) * $setting->assignment / 100) +
            (($data['quiz_score'] ?? 0) * $setting->quiz / 100) +
            (($data['uts_score'] ?? 0) * $setting->uts / 100) +
            (($data['uas_score'] ?? 0) * $setting->uas / 100),
            2
        );
    }

    private function determineGrade($finalScore)
    {
        if ($finalScore >= 85) return 'A';
        if ($finalScore >= 75) return 'B';
        if ($finalScore >= 65) return 'C';
        if ($finalScore >= 50) return 'D';
        return 'E';
    }

    public function getSettings($idKelas, $idMk)
    {
        $dosen = $this->getDosen();

        $this->validateOwnership($dosen, $idKelas, $idMk);

        return $this->getSetting($dosen, $idKelas, $idMk);
    }

    public function updateSettings($idKelas, $idMk, array $data)
    {
        $dosen = $this->getDosen();

        $this->validateOwnership($dosen, $idKelas, $idMk);

        $total =
            $data['participation'] +
            $data['assignment'] +
            $data['quiz'] +
            $data['uts'] +
            $data['uas'];

        if ($total != 100) {
            throw new \Exception('Total bobot nilai harus 100');
        }

        $setting = $this->getSetting($dosen, $idKelas, $idMk);

        $setting->update($data);

        return $setting;
    }

    public function index($idKelas, $idMk)
    {
        $dosen = $this->getDosen();

        $this->validateOwnership($dosen, $idKelas, $idMk);

        $students = PesertaKelasMk::where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->orderBy('no_urut')
            ->get();

        $grades = Grade::where('id_kelas', (string) $idKelas)
            ->where('id_mk', (string) $idMk)
            ->get()
            ->keyBy('nim');

        return $students->map(function ($student) use ($grades) {
            $grade = $grades->get($student->nim);

            return [
                'nim' => $student->nim,
                'nama' => $student->nama,
                'participation_score' => $grade->participation_score ?? 0,
                'assignment_score' => $grade->assignment_score ?? 0,
                'quiz_score' => $grade->quiz_score ?? 0,
                'uts_score' => $grade->uts_score ?? 0,
                'uas_score' => $grade->uas_score ?? 0,
                'final_score' => $grade->final_score ?? 0,
                'grade' => $grade->grade ?? null,
            ];
        });
    }

    public function store(array $payload)
    {
        $dosen = $this->getDosen();

        $idKelas = $payload['id_kelas'];
        $idMk = $payload['id_mk'];

        $this->validateOwnership($dosen, $idKelas, $idMk);

        $setting = $this->getSetting($dosen, $idKelas, $idMk);

        $results = [];

        foreach ($payload['data'] as $item) {
            $this->validateStudent($item['nim'], $idKelas, $idMk);

            $scoreData = [
                'participation_score' => $item['participation_score'] ?? 0,
                'assignment_score' => $item['assignment_score'] ?? 0,
                'quiz_score' => $item['quiz_score'] ?? 0,
                'uts_score' => $item['uts_score'] ?? 0,
                'uas_score' => $item['uas_score'] ?? 0,
            ];

            $finalScore = $this->calculateFinal($scoreData, $setting);

            $grade = Grade::updateOrCreate(
                [
                    'id_kelas' => (string) $idKelas,
                    'id_mk' => (string) $idMk,
                    'nim' => $item['nim'],
                ],
                [
                    'id_dosen' => $dosen->id_dosen,
                    ...$scoreData,
                    'final_score' => $finalScore,
                    'grade' => $this->determineGrade($finalScore),
                ]
            );

            $results[] = $grade;
        }

        return $results;
    }
}