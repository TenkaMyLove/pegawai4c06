<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GradeSetting extends Model
{
    protected $connection = 'pegawai';
    protected $table = 'grade_settings';

    protected $fillable = [
        'id_dosen',
        'id_kelas',
        'id_mk',
        'participation',
        'assignment',
        'quiz',
        'uts',
        'uas',
    ];
}