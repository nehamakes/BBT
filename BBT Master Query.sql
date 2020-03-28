select
----SUBSCRIBERS
	  s.id as subscriber_id
	, s.created_at
	, s.signedup_at
	, s.deactivated_at
	, s.carrier_name
	, s.survey_id --need to join to something
	, z.code as subscriber_zip_code
	, z.city as subscriber_city
	, s_state.name as subscriber_state
	, ss.name as subscriber_source
	, sst.name as subscriber_status
	, l.name as subscriber_language
	, sdr.name as subscriber_deactivation_method
	
----CHILDREN: dob, active, created date, prenatal
	, c.number_of_children
	
----PARTNERS
	, p.name as partner_name
	, p.created_at as partner_created_date
	, p.is_active as parnter_is_active
	, pt.name as partner_type
	, p_state.name as partner_state

----MESSAGES
	, m.messages
	, case when m.messages is null 
		   	then 'No Messages'
		   when m.messages <= 10
		   	then '10 or less'
		   when m.messages <= 50
		   	then '10 - 50'
		   when m.messages <= 100
		   	then '50 - 100'
		   when m.messages <= 200
		   	then '100 - 200'
		   when m.messages <= 500
		   	then '200 - 500'
		   when m.messages > 500
		   	then '500+'
	  end as messages_category

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

left join (
	select subscriber_id
		 , count(distinct id) as number_of_children
		 --, case when (cast(date_of_birth as date) - cast(created_at as date)) <= 365 then count(distinct id) end as children_under_1_when_joined
	from public.children
	group by subscriber_id, date_of_birth, created_at
	) as c 
on c.subscriber_id = s.id

left join public.partners as p
on p.id = s.partner_id

left join public.partner_types as pt 
on pt.id = p.type_id

left join public.states as p_state
on p_state.id = p.state_id

--left join surveys table

left join (
	select m.subscriber_id
	     , count(distinct m.message_id) as messages
		 --, case when (cast(s.created_at as date) - cast(m.created_at as date)) <= 30 then count(distinct message_id) end as messages_in_first_30_days
		 --, case when datediff('day', s.created_at - m.created_at) <= 90 then count(distinct message_id) end as messages_in_first_90_days
		 --, case when datediff('day', s.created_at - m.created_at) <= 180 then count(distinct message_id) end as messages_in_first_180_days
	from archive.outbound_messages as m
	group by subscriber_id
	)as m 
on m.subscriber_id = s.id
