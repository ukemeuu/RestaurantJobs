-- Create a trigger function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  assigned_role text;
  metadata_role text;
BEGIN
  -- 1. Determine Role from Metadata (default to 'candidate' if missing)
  metadata_role := new.raw_user_meta_data->>'role';
  
  IF metadata_role IS NOT NULL AND metadata_role IN ('employer', 'candidate', 'admin') THEN
    assigned_role := metadata_role;
  ELSE
    assigned_role := 'candidate';
  END IF;

  -- 2. Insert into user_roles
  INSERT INTO public.user_roles (id, role)
  VALUES (new.id, assigned_role);

  -- 3. Create Profile based on Role
  IF assigned_role = 'employer' THEN
    INSERT INTO public.employers (id, poc_email, org_name)
    VALUES (
      new.id, 
      new.email,
      COALESCE(new.raw_user_meta_data->>'org_name', '')
    );
  ELSIF assigned_role = 'candidate' THEN
    INSERT INTO public.candidate_profiles (id)
    VALUES (new.id);
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remove existing trigger if it exists to avoid duplication
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Re-create the Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
