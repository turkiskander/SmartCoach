@extends('layouts.app')


@section('title', 'SmartCoach — Administration')


@section('styles')


<style>
    .admin-container {
        min-height: calc(100vh - 80px);
        margin-top: 80px;
        padding: 40px;
    }
    .admin-card {
        background: rgba(15, 23, 42, 0.4);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 24px;
        padding: 32px;
        max-width: 1000px;
        margin: 0 auto;
    }
    .admin-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 32px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        padding-bottom: 20px;
    }
    .admin-title {
        font-family: 'Orbitron', sans-serif;
        font-size: 1.5rem;
        color: #FFB800;
    }
    .user-table {
        width: 100%;
        border-collapse: collapse;
        color: var(--text);
    }
    .user-table th {
        text-align: left;
        padding: 16px;
        color: var(--text-muted);
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    .user-table td {
        padding: 16px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }
    .badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
    }
    .badge-pending {
        background: rgba(255, 184, 0, 0.1);
        color: #FFB800;
        border: 1px solid #FFB800;
    }
    .btn-approve {
        background: #006039;
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s ease;
    }
    .btn-approve:hover {
        background: #007a48;
        transform: translateY(-2px);
    }
    .btn-refuse {
        background: rgba(220, 38, 38, 0.2);
        color: #ef4444;
        border: 1px solid #ef4444;
        padding: 8px 16px;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s ease;
    }
    .btn-refuse:hover {
        background: rgba(220, 38, 38, 0.3);
        transform: translateY(-2px);
    }
    .empty-state {
        text-align: center;
        padding: 60px;
        color: var(--text-muted);
    }
</style>
@endsection

@section('content')
<div class="admin-container">
    <div class="admin-card">
        <div class="admin-header">
            <h1 class="admin-title">Approbations en attente</h1>
            <span class="badge badge-pending">{{ $pendingUsers->count() }} nouveaux</span>
        </div>

        @if(session('success'))
            <div style="background: rgba(0, 96, 57, 0.2); border: 1px solid #006039; color: white; padding: 15px; border-radius: 12px; margin-bottom: 20px;">
                {{ session('success') }}
            </div>
        @endif

        @if($pendingUsers->isEmpty())
            <div class="empty-state">
                <p>Aucun utilisateur en attente d'approbation pour le moment.</p>
            </div>
        @else
            <table class="user-table">
                <thead>
                    <tr>
                        <th>Utilisateur</th>
                        <th>Email</th>
                        <th>Objectif</th>
                        <th>Offre</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($pendingUsers as $user)
                    <tr>
                        <td style="font-weight: 600;">{{ $user->name }}</td>
                        <td>{{ $user->email }}</td>
                        <td>{{ str_replace('_', ' ', ucfirst($user->goal)) }}</td>
                        <td><span style="color: #FFB800; font-weight: bold;">{{ ucfirst($user->offer) }}</span></td>
                        <td>
                            <div style="display: flex; gap: 10px;">
                                <form action="{{ route('admin.approve', $user->id) }}" method="POST">
                                    @csrf
                                    <button type="submit" class="btn-approve">Approuver</button>
                                </form>
                                <form action="{{ route('admin.refuse', $user->id) }}" method="POST" onsubmit="return confirm('Êtes-vous sûr de vouloir refuser cette inscription ?');">
                                    @csrf
                                    <button type="submit" class="btn-refuse">Refuser</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>
</div>
@endsection
