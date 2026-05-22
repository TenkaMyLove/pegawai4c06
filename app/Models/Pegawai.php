<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pegawai extends Model
{
    protected $connection = 'pegawai';
    protected $table = 'pegawai';
    protected $primaryKey = 'id_pegawai';

    public $timestamps = false;

    protected $fillable = [
        'nip',
        'nik',
        'nama_pegawai',
        'jenis_kelamin',
        'alamat',
        'unit_kerja',
        'id_user',
    ];

    public function jabatan()
    {
        return $this->belongsToMany(
            Jabatan::class,
            'memiliki',
            'nip',
            'id_jabatan',
            'nip',
            'id_jabatan'
        );
    }

    public function absensi()
    {
        return $this->hasMany(
            AbsensiPegawai::class,
            'id_pegawai',
            'id_pegawai'
        );
    }
}