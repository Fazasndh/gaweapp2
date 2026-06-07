<?php

namespace App\Http\Controllers;

use App\Models\Application;
use Illuminate\Http\Request;

class ApplicationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'company') {
            // HRD hanya melihat lamaran yang masuk ke lowongan miliknya sendiri
            $applications = Application::with(['user', 'job'])
                ->whereHas('job', function ($query) use ($user) {
                    $query->where('user_id', $user->id);
                })->get();
        } else {
            // Pelamar hanya melihat riwayat lamarannya sendiri
            $applications = Application::with('job')
                ->where('user_id', $user->id)
                ->get();
        }

        return response()->json([
            'message' => 'Success fetch applications',
            'data' => $applications
        ], 200);
    }
    public function store(Request $request)
    {
        // 1. Validasi Akses: Hanya pencari kerja (seeker) yang bisa melamar
        if ($request->user()->role !== 'seeker') {
            return response()->json(['message' => 'Access Denied: Only seekers can apply'], 403);
        }

        // 2. Validasi Input: Pastikan ID lowongan valid dan ada di database
        $request->validate([
            'job_id' => 'required|exists:jobs,id'
        ]);

        $userId = $request->user()->id;
        $jobId = $request->job_id;

        // 3. Proteksi Anti-Spam: Cek apakah user ini sudah melamar lowongan ini sebelumnya
        $existingApplication = Application::where('user_id', $userId)
            ->where('job_id', $jobId)
            ->first();

        if ($existingApplication) {
            return response()->json([
                'message' => 'You have already applied for this job.'
            ], 409); // 409 Conflict
        }

        // 4. Eksekusi: Simpan data lamaran
        $application = Application::create([
            'job_id' => $jobId,
            'user_id' => $userId,
            'status' => 'pending'
        ]);

        return response()->json([
            'message' => 'Application submitted successfully',
            'data' => $application
        ], 201);
    }
    public function update(Request $request, $id)
    {
        // 1. Validasi Lapis Pertama: Hanya HRD yang boleh mengubah status
        if ($request->user()->role !== 'company') {
            return response()->json(['message' => 'Access Denied: Only companies can update status'], 403);
        }

        // 2. Validasi Input: Pastikan status yang dikirim sesuai aturan sistem
        $request->validate([
            'status' => 'required|in:pending,reviewed,accepted,rejected'
        ]);

        $application = Application::find($id);
        if (!$application) {
            return response()->json(['message' => 'Application not found'], 404);
        }

        // 3. Validasi Lapis Kedua (Krusial): Pastikan lamaran ini BENAR masuk ke lowongan milik HRD yang sedang login
        $job = \App\Models\Job::find($application->job_id);
        if ($job->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized: You do not own this job posting'], 403);
        }

        // 4. Eksekusi: Ubah status
        $application->update([
            'status' => $request->status
        ]);

        return response()->json([
            'message' => 'Application status updated successfully',
            'data' => $application
        ], 200);
    }
}