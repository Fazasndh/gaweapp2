<?php

namespace App\Http\Controllers;

use App\Models\Job;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log; 

class JobController extends Controller
{
    // Tampil SEMUA Lowongan (Untuk Seeker) 
    public function index(Request $request)
    {
        try {
            // 1. Tarik SEMUA lowongan
            $jobs = Job::with('user:id,name')->latest()->get(); 

            // 2. Ambil ID user yang sedang login
            $userId = $request->user()?->id;

            if ($userId) {
                // 3. Tarik daftar ID pekerjaan 
                // Hasilnya berupa array angka, contoh: [1, 5, 12]
                $savedJobIds = \App\Models\SavedJob::where('user_id', $userId)
                                                   ->pluck('job_id')
                                                   ->toArray();

                $jobs->map(function ($job) use ($savedJobIds) {
                    $job->is_saved = in_array($job->id, $savedJobIds);
                    return $job;
                });
            } else {
                $jobs->map(function ($job) {
                    $job->is_saved = false;
                    return $job;
                });
            }

            return response()->json([
                'status' => 'success',
                'data' => $jobs
            ], 200);

        } catch (\Exception $e) {
            Log::error("Index Jobs Error: " . $e->getMessage());
            return response()->json(['message' => 'Server Error', 'error' => $e->getMessage()], 500);
        }
    }

    // Tampil Lowongan Khusus Perusahaan Ini Saja (Untuk HRD)
    public function myCompanyJobs(Request $request)
    {
        try {
            $jobs = Job::where('user_id', $request->user()->id)->latest()->get();
            return response()->json([
                'status' => 'success',
                'data' => $jobs 
            ], 200);
        } catch (\Exception $e) {
            Log::error("My Jobs Error: " . $e->getMessage());
            return response()->json(['message' => 'Server Error', 'error' => $e->getMessage()], 500);
        }
    }

    // Tambah Lowongan
    public function store(Request $request)
    {
        if ($request->user()->role !== 'company') {
            return response()->json(['message' => 'Access Denied: Only company can post jobs'], 403);
        }

        // Validasi
        $validated = $request->validate([
            'title' => 'required|string',
            'location' => 'required|string',
            'description' => 'required|string',
            'job_type' => 'required|string'
        ]);

        try {
            $job = Job::create([
                'user_id' => $request->user()->id,
                'company_name' => $request->user()->name,
                'title' => $validated['title'],
                'location' => $validated['location'],
                'description' => $validated['description'],
                'salary_range' => $request->salary_range ?? null,
                'job_type' => $validated['job_type'],
            ]);

            return response()->json([
                'message' => 'Job posted successfully',
                'data' => $job
            ], 201);

        } catch (\Exception $e) {
            Log::error("Store Job Gagal: " . $e->getMessage());
            return response()->json([
                'message' => 'Database Error saat menyimpan lowongan',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Hapus
    public function destroy(Request $request, $id)
    {
        try {
            $job = Job::find($id);

            if (!$job) {
                return response()->json(['message' => 'Job not found'], 404);
            }
            if ($job->user_id !== $request->user()->id) {
                return response()->json(['message' => 'Unauthorized action'], 403);
            }

            $job->delete();
            return response()->json(['message' => 'Job deleted successfully'], 200);

        } catch (\Exception $e) {
            Log::error("Destroy Job Error: " . $e->getMessage());
            return response()->json(['message' => 'Server Error', 'error' => $e->getMessage()], 500);
        }
    }

    // Edit
    public function update(Request $request, $id)
    {
        try {
            $job = Job::find($id);

            if (!$job) {
                return response()->json(['message' => 'Job not found'], 404);
            }
            if ($job->user_id !== $request->user()->id) {
                return response()->json(['message' => 'Unauthorized action'], 403);
            }

            $request->validate([
                'title' => 'sometimes|required|string',
                'location' => 'sometimes|required|string',
                'description' => 'sometimes|required|string',
                'job_type' => 'sometimes|required|string'
            ]);

            $job->update($request->only(['title', 'location', 'description', 'salary_range', 'job_type']));

            return response()->json([
                'message' => 'Job updated successfully',
                'data' => $job
            ], 200);

        } catch (\Exception $e) {
            Log::error("Update Job Error: " . $e->getMessage());
            return response()->json(['message' => 'Server Error', 'error' => $e->getMessage()], 500);
        }
    }
}