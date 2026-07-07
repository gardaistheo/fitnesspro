<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('programs', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->json('muscles')->nullable();
            $table->string('difficulty');
            $table->unsignedInteger('duration')->nullable()->comment('duration in minutes');
            $table->text('description')->nullable();
            $table->timestamps();

            $table->index('difficulty');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('programs');
    }
};
