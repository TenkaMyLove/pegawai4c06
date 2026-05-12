<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class Pegawai extends Model
{
    protected $table = 'pegawai';

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

    public function user()
    {
        return $this->belongsTo(User::class, 'ID_USER');
    }
}