<?php

namespace App\Http\Controllers;

use App\Models\Resume;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ResumeController extends Controller
{
    public function store(Request $request)
    {
        // 1. Validasi Mutlak: Hanya Pencari Kerja yang boleh bikin Resume
        if ($request->user()->role !== 'seeker') {
            return response()->json(['message' => 'Access Denied: Only seekers can create resume'], 403);
        }

        // 2. Validasi Input (File wajib PDF dan maksimal 2MB)
        $request->validate([
            'job_title_qualification' => 'required|string',
            'location' => 'required|string',
            'file' => 'nullable|mimes:pdf|max:2048' 
        ]);

        // 3. Logika Penyimpanan File
        $filePath = null;
        if ($request->hasFile('file')) {
            // Simpan file ke folder storage/app/public/resumes
            $filePath = $request->file('file')->store('resumes', 'public');
        }

        // 4. UpdateOrCreate: Mencegah 1 user punya banyak resume numpuk
        $resume = Resume::updateOrCreate(
            ['user_id' => $request->user()->id],
            [
                'job_title_qualification' => $request->job_title_qualification,
                'location' => $request->location,
                'file_path' => $filePath,
            ]
        );

        return response()->json([
            'message' => 'Resume updated successfully',
            'data' => $resume
        ], 200);
    }
}