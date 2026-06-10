<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\JobController;
use App\Http\Controllers\ResumeController;
use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\SeekerProfileController;
use App\Http\Controllers\JobApplicationController;
use App\Http\Controllers\CompanyProfileController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/jobs', [JobController::class, 'index']); 

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
    Route::post('/jobs/{job_id}/apply', [JobApplicationController::class, 'applyJob']);
    Route::post('/jobs/{job_id}/save', [App\Http\Controllers\SeekerActivityController::class, 'toggleSave']);
    Route::get('/seeker/dashboard/stats', [App\Http\Controllers\SeekerActivityController::class, 'getDashboardStats']);
    Route::get('/seeker/applied-jobs', [App\Http\Controllers\SeekerActivityController::class, 'getAppliedJobs']);
    Route::get('/seeker/saved-jobs', [App\Http\Controllers\SeekerActivityController::class, 'getSavedJobs']);
    Route::get('/seeker/notifications', [App\Http\Controllers\NotificationController::class, 'index']);
    Route::put('/seeker/notifications/{id}/read', [App\Http\Controllers\NotificationController::class, 'markAsRead']);
    Route::get('/company/applicants', [App\Http\Controllers\JobApplicationController::class, 'getCompanyApplicants']);
    Route::put('/company/applicants/{id}/status', [App\Http\Controllers\JobApplicationController::class, 'updateStatus']);
    Route::get('/company/profile', [CompanyProfileController::class, 'show']);
    Route::post('/company/profile/update', [CompanyProfileController::class, 'update']);
});