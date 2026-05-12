<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dosen', function (Blueprint $table) {

            $table->string('NIP_DOSEN')->primary();

            $table->string('DOSEN_NAMA');

            $table->unsignedBigInteger('ID_USER')->nullable();

            $table->timestamps();

            $table->foreign('ID_USER')
                ->references('id')
                ->on('users')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dosen');
    }
};