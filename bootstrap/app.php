<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\HandleCors;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
    web: __DIR__.'/../routes/web.php',
    api: __DIR__.'/../routes/api.php',
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
)
->withMiddleware(function (Middleware $middleware): void {
    $middleware->api();

    $middleware->append(HandleCors::class);

    $middleware->alias([
        'auth' => \App\Http\Middleware\Authenticate::class,
        'admin' => \App\Http\Middleware\AdminOnly::class,
        'dosen' => \App\Http\Middleware\DosenOnly::class,
    ]);
})
->withExceptions(function (Exceptions $exceptions): void {

    // FORCE API to return JSON
    $exceptions->shouldRenderJsonWhen(function ($request, $e) {
        return $request->is('api/*');
    });

    $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e, $request) {
        return response()->json([
            'error' => 'Unauthenticated'
        ], 401);
    });

})
    ->create();
