<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SeekerProfile extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'photo_url',
        'phone',
        'skills',
        'resume_url',
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
