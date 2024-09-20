show databases;
use project3;


#table-1 users
CREATE TABLE users (
user_id INT,
created_at VARCHAR(100),
company_id INT,
language VARCHAR(70),
activated_at VARCHAR(100),
state VARCHAR(60)
);



SHOW VARIABLES LIKE 'secure_file_priv';



LOAD DATA INFILE "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from users;
ALTER table users add column temp_created_at datetime;
UPDATE users SET temp_created_at = STR_TO_DATE(created_at, '%d-%m-%y %H %i');


SELECT extract(week(created_at)) * count(DISTINCT user_id) as Weekly_User_engagement
FROM events
GROUP BY week
ORDER BY week;




#weekly user engagement

select extract(week from occured_at) as week_number,
count(distinct user_id) as active_user
from events_tb1
where event_type='engagement'
group by week_number
order by week_number;



#user growth analysis

select year, week_num, num_users, sun(num_users)                                                                                           ;;
 over (order by year, week_num) as cum_users          
 from (
 select extract(year from created_at) as year, extract(week from created_at) as week_num, count(distinct user_id) as num_users
 from users_tb1
 where state='active'
 group by year, week_num
 order by year, week_num)sub
 
 
 
 
 #weekly retention analysis
 
 with ctel as (
 select distinct user_id,
 Extract (week from occured at) as signup_week
 from events_tb1
 where event_type = 'signup_flow"
 and event_name = 'complete_signup and extract (week from occurred at) = 18 ),
 cte2 as (select distinct user_id,
 Extract (week from occurred at) as engagement_week
 from events_tb1
 where event_type = 'engagement')
 select count(user_id) total_engaged_users,
 sum(case when retension_week> 8 then 1 else end) as retained_users
 from (select a.user_id, a.signup_week,
 b.engagement_week, b.engagement_week-a.signup_week as retension_week
 from ctel a
 LEFT JOIN cte2 b
 on a.user_id - b.user_id
 order by a.user_id) sub
 
 # weekly engagement per device
 
 with cte as (select extract (year from occurred_at)||'-'||extract(week from occurred_at) as weeknum
 device, count(distinct user_id) as usercnt
 from events_tb1
 where event_type = 'engagement'
 group by weeknum, device 
 order by weeknum)
 select weeknum, device, usercnt
 from cte
 
 
 # email engagement analysis
 
 select
 100 * sum(case when email_cat = 'email_open' then 1 else 0 end)/
 sum(case when email_cat = 'email sent' then 1 else 0 end) as email_open_rate,
 100 * sum(case when email_cat = 'email clicked' then 1 else 0 end)/
 sun(case when email_cat = 'email sent' then 1 else 0 end) as email_click_rate
 from (select*,
 case
 when action in ('sent_weekly_digest', 'sent_reengagement_email') then 'email_sent'
 when action in ('email_open') then 'email_open'
 when action in ('email_clickthrough') then 'email_clicked'
 end as email_cat
 from email_events) sub

