<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kelas_sessions', function (Blueprint $table) {
            $table->id();

            $table->string('KELAS_ID');
            $table->unsignedTinyInteger('KODE_PERTEMUAN');

            $table->boolean('IS_ACTIVE')->default(true);

            $table->timestamp('STARTED_AT');
            $table->timestamp('ENDED_AT')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kelas_sessions');
    }
};