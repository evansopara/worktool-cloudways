<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LeaveApplication;
use App\Models\Booking;
use App\Models\TechnicalSupportRequest;
use App\Models\Complaint;
use App\Models\StaffComplaint;
use App\Models\StaffQuery;
use App\Models\Sop;
use App\Models\SopSegment;
use App\Models\IssueReport;
use App\Models\ReviewLink;
use App\Models\Note;
use Illuminate\Http\Request;

class SimpleController extends Controller
{
    // ==================== LEAVE ====================
    public function leaveIndex(Request $request)
    {
        $user = $request->user();
        $query = LeaveApplication::with(['user', 'reviewer']);

        if (in_array($user->role, ['staff', 'intern', 'project_manager'])) {
            $query->where('user_id', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function leaveStore(Request $request)
    {
        $data = $request->validate([
            'leave_type' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'reason' => 'nullable|string',
        ]);
        $data['user_id'] = $request->user()->id;
        $data['status'] = 'pending';

        $leave = LeaveApplication::create($data);
        return response()->json($leave->load('user'), 201);
    }

    public function leaveDecide(Request $request, LeaveApplication $leave)
    {
        $this->authorizeRole($request, ['operations_manager', 'team_lead']);
        $data = $request->validate([
            'status' => 'required|in:approved,rejected',
            'review_comment' => 'nullable|string',
        ]);
        $data['reviewed_by'] = $request->user()->id;
        $data['reviewed_at'] = now();

        $leave->update($data);
        return response()->json($leave->load(['user', 'reviewer']));
    }

    // ==================== BOOKINGS ====================
    public function bookingIndex(Request $request)
    {
        return response()->json(
            Booking::with('scheduler')->orderBy('start_time', 'asc')->get()
        );
    }

    public function bookingStore(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after:start_time',
            'location' => 'nullable|string',
            'participants' => 'nullable|array',
            'type' => 'nullable|string',
        ]);
        $data['scheduled_by'] = $request->user()->id;

        $booking = Booking::create($data);
        return response()->json($booking->load('scheduler'), 201);
    }

    public function bookingUpdate(Request $request, Booking $booking)
    {
        $booking->update($request->validate([
            'title' => 'sometimes|string',
            'description' => 'nullable|string',
            'start_time' => 'sometimes|date',
            'end_time' => 'sometimes|date',
            'location' => 'nullable|string',
            'participants' => 'nullable|array',
        ]));
        return response()->json($booking);
    }

    public function bookingDestroy(Booking $booking)
    {
        $booking->delete();
        return response()->json(['message' => 'Booking deleted.']);
    }

    // ==================== TECHNICAL SUPPORT ====================
    public function supportIndex(Request $request)
    {
        $user = $request->user();
        $query = TechnicalSupportRequest::with(['requester', 'assignedTo']);

        if (in_array($user->role, ['staff', 'intern'])) {
            $query->where('requester_id', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function supportStore(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'task_id' => 'nullable|integer|exists:tasks,id',
            'priority' => 'nullable|string',
        ]);
        $data['requester_id'] = $request->user()->id;
        $data['status'] = 'open';

        $req = TechnicalSupportRequest::create($data);
        return response()->json($req->load('requester'), 201);
    }

    public function supportUpdate(Request $request, TechnicalSupportRequest $support)
    {
        $support->update($request->validate([
            'status' => 'sometimes|string',
            'assigned_to_id' => 'nullable|integer|exists:users,id',
            'resolution' => 'nullable|string',
            'resolved_at' => 'nullable|date',
        ]));
        return response()->json($support->load(['requester', 'assignedTo']));
    }

    // ==================== COMPLAINTS ====================
    public function complaintIndex(Request $request)
    {
        $user = $request->user();
        $query = Complaint::query();

        if ($user->role === 'client') {
            $query->where('submitter_id', $user->id);
        } elseif (!in_array($user->role, ['operations_manager', 'team_lead', 'customer_support_officer'])) {
            $query->where('submitter_id', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function complaintStore(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string',
            'email' => 'required|email',
            'product_manager_name' => 'nullable|string',
            'developer_name' => 'nullable|string',
            'technical_manager_name' => 'nullable|string',
            'valuable_things' => 'nullable|array',
            'detailed_explanation' => 'required|string',
            'screenshot_url' => 'nullable|string',
        ]);
        $data['submitter_id'] = $request->user()->id;
        $data['status'] = 'open';

        $complaint = Complaint::create($data);
        return response()->json($complaint, 201);
    }

    public function complaintUpdate(Request $request, Complaint $complaint)
    {
        $this->authorizeRole($request, ['operations_manager', 'team_lead', 'customer_support_officer']);
        $complaint->update($request->validate([
            'status' => 'sometimes|string',
            'review_comments' => 'nullable|string',
            'reviewed_by' => 'nullable|integer',
            'reviewed_at' => 'nullable|date',
        ]));
        return response()->json($complaint);
    }

    // ==================== STAFF COMPLAINTS ====================
    public function staffComplaintIndex(Request $request)
    {
        $user = $request->user();
        $query = StaffComplaint::with('submitter');

        if (!in_array($user->role, ['operations_manager', 'team_lead'])) {
            $query->where('submitter_id', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function staffComplaintStore(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string',
            'email' => 'required|email',
            'department' => 'nullable|string',
            'detailed_explanation' => 'required|string',
            'screenshot_url' => 'nullable|string',
        ]);
        $data['submitter_id'] = $request->user()->id;
        $data['status'] = 'open';

        $complaint = StaffComplaint::create($data);
        return response()->json($complaint, 201);
    }

    public function staffComplaintUpdate(Request $request, StaffComplaint $complaint)
    {
        $this->authorizeRole($request, ['operations_manager', 'team_lead']);
        $complaint->update($request->validate([
            'status' => 'sometimes|string',
            'review_comments' => 'nullable|string',
            'reviewed_at' => 'nullable|date',
        ]));
        return response()->json($complaint);
    }

    // ==================== STAFF QUERIES ====================
    public function queryIndex(Request $request)
    {
        $user = $request->user();
        $query = StaffQuery::with(['submitter', 'assignee']);

        if (in_array($user->role, ['staff', 'intern'])) {
            $query->where('submitted_by', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function queryStore(Request $request)
    {
        $data = $request->validate([
            'subject' => 'required|string',
            'message' => 'required|string',
            'assigned_to' => 'nullable|integer|exists:users,id',
        ]);
        $data['submitted_by'] = $request->user()->id;
        $data['status'] = 'open';

        $q = StaffQuery::create($data);
        return response()->json($q->load('submitter'), 201);
    }

    public function queryRespond(Request $request, StaffQuery $staffQuery)
    {
        $staffQuery->update([
            'response' => $request->validate(['response' => 'required|string'])['response'],
            'responded_at' => now(),
            'status' => 'resolved',
        ]);
        return response()->json($staffQuery);
    }

    // ==================== SOPs ====================
    public function sopIndex()
    {
        return response()->json(Sop::with('segments')->orderBy('created_at', 'desc')->get());
    }

    public function sopStore(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'category' => 'nullable|string',
        ]);
        $data['created_by'] = $request->user()->id;
        $data['status'] = 'active';

        $sop = Sop::create($data);
        return response()->json($sop, 201);
    }

    public function sopShow(Sop $sop)
    {
        return response()->json($sop->load(['creator', 'segments']));
    }

    public function sopUpdate(Request $request, Sop $sop)
    {
        $sop->update($request->validate([
            'title' => 'sometimes|string',
            'description' => 'nullable|string',
            'category' => 'nullable|string',
            'status' => 'nullable|string',
        ]));
        return response()->json($sop);
    }

    public function sopDestroy(Sop $sop)
    {
        $sop->delete();
        return response()->json(['message' => 'SOP deleted.']);
    }

    public function sopSegmentStore(Request $request, Sop $sop)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'content' => 'required|string',
            'order_index' => 'nullable|integer',
        ]);
        $data['sop_id'] = $sop->id;

        $segment = SopSegment::create($data);
        return response()->json($segment, 201);
    }

    public function sopSegmentUpdate(Request $request, Sop $sop, SopSegment $segment)
    {
        $segment->update($request->validate([
            'title' => 'sometimes|string',
            'content' => 'sometimes|string',
            'order_index' => 'nullable|integer',
        ]));
        return response()->json($segment);
    }

    public function sopSegmentDestroy(Sop $sop, SopSegment $segment)
    {
        $segment->delete();
        return response()->json(['message' => 'Segment deleted.']);
    }

    // ==================== ISSUE REPORTS ====================
    public function issueIndex(Request $request)
    {
        $user = $request->user();
        $query = IssueReport::with(['reporter', 'project', 'task']);

        if (in_array($user->role, ['staff', 'intern'])) {
            $query->where('reported_by', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function issueStore(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'project_id' => 'nullable|integer|exists:projects,id',
            'task_id' => 'nullable|integer|exists:tasks,id',
            'priority' => 'nullable|string',
            'screenshot_url' => 'nullable|string',
        ]);
        $data['reported_by'] = $request->user()->id;
        $data['status'] = 'open';

        $issue = IssueReport::create($data);
        return response()->json($issue->load('reporter'), 201);
    }

    public function issueUpdate(Request $request, IssueReport $issue)
    {
        $issue->update($request->validate([
            'status' => 'sometimes|string',
            'resolution' => 'nullable|string',
            'resolved_at' => 'nullable|date',
            'priority' => 'nullable|string',
        ]));
        return response()->json($issue);
    }

    // ==================== REVIEW LINKS ====================
    public function reviewLinkIndex(Request $request)
    {
        $user = $request->user();
        $query = ReviewLink::with(['sender', 'assignee']);

        if ($user->role === 'client') {
            $query->where('assigned_to', $user->id);
        } elseif (!in_array($user->role, ['operations_manager', 'team_lead', 'project_manager'])) {
            $query->where('sent_by', $user->id)->orWhere('assigned_to', $user->id);
        }

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    public function reviewLinkStore(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'link_url' => 'required|url',
            'description' => 'nullable|string',
            'assigned_to' => 'nullable|integer|exists:users,id',
        ]);
        $data['sent_by'] = $request->user()->id;
        $data['status'] = 'pending';

        $link = ReviewLink::create($data);
        return response()->json($link->load(['sender', 'assignee']), 201);
    }

    public function reviewLinkRespond(Request $request, ReviewLink $reviewLink)
    {
        $reviewLink->update([
            'status' => 'reviewed',
            'review_comment' => $request->validate(['review_comment' => 'nullable|string'])['review_comment'] ?? null,
            'reviewed_at' => now(),
        ]);
        return response()->json($reviewLink);
    }

    // ==================== NOTES ====================
    public function noteIndex(Request $request)
    {
        return response()->json(
            Note::where('user_id', $request->user()->id)->orderBy('created_at', 'desc')->get()
        );
    }

    public function noteStore(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'content' => 'nullable|string',
            'todo_items' => 'nullable|array',
            'color' => 'nullable|string',
        ]);
        $data['user_id'] = $request->user()->id;

        $note = Note::create($data);
        return response()->json($note, 201);
    }

    public function noteUpdate(Request $request, Note $note)
    {
        if ($note->user_id !== $request->user()->id) abort(403);

        $note->update($request->validate([
            'title' => 'sometimes|string',
            'content' => 'nullable|string',
            'todo_items' => 'nullable|array',
            'color' => 'nullable|string',
        ]));
        return response()->json($note);
    }

    public function noteDestroy(Request $request, Note $note)
    {
        if ($note->user_id !== $request->user()->id) abort(403);
        $note->delete();
        return response()->json(['message' => 'Note deleted.']);
    }

    private function authorizeRole(Request $request, array $roles)
    {
        if (!in_array($request->user()->role, $roles)) {
            abort(403, 'Unauthorized');
        }
    }
}
