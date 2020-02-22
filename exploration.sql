select
----SUBSCRIBER DATA
	s.created_at,
	s.signedup_at,
	s.deactivated_at,
	s.carrier_name,
	s.survey_id, --need to join to something
	z.code as subscriber_zip_code,
	z.city as subscriber_city,
	s_state.name as subscriber_state,
	ss.name as subscriber_source,
	sst.name as subscriber_status,
	l.name as subscriber_language,
	sdr.name as subscriber_deactivation_method,
----PARTNER DATA
	p.name as partner_name,
	p.created_at as partner_created_date,
	p.is_active as parnter_is_active,
	pt.name as partner_type,	
	p_state.name as partner_state
----**fields unsure about:
	--s.external_id
	--p.parent_id
	--p.initiative_id
	--p.external_id
from public.v_subscribers as s
left join public.zip_codes as z 
on z.id = s.zip_id
left join public.states as s_state
on s_state.id = z.state_id
left join public.subscriber_sources as ss 
on ss.id = s.source_id
left join public.subscriber_statuses as sst 
on sst.id = s.status_id
left join public.languages as l
on l.id = s.language_id
left join public.subscriber_deactivation_reasons as sdr 
on sdr.id = s.deactivation_reason_id
left join public.partners as p
on p.id = s.partner_id
left join public.partner_types as pt 
on pt.id = p.type_id
left join public.states as p_state
on p_state.id = p.state_id
--left join public.children as c on c.subscriber_id = s.id
--left join surveys table
--left join messages (aggregate date)