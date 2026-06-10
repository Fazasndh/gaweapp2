<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::create('job_applications', function (Blueprint $table) {
        $table->id();
        $table->foreignId('job_id')->constrained()->cascadeOnDelete();
        $table->foreignId('user_id')->constrained()->cascadeOnDelete(); // ID Pelamar
        $table->string('resume_url'); // Snapshot resume saat apply
        $table->enum('status', ['pending', 'reviewed', 'accepted', 'rejected'])->default('pending');
        $table->timestamps();
        $table->unique(['job_id', 'user_id']); 
    });
}
};
