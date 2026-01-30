use trafficdb;
SELECT * FROM trafficdb.traffic_data;

#Creating column named Temperacture 
alter table traffic_data
add column temperature_c Float;

#disable safe mode temp
set sql_safe_updates=0;

#update temp values bcoz by default it is null
DESC traffic_data;
alter table traffic_data modify column timestamp datetime;
update traffic_data
set temperature_c=case
when hour(timestamp) between 6 and 11 then 28
when hour(timestamp) between 12 and 16 then 33 
else 26 
end;

#Find Average traffic speed overall
select avg(traffic_speed_kmph) as avg_speed from traffic_data;

#Finding min and max vehicle count
select max(vehicle_count) as max_vehicles,min(vehicle_count) as min_vehicles from traffic_data;


#Find hourluy average traffic speed and AQI
select hour(timestamp) as hour,
avg(traffic_speed_kmph) as avg_speed,
avg(air_quality_index) as avg_aqi
from traffic_data
group by hour(timestamp)
order by hour;

#Find coorelation trend does higher traffic cause poor air quality
select 
case 
when vehicle_count<200 then 'low Traffic'
when vehicle_count between 200 and 500 then 'medium traffic'
else 'high traffic'
end as traffic_level,
avg(air_quality_index) as avg_aqi
from traffic_data
group by traffic_level;

#Find days with worst avg traffic speed
select date(timestamp) as date,avg(traffic_speed_kmph) as avg_speed
from traffic_data
group by date(timestamp)
order by avg_speed ASC
Limit 10;


#Identify which range of AQi corresponds to high congesrion
select
case 
when air_quality_index <50 then 'Good'
when air_quality_index between 50 and 100 then 'Moderate'
when air_quality_index between 100 and 200 then 'Unhealthy'
else 'Very Unhealthy'
end as aqi_category,
avg(congestion_level_percent) as avg_congestion
from traffic_data
group by aqi_category
order by avg_congestion desc;



#Find peak hours where both traffic and pollution are high
select hour(timestamp) as hour,
avg(vehicle_count) as avg_vehicles,
avg(air_quality_index) as avg_aqi
from traffic_data
group by hour(timestamp)
having avg(vehicle_count)>(select avg(vehicle_count) from traffic_data)
and avg(air_quality_index)>(select avg(air_quality_index)from traffic_data)
order by hour;

show databases;
