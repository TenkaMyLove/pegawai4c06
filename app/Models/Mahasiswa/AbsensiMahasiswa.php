<?php

namespace App\Models\Mahasiswa;

use Illuminate\Database\Eloquent\Model;

class AbsensiMahasiswa extends Model
{
    protected $connection = 'mysql';
    protected $table = 'absensi_mahasiswa';
    protected $primaryKey = 'ID_ABSENSI';

    public $timestamps = false;

    protected $fillable = [
        'NIM',
        'ID_MK',
        'KELAS_ID',
        'KODE_PERTEMUAN',
        'TANGGAL',
        'STATUS',
        'METODE'
    ];

    protected $casts = [
        'TANGGAL' => 'date'
    ];
}