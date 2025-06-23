//
//  Supabase.swift
//  FantasyFitness
//
//  Created by Jawwaad Sabree on 6/18/25.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://oqyigcstkojffdkwmbgf.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9xeWlnY3N0a29qZmZka3dtYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMTY1MzIsImV4cCI6MjA2NTc5MjUzMn0.Uc5d9B6uo1XOCWeLhOK2GVs4OJzJyVTMU64LgYkvEgo"
)
