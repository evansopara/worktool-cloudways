<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $fillable = ['user_id', 'type', 'content', 'reference_id', 'reference_type', 'read'];
    protected $casts = ['read' => 'boolean'];

    public function user() { return $this->belongsTo(User::class); }
}
