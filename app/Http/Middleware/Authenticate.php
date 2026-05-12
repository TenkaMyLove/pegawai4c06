<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    protected function redirectTo($request)
    {
        // API should NEVER redirect
        if ($request->is('api/*')) {
            return null;
        }

        return route('login'); // fallback (not used for API)
    }
}