<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Memiliki extends Model
{
    protected $connection = 'pegawai';
    protected $table = 'memiliki';

    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'id_jabatan',
        'nip',
    ];

    public function pegawai()
    {
        return $this->belongsTo(
            Pegawai::class,
            'nip',
            'nip'
        );
    }

    public function jabatan()
    {
        return $this->belongsTo(
            Jabatan::class,
            'id_jabatan',
            'id_jabatan'
        );
    }
}