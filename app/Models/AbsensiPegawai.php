<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AbsensiPegawai extends Model
{
    protected $connection = 'pegawai';
    protected $table = 'absensi_pegawai';
    protected $primaryKey = 'id_absensi';

    public $timestamps = false;

    protected $fillable = [
        'id_pegawai',
        'tanggal',
        'waktu_masuk',
        'waktu_keluar',
        'keterangan',
    ];

    public function pegawai()
    {
        return $this->belongsTo(
            Pegawai::class,
            'id_pegawai',
            'id_pegawai'
        );
    }
}