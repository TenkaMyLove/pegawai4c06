<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Grade extends Model
{
    protected $connection = 'pegawai';
    protected $table = 'grades';

    protected $fillable = [
        'id_dosen',
        'nim',
        'id_kelas',
        'id_mk',
        'participation_score',
        'assignment_score',
        'quiz_score',
        'uts_score',
        'uas_score',
        'final_score',
        'grade',
    ];
}