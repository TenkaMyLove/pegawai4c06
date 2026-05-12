<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QrSession extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'KELAS_ID',
        'KODE_PERTEMUAN',
        'TOKEN',
        'EXPIRED_AT'
    ];
}