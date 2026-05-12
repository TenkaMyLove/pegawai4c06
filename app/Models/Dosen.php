<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Dosen extends Model
{
    protected $table = 'dosen';

    protected $primaryKey = 'NIP_DOSEN';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'NIP_DOSEN',
        'DOSEN_NAMA',
        'ID_USER'
    ];
}