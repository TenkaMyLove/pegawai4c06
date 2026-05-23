<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\AdminActivityLogService;

class AdminActivityLogController extends Controller
{
    public function index(AdminActivityLogService $service)
    {
        return response()->json([
            'data' => $service->getAll()
        ]);
    }
}