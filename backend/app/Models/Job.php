<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Job extends Model
{
    use HasFactory;
    public function user()
    {
        return $this->belongsTo(User::class);
        return $this->hasMany(SavedJob::class);
    }
    public function job() {
    return $this->belongsTo(Job::class);
}
    protected $fillable = [
    'user_id','company_name', 'title', 'location', 'description', 'salary_range', 'job_type'
];
}