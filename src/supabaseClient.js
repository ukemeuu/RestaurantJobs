import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://sjnfmglvaugydytncgsy.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqbmZtZ2x2YXVneWR5dG5jZ3N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxOTQwNDcsImV4cCI6MjA4NDc3MDA0N30.0uieUUlo20a0Pnkj_dco2H7eUyHQwJMRWh0sH1ueNdg'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
