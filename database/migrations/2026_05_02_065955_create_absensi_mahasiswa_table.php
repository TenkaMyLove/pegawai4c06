<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('absensi_mahasiswa', function (Blueprint $table) {
            $table->id('ID_ABSENSI');
            $table->string('NIM');
            $table->string('KELAS_ID');
            $table->date('TANGGAL');
            $table->enum('STATUS', ['H','S','I','A']);
            $table->string('METODE');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('absensi_mahasiswa');
    }
};
