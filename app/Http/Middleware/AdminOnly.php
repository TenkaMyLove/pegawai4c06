<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminOnly
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle($request, Closure $next)
    {
    $allowedRoles = ['admin', 'super_admin', 'admin_akademik', 'admin_pegawai'];
    if (!$request->user() || !in_array($request->user()->role, $allowedRoles)) {
        return response()->json(['error' => 'Unauthorized'], 403);
    }

    return $next($request);
  }
}