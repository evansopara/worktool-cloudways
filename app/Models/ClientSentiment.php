<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClientSentiment extends Model
{
    protected $fillable = ['project_id', 'client_id', 'sentiment', 'feedback', 'recorded_by', 'recorded_at'];
    protected $casts = ['recorded_at' => 'datetime'];

    public function project() { return $this->belongsTo(Project::class); }
    public function client() { return $this->belongsTo(User::class, 'client_id'); }
    public function recorder() { return $this->belongsTo(User::class, 'recorded_by'); }
}
