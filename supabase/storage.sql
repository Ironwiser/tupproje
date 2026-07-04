-- firetrack storage, extinguisher-photos bucket politikaları
-- önce dashboard > storage > new bucket:
--   ad: extinguisher-photos
--   public: kapalı
-- sonra bu dosyayı sql editorde çalıştır

drop policy if exists "photo_upload_own" on storage.objects;
create policy "photo_upload_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'extinguisher-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "photo_update_own" on storage.objects;
create policy "photo_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'extinguisher-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  )
  with check (
    bucket_id = 'extinguisher-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "photo_read_own" on storage.objects;
create policy "photo_read_own"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'extinguisher-photos'
    and (
      auth.uid()::text = (storage.foldername(name))[1]
      or exists (
        select 1
        from public.profiles viewer
        join public.profiles owner on owner.company_id = viewer.company_id
        where viewer.id = auth.uid()
          and viewer.company_id is not null
          and owner.id::text = (storage.foldername(name))[1]
      )
    )
  );

drop policy if exists "photo_delete_own" on storage.objects;
create policy "photo_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'extinguisher-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
