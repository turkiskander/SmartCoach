<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ModuleController extends Controller
{
    /**
     * Display the main dashboard for mobile modules.
     */
    public function index()
    {
        return view('user.modules.index');
    }

    /**
     * Show a specific module.
     */
    public function show($module)
    {
        $validModules = ['protein', 'pp_calculator', 'beeper', 'calculator', 'training_calculation'];
        
        if (!in_array($module, $validModules)) {
            abort(404);
        }

        return view("user.modules.{$module}");
    }
}
