<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\JobController;
use App\Http\Controllers\ResumeController;
use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\SeekerProfileController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/jobs', [JobController::class, 'index']); 

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/jobs', [JobController::class, 'store']); 
    Route::post('/resumes', [ResumeController::class, 'store']);
    Route::post('/applications', [ApplicationController::class, 'store']);
    Route::get('/applications', [ApplicationController::class, 'index']);
    Route::put('/applications/{id}', [ApplicationController::class, 'update']);
    Route::get('/my-jobs', [JobController::class, 'myCompanyJobs']);
    Route::delete('/jobs/{id}', [JobController::class, 'destroy']);
    Route::put('/jobs/{id}', [JobController::class, 'update']);
    Route::get('/profile', [SeekerProfileController::class, 'getProfile']);
    Route::post('/profile/update', [SeekerProfileController::class, 'updateProfile']);
});