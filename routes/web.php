<?php

use Illuminate\Support\Facades\Route;

Route::fallback(function () {
    $path = public_path('index.html');
    if (file_exists($path)) {
        return file_get_contents($path);
    }
    return response('Frontend not built. Run npm run build in the frontend directory.', 404);
});
