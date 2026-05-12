<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pegawai extends Model
{
    protected $table = 'pegawai';

    // 👉 ADD THIS (very important)
    protected $primaryKey = 'NIP';
    public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
        'NIP',
        'NIK',
        'NAMA_PEGAWAI',
        'JENIS_KELAMIN',
        'ID_PROVINSI',
        'ALAMAT',
        'ID_KAB',
        'UNIT_KERJA',
        'ID_USER'
    ];
}