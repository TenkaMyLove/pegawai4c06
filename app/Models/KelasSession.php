<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KelasSession extends Model
{
    protected $fillable = [
        'KELAS_ID',
        'ID_MK',
        'KODE_PERTEMUAN',
        'STARTED_AT',
        'ENDED_AT',
        'IS_ACTIVE',
    ];
}
