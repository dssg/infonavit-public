select 
	map.gid as coloniaid,l.*
from 
	colonias_centroid as map, LATERAL 
	(	
	select 
SUM(CASE WHEN distance < 2500 THEN no_employee ELSE 0 END) no_employee_0_2_5k,
SUM(CASE WHEN distance < 5000 THEN no_employee ELSE 0 END) no_employee_0_5k,
SUM(CASE WHEN distance < 10000 THEN no_employee ELSE 0 END) no_employee_0_10k,
SUM(CASE WHEN distance < 15000 THEN no_employee ELSE 0 END) no_employee_0_15k,
SUM(CASE WHEN distance < 20000 THEN no_employee ELSE 0 END) no_employee_0_20k,
SUM(CASE WHEN distance < 25000 THEN no_employee ELSE 0 END) no_employee_0_25k,
SUM(CASE WHEN distance < 30000 THEN no_employee ELSE 0 END) no_employee_0_30k,
SUM(CASE WHEN distance < 35000 THEN no_employee ELSE 0 END) no_employee_0_35k,
SUM(CASE WHEN distance < 40000 THEN no_employee ELSE 0 END) no_employee_0_40k,
SUM(CASE WHEN distance < 45000 THEN no_employee ELSE 0 END) no_employee_0_45k,
SUM(CASE WHEN distance < 50000 THEN no_employee ELSE 0 END) no_employee_0_50k,
SUM(CASE WHEN distance < 2500 THEN 1 ELSE 0 END) no_businesses_0_2_5k,
SUM(CASE WHEN distance < 5000 THEN 1 ELSE 0 END) no_businesses_0_5k,
SUM(CASE WHEN distance < 10000 THEN 1 ELSE 0 END) no_businesses_0_10k,
SUM(CASE WHEN distance < 15000 THEN 1 ELSE 0 END) no_businesses_0_15k,
SUM(CASE WHEN distance < 20000 THEN 1 ELSE 0 END) no_businesses_0_20k,
SUM(CASE WHEN distance < 25000 THEN 1 ELSE 0 END) no_businesses_0_25k,
SUM(CASE WHEN distance < 30000 THEN 1 ELSE 0 END) no_businesses_0_30k,
SUM(CASE WHEN distance < 35000 THEN 1 ELSE 0 END) no_businesses_0_35k,
SUM(CASE WHEN distance < 40000 THEN 1 ELSE 0 END) no_businesses_0_40k,
SUM(CASE WHEN distance < 45000 THEN 1 ELSE 0 END) no_businesses_0_45k,
SUM(CASE WHEN distance < 50000 THEN 1 ELSE 0 END) no_businesses_0_50k,
SUM(CASE WHEN distance >= 2500 and distance < 5000 THEN no_employee ELSE 0 END) no_employee_2_5_5k,
SUM(CASE WHEN distance >= 5000 and distance < 10000 THEN no_employee ELSE 0 END) no_employee_5_10k,
SUM(CASE WHEN distance >= 10000 and distance < 15000 THEN no_employee ELSE 0 END) no_employee_10_15k,
SUM(CASE WHEN distance >= 15000 and distance < 20000 THEN no_employee ELSE 0 END) no_employee_15_20k,
SUM(CASE WHEN distance >= 20000 and distance < 25000 THEN no_employee ELSE 0 END) no_employee_20_25k,
SUM(CASE WHEN distance >= 25000 and distance < 30000 THEN no_employee ELSE 0 END) no_employee_25_30k,
SUM(CASE WHEN distance >= 30000 and distance < 35000 THEN no_employee ELSE 0 END) no_employee_30_35k,
SUM(CASE WHEN distance >= 35000 and distance < 40000 THEN no_employee ELSE 0 END) no_employee_35_40k,
SUM(CASE WHEN distance >= 40000 and distance < 45000 THEN no_employee ELSE 0 END) no_employee_40_45k,
SUM(CASE WHEN distance >= 45000 and distance < 50000 THEN no_employee ELSE 0 END) no_employee_45_50k,
SUM(CASE WHEN distance >= 2500 and distance < 5000 THEN 1 ELSE 0 END) no_businesses_2_5_5k,
SUM(CASE WHEN distance >= 5000 and distance < 10000 THEN 1 ELSE 0 END) no_businesses_5_10k,
SUM(CASE WHEN distance >= 10000 and distance < 15000 THEN 1 ELSE 0 END) no_businesses_10_15k,
SUM(CASE WHEN distance >= 15000 and distance < 20000 THEN 1 ELSE 0 END) no_businesses_15_20k,
SUM(CASE WHEN distance >= 20000 and distance < 25000 THEN 1 ELSE 0 END) no_businesses_20_25k,
SUM(CASE WHEN distance >= 25000 and distance < 30000 THEN 1 ELSE 0 END) no_businesses_25_30k,
SUM(CASE WHEN distance >= 30000 and distance < 35000 THEN 1 ELSE 0 END) no_businesses_30_35k,
SUM(CASE WHEN distance >= 35000 and distance < 40000 THEN 1 ELSE 0 END) no_businesses_35_40k,
SUM(CASE WHEN distance >= 40000 and distance < 45000 THEN 1 ELSE 0 END) no_businesses_40_45k,
SUM(CASE WHEN distance >= 45000 and distance < 50000 THEN 1 ELSE 0 END) no_businesses_45_50k 		
	from (			
		select  
			internal_map.gid as mapgid,
			denue.gid,
			no_employee,
			ST_Distance_Spheroid(denue.geom,map.geom,''SPHEROID["WGS 84",6378137,298.257223563]'') as distance
		from 
			denue2010 as denue, --TODO replace in script
			colonias_centroid as internal_map
		Where                
			internal_map.gid=map.gid and ST_DWithin(denue.geom,map.geom,0.5)
		group by 
			internal_map.gid, 
			denue.gid
			) as distances
	group by mapgid) l

	
where	
	(1=1) 
