<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\QrService;

class QrController extends Controller
{
    public function generate(Request $request, QrService $service)
    {
        return $service->generate($request->kelas_id);
    }
}