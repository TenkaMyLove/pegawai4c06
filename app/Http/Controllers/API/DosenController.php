<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\PegawaiService;

class DosenController extends Controller
{
    public function index(PegawaiService $service)
    {
        return $service->getAll();
    }

    public function store(Request $request, PegawaiService $service)
    {
        return $service->create($request->all());
    }

    public function update($id, Request $request, PegawaiService $service)
    {
        return $service->update($id, $request->all());
    }

    public function destroy($id, PegawaiService $service)
    {
        return $service->delete($id);
    }
}
