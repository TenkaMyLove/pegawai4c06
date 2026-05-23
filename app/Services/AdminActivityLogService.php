<?php

namespace App\Services;

use App\Models\AdminActivityLog;

class AdminActivityLogService
{
    public function getAll()
    {
        return AdminActivityLog::orderBy('created_at', 'desc')->get();
    }

    public function log($userId, $aksi, $targetTable = null, $targetId = null, $deskripsi = null)
    {
        return AdminActivityLog::create([
            'id_user' => $userId,
            'aksi' => $aksi,
            'target_table' => $targetTable,
            'target_id' => $targetId,
            'deskripsi' => $deskripsi,
        ]);
    }
}