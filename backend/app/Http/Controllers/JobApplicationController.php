<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\JobApplication;
use App\Models\SeekerProfile;
use App\Models\Notification; 
use Illuminate\Support\Facades\Log;

class JobApplicationController extends Controller
{
    // 1. Fungsi Melamar Kerja (Seeker)
    public function applyJob(Request $request, $job_id)
    {
        try {
            $user = $request->user();

            $profile = SeekerProfile::where('user_id', $user->id)->first();
            
            if (!$profile || empty($profile->resume_url)) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Tindakan ditolak. Anda wajib melengkapi profil dan mengunggah Resume/CV terlebih dahulu.'
                ], 400);
            }

            $alreadyApplied = JobApplication::where('user_id', $user->id)
                                            ->where('job_id', $job_id)
                                            ->exists();
            
            if ($alreadyApplied) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda sudah melamar untuk posisi ini. Menunggu tinjauan perusahaan.'
                ], 409);
            }

            $application = JobApplication::create([
                'job_id' => $job_id,
                'user_id' => $user->id,
                'resume_url' => $profile->resume_url, 
                'status' => 'pending'
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Lamaran berhasil dikirim!',
                'data' => $application
            ], 201);

        } catch (\Exception $e) {
            Log::error("Job Apply Error: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengirim lamaran karena gangguan server.',
            ], 500);
        }
    }

    // 2. Fungsi Mengambil Daftar Pelamar (Company)
    public function getCompanyApplicants(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'company') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $applicants = JobApplication::with(['user.seekerProfile', 'job'])
        ->whereHas('job', function ($query) use ($user) {
            $query->where('user_id', $user->id);
            })
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $applicants
        ], 200);
    }

    // 3. Fungsi Mengupdate Status & Trigger Notifikasi (Company)
    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'company') {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak.'], 403);
        }

        $request->validate([
            'status' => 'required|in:reviewed,interview,accepted,rejected'
        ]);

        $application = JobApplication::with('job')
            ->where('id', $id)
            ->whereHas('job', function ($query) use ($user) {
                $query->where('user_id', $user->id);
            })->first();

        if (!$application) {
            return response()->json(['status' => 'error', 'message' => 'Data pelamar tidak ditemukan.'], 404);
        }

        $newStatus = $request->status;
        $application->update(['status' => $newStatus]);

        // Trigger Otomatis
        $companyName = $user->name;
        $jobTitle = $application->job->title;
        $message = "";

        switch ($newStatus) {
            case 'reviewed': $message = "Lamaran Anda untuk posisi $jobTitle di $companyName sedang ditinjau."; break;
            case 'interview': $message = "Selamat! Anda diundang sesi interview untuk posisi $jobTitle di $companyName."; break;
            case 'accepted': $message = "Luar biasa! Anda resmi DITERIMA di $companyName untuk posisi $jobTitle."; break;
            case 'rejected': $message = "Terima kasih telah melamar di $companyName ($jobTitle). Profil Anda belum cocok."; break;
        }

        Notification::create([
            'user_id' => $application->user_id,
            'title' => "Status Lamaran Diperbarui",
            'message' => $message,
            'is_read' => false
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Status berhasil diperbarui dan pelamar telah dinotifikasi.'
        ], 200);
    }
}