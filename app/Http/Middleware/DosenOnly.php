<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class DosenOnly
{
    public function handle(Request $request, Closure $next)
    {
        if (!auth()->check()) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        if (auth()->user()->role !== 'dosen') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return $next($request);
    }
}