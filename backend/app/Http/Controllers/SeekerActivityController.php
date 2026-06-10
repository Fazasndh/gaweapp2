<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SavedJob;
use App\Models\JobApplication; 
use Illuminate\Support\Facades\Log;

class SeekerActivityController extends Controller
{
    // LOGIKA 1: SIMPAN ATAU HAPUS BOOKMARK (TOGGLE)
    public function toggleSave(Request $request, $job_id)
    {
        try {
            $userId = $request->user()->id;

            // Cek apakah data sudah ada
            $existingSave = SavedJob::where('user_id', $userId)
                                    ->where('job_id', $job_id)
                                    ->first();

            if ($existingSave) {
                $existingSave->delete();
                return response()->json([
                    'statusCode' => 200,
                    'status' => 'unsaved',
                    'message' => 'Lowongan dihapus dari daftar simpanan.'
                ], 200);
            } else {
                SavedJob::create([
                    'user_id' => $userId,
                    'job_id' => $job_id
                ]);
                return response()->json([
                    'statusCode' => 201,
                    'status' => 'saved',
                    'message' => 'Lowongan berhasil disimpan!'
                ], 201);
            }
        } catch (\Exception $e) {
            Log::error("Toggle Save Error: " . $e->getMessage());
            return response()->json(['statusCode' => 500, 'message' => 'Terjadi kesalahan server.'], 500);
        }
    }

    // LOGIKA 2: KALKULATOR DASHBOARD
    public function getDashboardStats(Request $request)
    {
        try {
            $userId = $request->user()->id;
            $appliedCount = JobApplication::where('user_id', $userId)->count();
            
            // Hitung total dari tabel 'saved_jobs'
            $savedCount = SavedJob::where('user_id', $userId)->count();

            return response()->json([
                'statusCode' => 200,
                'data' => [
                    'total_applied' => $appliedCount,
                    'total_saved' => $savedCount
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error("Dashboard Stats Error: " . $e->getMessage());
            return response()->json(['statusCode' => 500, 'message' => 'Gagal memuat statistik.'], 500);
        }
    }
    public function getAppliedJobs(Request $request)
    {
        $userId = $request->user()->id;
        $applied = \App\Models\JobApplication::where('user_id', $userId)
            ->with('job') 
            ->latest()
            ->get();

        return response()->json(['status' => 'success', 'data' => $applied], 200);
    }
    public function getSavedJobs(Request $request)
    {
        $userId = $request->user()->id;
        $saved = \App\Models\SavedJob::where('user_id', $userId)
            ->with('job')
            ->latest()
            ->get();

        return response()->json(['status' => 'success', 'data' => $saved], 200);
    }
}