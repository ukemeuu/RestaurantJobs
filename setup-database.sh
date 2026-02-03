#!/bin/bash

# Restaurant Jobs - Database Setup Script
# This script applies all necessary SQL schemas to your Supabase database

echo "🚀 Setting up Restaurant Jobs Database..."
echo ""

# Check if SUPABASE_URL and SUPABASE_ANON_KEY are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo "⚠️  Warning: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables not set."
    echo "Please set them or run the SQL files manually in Supabase SQL Editor."
    echo ""
    echo "SQL files to run in order:"
    echo "1. supabase/supabase_schema.sql (Jobs and User Roles tables)"
    echo "2. supabase/applications_schema.sql (Applications table)"
    echo "3. supabase/storage_security_policies.sql (Storage policies for resumes)"
    echo ""
    exit 1
fi

echo "✅ Environment variables found"
echo ""

# Apply schemas in order
echo "📝 Applying Jobs and User Roles schema..."
curl -X POST "$SUPABASE_URL/rest/v1/rpc/exec_sql" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d @supabase/supabase_schema.sql

echo "📝 Applying Applications schema..."
curl -X POST "$SUPABASE_URL/rest/v1/rpc/exec_sql" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d @supabase/applications_schema.sql

echo "📝 Applying Storage policies..."
curl -X POST "$SUPABASE_URL/rest/v1/rpc/exec_sql" \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d @supabase/storage_security_policies.sql

echo ""
echo "✅ Database setup complete!"
echo ""
echo "Next steps:"
echo "1. Verify tables in Supabase Dashboard > Table Editor"
echo "2. Check storage bucket 'resumes' exists in Storage"
echo "3. Test job application submission"
