<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Job;

class JobApplication extends Model
{
    use HasFactory;
    
    protected $table = 'applications'; 

    protected $fillable = [
        'job_id',
        'user_id',
        'resume_url',
        'status'
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    } 
    public function job() 
    {
        return $this->belongsTo(Job::class, 'job_id');
    }
}