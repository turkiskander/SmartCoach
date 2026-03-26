<?php

namespace App\Http\Controllers;


use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use App\Mail\AccountApprovedMail;


class AdminController extends Controller
{
    /**
     * Display a listing of pending user approvals.
     */
    public function index()
    {
        $pendingUsers = User::where('is_approved', false)->get();
        return view('admin.approvals', compact('pendingUsers'));

    }

    /**
     * Approve the specified user.
     */
    public function approve($id)
    {
        $user = User::findOrFail($id);
        $user->is_approved = true;
        $user->save();

        // Send confirmation email
        Mail::to($user->email)->send(new AccountApprovedMail($user));

        return redirect()->back()->with('success', 'L\'utilisateur a été approuvé et un e-mail de confirmation a été envoyé.');
    }

    /**
     * Refuse (delete) the specified user.
     */
    public function refuse($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return redirect()->back()->with('success', 'L\'inscription a été refusée et l\'utilisateur supprimé.');
    }
}
