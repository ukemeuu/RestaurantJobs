-- 1. AUTO-CONFIRM TRIGGER (Bypasses Email Confirmation)
CREATE OR REPLACE FUNCTION public.auto_confirm_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Automatically verify the user's email
  NEW.email_confirmed_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_auto_confirm ON auth.users;
CREATE TRIGGER on_auth_user_auto_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();


-- 2. HANDLE NEW USER (Role & Profile Creation)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  assigned_role text;
  metadata_role text;
BEGIN
  -- Determine Role
  metadata_role := new.raw_user_meta_data->>'role';
  assigned_role := COALESCE(metadata_role, 'candidate');

  -- Insert into user_roles
  INSERT INTO public.user_roles (id, role)
  VALUES (new.id, assigned_role);

  -- Create Profile
  IF assigned_role = 'employer' THEN
    INSERT INTO public.employers (id, poc_email, org_name)
    VALUES (new.id, new.email, COALESCE(new.raw_user_meta_data->>'org_name', ''));
  ELSIF assigned_role = 'candidate' THEN
    INSERT INTO public.candidate_profiles (id)
    VALUES (new.id);
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
