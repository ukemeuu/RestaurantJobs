-- Allow Admins to update ANY job
create policy "Admins can update any job" on jobs
  for update
  using (
    exists (
      select 1 from user_roles
      where id = auth.uid()
      and role = 'admin'
    )
  );
