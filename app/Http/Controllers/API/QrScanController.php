<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\QrScanService;

class QrScanController extends Controller
{
    public function scan(Request $request, QrScanService $service)
{
    $result = $service->scan(
        $request->nim,
        $request->token
    );

    if (!$result['success']) {
        return response()->json($result, 400);
    }

    return response()->json($result);
    }
}