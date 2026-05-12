<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kelas extends Model
{
    protected $table = 'kelas';

    protected $primaryKey = 'ID_KELAS';

    public $incrementing = false;

    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
        'ID_KELAS',
        'NAMA_KELAS',
        'NIP_DOSEN',
        'KODE_MK'
    ];
}