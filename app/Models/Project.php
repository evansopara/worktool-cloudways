<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $fillable = [
        'name', 'description', 'category', 'status',
        'client_id', 'manager_id', 'created_by', 'progress', 'start_date', 'end_date',
    ];

    protected $casts = ['start_date' => 'datetime', 'end_date' => 'datetime'];

    public function client() { return $this->belongsTo(User::class, 'client_id'); }
    public function manager() { return $this->belongsTo(User::class, 'manager_id'); }
    public function creator() { return $this->belongsTo(User::class, 'created_by'); }
    public function tasks() { return $this->hasMany(Task::class); }
    public function members() { return $this->hasMany(ProjectMember::class); }
    public function messages() { return $this->hasMany(ProjectMessage::class); }
    public function plans() { return $this->hasMany(ProjectPlan::class); }
    public function resources() { return $this->hasMany(Resource::class); }
}
