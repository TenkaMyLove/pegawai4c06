<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\PegawaiService;

class DosenController extends Controller
{
    public function index(PegawaiService $service)
    {
        return response()->json($service->getAll());
    }

    public function show($id, PegawaiService $service)
    {
        return response()->json($service->getById($id));
    }

    public function store(Request $request, PegawaiService $service)
    {
        return response()->json($service->create($request->all()), 201);
    }

    public function update($id, Request $request, PegawaiService $service)
    {
        return response()->json($service->update($id, $request->all()));
    }

    public function destroy($id, PegawaiService $service)
    {
        return response()->json($service->delete($id));
    }
}