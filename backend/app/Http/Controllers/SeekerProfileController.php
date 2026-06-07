<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SeekerProfile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class SeekerProfileController extends Controller 
{
    // 1. FUNGSI TAMPIL PROFIL (JANGAN DIHILANGKAN TRY-CATCH-NYA)
    public function getProfile(Request $request)
    {
        try {
            $user = $request->user();
            $profile = SeekerProfile::firstOrCreate(['user_id' => $user->id]);
            
            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'phone' => $profile->phone,
                    'skills' => $profile->skills,
                    'photo_url' => $profile->photo_url,
                    'resume_url' => $profile->resume_url,
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error("Get Profile Error: " . $e->getMessage());
            return response()->json(['message' => 'Server Error', 'error' => $e->getMessage()], 500);
        }
    }

    // 2. FUNGSI UPLOAD (VALIDASI DI LUAR, PROSES DI DALAM TRY)
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        // Validasi di luar agar mengembalikan 422 jika format/ukuran salah
        $request->validate([
            'phone' => 'nullable|string|max:20',
            'skills' => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', 
            'resume' => 'nullable|mimes:pdf,doc,docx|max:5120',      
        ]);

        try {
            $profile = SeekerProfile::firstOrCreate(['user_id' => $user->id]);

            if ($request->hasFile('photo')) {
                if ($profile->photo_url) {
                    $oldPath = str_replace(url('storage') . '/', '', $profile->photo_url);
                    Storage::disk('public')->delete($oldPath);
                }
                $photoPath = $request->file('photo')->store('seeker_photos', 'public');
                $profile->photo_url = url('storage/' . $photoPath);
            }

            if ($request->hasFile('resume')) {
                if ($profile->resume_url) {
                    $oldPath = str_replace(url('storage') . '/', '', $profile->resume_url);
                    Storage::disk('public')->delete($oldPath);
                }
                $resumePath = $request->file('resume')->store('seeker_resumes', 'public');
                $profile->resume_url = url('storage/' . $resumePath);
            }

            $profile->phone = $request->phone ?? $profile->phone;
            $profile->skills = $request->skills ?? $profile->skills;
            $profile->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Profil dan berkas berhasil diperbarui',
                'data' => $profile
            ], 200);

        } catch (\Exception $e) {
            Log::error("Update Profile Error: " . $e->getMessage());
            return response()->json(['message' => 'Gagal memperbarui profil', 'error' => $e->getMessage()], 500);
        }
    }
}