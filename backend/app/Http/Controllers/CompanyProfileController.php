<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CompanyProfile;

class CompanyProfileController extends Controller
{
   public function show(Request $request) {
    return response()->json($request->user()->companyProfile ?? []);
}

public function update(Request $request) {
    $data = $request->validate([
        'company_name' => 'required|string',
        'industry' => 'nullable|string',
        'location' => 'nullable|string',
        'description' => 'nullable|string',
        'website' => 'nullable|url',
    ]);

    $profile = \App\Models\CompanyProfile::updateOrCreate(
        ['user_id' => $request->user()->id],
        $data
    );

    return response()->json(['status' => 'success', 'data' => $profile]);
}
}
