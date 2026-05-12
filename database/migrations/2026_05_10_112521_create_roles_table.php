<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id('ID_ROLE');
            $table->string('NAMA_ROLE');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('roles');
    }
};