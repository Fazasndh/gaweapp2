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
        Schema::create('applications', function (Blueprint $table) {
            $table->id();
            // Relasi ke Lowongan Kerja
            $table->foreignId('job_id')->constrained()->onDelete('cascade');
            // Relasi ke Pelamar (Seeker)
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            // Status lamaran untuk diupdate oleh HRD nantinya
            $table->enum('status', ['pending', 'reviewed', 'accepted', 'rejected'])->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('applications');
    }
};
