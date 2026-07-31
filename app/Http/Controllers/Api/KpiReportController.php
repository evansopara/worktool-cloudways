<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\TaskSession;
use App\Models\User;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Http\Request;

class KpiReportController extends Controller
{
    private const ALLOWED_ROLES = ['operations_manager', 'team_lead'];

    private const EMPLOYEE_ROLES = [
        'operations_manager', 'team_lead', 'project_manager',
        'staff', 'intern', 'customer_support_officer',
    ];

    /**
     * The department/team categories the org actually operates with. Always
     * offered in the Department filter, even before anyone is tagged with them.
     */
    private const CANONICAL_DEPARTMENTS = [
        'Staff', 'Customer Support Officer', 'Automation', 'Design',
        'Media Buying', 'Development', 'Community Manager',
        'Operations Manager', 'Technical Support',
    ];

    /**
     * Known spellings/variants (department or specialization values, and role
     * slugs) seen in the data, normalized to their canonical display label.
     */
    private const DEPARTMENT_ALIASES = [
        'developer' => 'Development',
        'development' => 'Development',
        'media buyer' => 'Media Buying',
        'media buying' => 'Media Buying',
        'community manager' => 'Community Manager',
        'technical_support' => 'Technical Support',
        'technical support' => 'Technical Support',
        'automation' => 'Automation',
        'design' => 'Design',
        'staff' => 'Staff',
        'customer_support_officer' => 'Customer Support Officer',
        'customer support officer' => 'Customer Support Officer',
        'operations_manager' => 'Operations Manager',
        'operations manager' => 'Operations Manager',
        'project_manager' => 'Project Manager',
        'project manager' => 'Project Manager',
        'team_lead' => 'Team Lead',
        'team lead' => 'Team Lead',
        'intern' => 'Intern',
    ];

    private function assertAllowed(Request $request): void
    {
        if (!in_array($request->user()->role, self::ALLOWED_ROLES)) {
            abort(403, 'You are not authorized to view KPI reports.');
        }
    }

    /**
     * A user's department field is often blank in practice, with the real
     * team info living in `specialization` or implied by `role` instead.
     * Fall back through all three so every employee lands in some bucket.
     */
    private function effectiveDepartment(User $user): string
    {
        $raw = trim((string) ($user->department ?: $user->specialization));
        if ($raw !== '') {
            return self::DEPARTMENT_ALIASES[strtolower($raw)] ?? ucwords($raw);
        }

        return self::DEPARTMENT_ALIASES[$user->role] ?? ucwords(str_replace('_', ' ', $user->role));
    }

    public function departments(Request $request)
    {
        $this->assertAllowed($request);

        $users = User::whereIn('role', self::EMPLOYEE_ROLES)->get(['role', 'department', 'specialization']);
        $derived = $users->map(fn ($u) => $this->effectiveDepartment($u));

        $all = collect(self::CANONICAL_DEPARTMENTS)->merge($derived)->unique()->sort()->values();

        return response()->json($all);
    }

    public function productivity(Request $request)
    {
        $this->assertAllowed($request);

        $department = $request->query('department');
        $employeeId = $request->query('employee_id');
        [$from, $to] = $this->resolveRange(
            $request->query('range', 'last_month'),
            $request->query('from'),
            $request->query('to'),
        );

        $employeesAll = User::whereIn('role', self::EMPLOYEE_ROLES)
            ->orderBy('first_name')
            ->get(['id', 'first_name', 'last_name', 'role', 'department', 'specialization'])
            ->map(function (User $u) {
                $u->setAttribute('effective_department', $this->effectiveDepartment($u));

                return $u;
            });

        $employees = $department
            ? $employeesAll->filter(fn (User $u) => $u->effective_department === $department)->values()
            : $employeesAll->values();

        $response = [
            'employees' => $employees,
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
        ];

        if ($employeeId) {
            $employee = User::findOrFail($employeeId);

            $sessions = TaskSession::where('user_id', $employeeId)
                ->whereBetween('started_at', [$from, $to->copy()->endOfDay()])
                ->with('task:id,title,working_hours,working_minutes')
                ->get();

            $sessionsByDate = $sessions->groupBy(fn ($s) => Carbon::parse($s->started_at)->toDateString());

            $chart = [];
            $dailyDetails = [];
            foreach (CarbonPeriod::create($from, $to) as $day) {
                $dateStr = $day->toDateString();
                $daySessions = $sessionsByDate->get($dateStr, collect());
                $totalSeconds = (int) $daySessions->sum('duration_seconds');
                $taskTitles = $daySessions->pluck('task.title')->filter()->unique()->values();

                $status = $totalSeconds >= 4 * 3600 ? 'good' : ($totalSeconds >= 2 * 3600 ? 'fair' : 'poor');

                $dailyDetails[] = [
                    'date' => $dateStr,
                    'total_span_seconds' => $totalSeconds,
                    'tasks' => $taskTitles,
                    'status' => $status,
                ];
                $chart[] = ['date' => $dateStr, 'hours' => round($totalSeconds / 3600, 2)];
            }

            $taskIds = $sessions->pluck('task_id')->unique();
            $tasks = Task::whereIn('id', $taskIds)->get(['id', 'title', 'working_hours', 'working_minutes']);

            $taskBreakdown = [];
            $totalEstMinutes = 0;
            $totalActMinutes = 0;
            foreach ($tasks as $task) {
                $estMinutes = ((int) ($task->working_hours ?? 0)) * 60 + (int) ($task->working_minutes ?? 0);
                $actSeconds = (int) $sessions->where('task_id', $task->id)->sum('duration_seconds');
                $actMinutes = (int) round($actSeconds / 60);
                $percentage = $estMinutes > 0 ? round(($actMinutes / $estMinutes) * 100) : 0;

                $taskBreakdown[] = [
                    'title' => $task->title,
                    'estimated_minutes' => $estMinutes,
                    'actual_minutes' => $actMinutes,
                    'percentage' => $percentage,
                ];
                $totalEstMinutes += $estMinutes;
                $totalActMinutes += $actMinutes;
            }

            $activeDays = collect($dailyDetails)->filter(fn ($d) => $d['total_span_seconds'] > 0)->count();
            $totalHours = collect($dailyDetails)->sum('total_span_seconds') / 3600;
            $avgDailyHours = $activeDays > 0 ? $totalHours / $activeDays : 0;
            $productivityScore = $totalEstMinutes > 0 ? (int) round(($totalActMinutes / $totalEstMinutes) * 100) : 0;

            $tasksCompleted = Task::where('assignee_id', $employeeId)
                ->where('status', 'completed')
                ->whereBetween('completed_at', [$from, $to->copy()->endOfDay()])
                ->count();
            $tasksInProgress = Task::where('assignee_id', $employeeId)
                ->where('status', 'in_progress')
                ->count();

            // Most recent day first, matching the table's expected reading order.
            $response['daily_details'] = array_reverse($dailyDetails);
            $response['chart'] = $chart;
            $response['task_breakdown'] = $taskBreakdown;
            $response['overview'] = [
                'total_working_days' => count($dailyDetails),
                'active_days' => $activeDays,
                'average_daily_hours' => round($avgDailyHours, 2),
                'productivity_score' => $productivityScore,
                'unique_task_count' => count($taskBreakdown),
            ];
            $response['staff_summary'] = [
                'id' => $employee->id,
                'name' => trim($employee->first_name.' '.$employee->last_name),
                'role' => $employee->role,
                'department' => $this->effectiveDepartment($employee),
                'total_hours' => round($totalHours, 2),
                'active_days' => $activeDays,
                'tasks_completed' => $tasksCompleted,
                'tasks_in_progress' => $tasksInProgress,
                'productivity_score' => $productivityScore,
            ];
        }

        return response()->json($response);
    }

    /**
     * @return array{0: Carbon, 1: Carbon}
     */
    private function resolveRange(string $range, ?string $from, ?string $to): array
    {
        $now = Carbon::now();

        return match ($range) {
            'this_month' => [$now->copy()->startOfMonth(), $now->copy()->endOfMonth()],
            'last_7_days' => [$now->copy()->subDays(6)->startOfDay(), $now->copy()->endOfDay()],
            'last_30_days' => [$now->copy()->subDays(29)->startOfDay(), $now->copy()->endOfDay()],
            'custom' => [
                $from ? Carbon::parse($from)->startOfDay() : $now->copy()->startOfMonth(),
                $to ? Carbon::parse($to)->endOfDay() : $now->copy()->endOfDay(),
            ],
            default => [$now->copy()->subMonthNoOverflow()->startOfMonth(), $now->copy()->subMonthNoOverflow()->endOfMonth()],
        };
    }
}
