<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {

            $table->unsignedBigInteger('ID_ROLE')
                ->nullable()
                ->after('role');

            $table->foreign('ID_ROLE')
                ->references('ID_ROLE')
                ->on('roles');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {

            $table->dropForeign(['ID_ROLE']);

            $table->dropColumn('ID_ROLE');
        });
    }
};