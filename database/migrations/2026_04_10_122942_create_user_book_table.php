<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('user_book', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('book_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->boolean('is_reading')->default(false);
            $table->boolean('is_favorite')->default(false);
            $table->boolean('is_completed')->default(false);

            $table->timestamp('started_reading_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('favorited_at')->nullable();

            $table->tinyInteger('rating')->nullable(); // 1–5

            $table->timestamps();

            $table->unique(['user_id', 'book_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_books');
    }
};
