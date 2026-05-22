<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Jabatan extends Model
{
    protected $connection = 'pegawai';
    protected $table = 'jabatan';
    protected $primaryKey = 'id_jabatan';

    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'id_jabatan',
        'nama_jabatan',
    ];

    public function pegawai()
    {
        return $this->belongsToMany(
            Pegawai::class,
            'memiliki',
            'id_jabatan',
            'nip',
            'id_jabatan',
            'nip'
        );
    }
}