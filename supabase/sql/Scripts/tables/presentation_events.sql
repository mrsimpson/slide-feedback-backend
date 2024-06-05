create table public.presentation_events
(
    id           bigint generated by default as identity
        primary key,
    created_at   timestamp with time zone default now() not null,
    created_by   uuid                     default auth.uid()
                                                        references auth.users
                                                            on update cascade on delete set null,
    value        jsonb,
    presentation bigint                                 not null
        references public.presentations
            on update cascade,
    type         event_type                             not null
);

alter table public.presentation_events
    owner to postgres;

grant select, update, usage on sequence public.presentation_events_id_seq to anon;

grant select, update, usage on sequence public.presentation_events_id_seq to authenticated;

grant select, update, usage on sequence public.presentation_events_id_seq to service_role;

create policy "Enable update own events" on public.presentation_events
    as permissive
    for update
    using ((SELECT auth.uid() AS uid) = created_by);

create policy "Enable reading own events" on public.presentation_events
    as permissive
    for select
    using ((SELECT auth.uid() AS uid) = created_by);

create policy "Enable insert for all users" on public.presentation_events
    as permissive
    for insert
    to anon, authenticated
    with check (true);

create policy "Presenter can see all events for own presentation" on public.presentation_events
    as permissive
    for select
    to authenticated
    using ((SELECT auth.uid() AS uid) IN (SELECT presentations.presenter
                                          FROM presentations
                                          WHERE (presentations.id = presentation_events.presentation)));

grant delete, insert, references, select, trigger, truncate, update on public.presentation_events to anon;

grant delete, insert, references, select, trigger, truncate, update on public.presentation_events to authenticated;

grant delete, insert, references, select, trigger, truncate, update on public.presentation_events to service_role;
