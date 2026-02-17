-- INSPECT JOBS TABLE CONSTRAINTS
-- Run this to see exactly what constraints are active on the 'jobs' table.

SELECT 
    con.conname as constraint_name, 
    con.contype as constraint_type, 
    pg_get_constraintdef(con.oid) as definition
FROM pg_catalog.pg_constraint con
INNER JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid
INNER JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace
WHERE nsp.nspname = 'public'
AND rel.relname = 'jobs';
