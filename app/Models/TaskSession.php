<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TaskSession extends Model
{
    public $timestamps = false;

    protected $fillable = ['task_id', 'user_id', 'start_time', 'end_time', 'duration', 'started_at', 'ended_at', 'duration_seconds'];
    protected $casts = ['start_time' => 'datetime', 'end_time' => 'datetime'];

    // Aliases so controller code using started_at/ended_at/duration_seconds still works
    public function getStartedAtAttribute() { return $this->start_time; }
    public function setStartedAtAttribute($v) { $this->start_time = $v; }
    public function getEndedAtAttribute() { return $this->end_time; }
    public function setEndedAtAttribute($v) { $this->end_time = $v; }
    public function getDurationSecondsAttribute() { return $this->duration; }
    public function setDurationSecondsAttribute($v) { $this->duration = $v; }

    public function task() { return $this->belongsTo(Task::class); }
    public function user() { return $this->belongsTo(User::class); }
}
