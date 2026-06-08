SELECT date_part('month',u2.event_date) as month,count(distinct u2.user_id) as monthly_active_users
FROM user_actions u1
join user_actions u2
on u1.user_id=u2.user_id 
and date_part('month',u1.event_date)=date_part('month',u2.event_date)-1 
and u1.event_type is not null
and u2.event_type is not null
where date_part('month',u2.event_date)=7
GROUP by date_part('month',u2.event_date)
