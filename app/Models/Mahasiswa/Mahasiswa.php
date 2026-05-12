<?php

namespace App\Models\Mahasiswa;

use Illuminate\Database\Eloquent\Model;

class Mahasiswa extends Model
{
    protected $connection = 'mysql_main';
    protected $table = 'mahasiswa';
    protected $primaryKey = 'NIM';

    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;
}