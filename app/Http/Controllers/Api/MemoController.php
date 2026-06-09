<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Memo;
use App\Models\MemoRead;
use App\Models\MemoResponse;
use Illuminate\Http\Request;

class MemoController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $memos = Memo::with(['sender', 'reads', 'responses.user'])
            ->where('sender_id', $userId)
            ->orWhereJsonContains('recipients', $userId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($memos);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'subject' => 'required|string',
            'content' => 'required|string',
            'recipients' => 'required|array',
            'recipients.*' => 'integer|exists:users,id',
        ]);

        $data['sender_id'] = $request->user()->id;

        $memo = Memo::create($data);
        return response()->json($memo->load(['sender', 'reads', 'responses']), 201);
    }

    public function show(Request $request, Memo $memo)
    {
        $userId = $request->user()->id;

        // Mark as read if recipient
        if (in_array($userId, $memo->recipients ?? [])) {
            MemoRead::firstOrCreate([
                'memo_id' => $memo->id,
                'user_id' => $userId,
            ]);
        }

        return response()->json($memo->load(['sender', 'reads', 'responses.user']));
    }

    public function destroy(Request $request, Memo $memo)
    {
        if ($memo->sender_id !== $request->user()->id && !in_array($request->user()->role, ['operations_manager'])) {
            abort(403);
        }

        $memo->delete();
        return response()->json(['message' => 'Memo deleted.']);
    }

    public function respond(Request $request, Memo $memo)
    {
        $data = $request->validate(['content' => 'required|string']);

        $response = MemoResponse::create([
            'memo_id' => $memo->id,
            'user_id' => $request->user()->id,
            'content' => $data['content'],
        ]);

        return response()->json($response->load('user'), 201);
    }
}
