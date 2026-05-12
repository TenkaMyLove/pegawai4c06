<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KelasSession extends Model
{
    protected $fillable = [
        'KELAS_ID',
        'KODE_PERTEMUAN',
        'IS_ACTIVE',
        'STARTED_AT',
        'ENDED_AT'
    ];
}
