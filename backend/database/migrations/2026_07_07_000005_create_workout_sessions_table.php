<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('program_id')->nullable()->constrained()->nullOnDelete();
            $table->date('scheduled_date');
            $table->time('scheduled_time')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->string('status')->default('planned');
            $table->timestamps();

            $table->index('user_id');
            $table->index('program_id');
            $table->index('scheduled_date');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_sessions');
    }
};
