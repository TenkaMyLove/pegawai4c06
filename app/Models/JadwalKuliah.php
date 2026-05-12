<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JadwalKuliah extends Model
{
    protected $table = 'jadwal_kuliah';

    protected $fillable = [
        'KELAS_ID',
        'HARI',
        'JAM_MULAI',
        'JAM_SELESAI',
        'RUANG'
    ];
}