<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('program_exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->foreignId('exercise_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('sets');
            $table->unsignedInteger('reps');
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();

            $table->index(['program_id', 'order']);
            $table->index('exercise_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('program_exercises');
    }
};
