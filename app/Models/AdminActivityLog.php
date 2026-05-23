<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AdminActivityLog extends Model
{
    protected $connection = 'pegawai';

    protected $table = 'admin_activity_logs';

    protected $primaryKey = 'id_log';

    protected $fillable = [
        'id_user',
        'aksi',
        'target_table',
        'target_id',
        'deskripsi',
    ];
}