<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('absensi_mahasiswa', function (Blueprint $table) {
            $table->renameColumn('PERTEMUAN', 'KODE_PERTEMUAN');
        });
    }

    public function down(): void
    {
        Schema::table('absensi_mahasiswa', function (Blueprint $table) {
            $table->renameColumn('KODE_PERTEMUAN', 'PERTEMUAN');
        });
    }
};