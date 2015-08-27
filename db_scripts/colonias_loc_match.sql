-- Compare the accuract of levenshtein distance matching
select *, (dist_col + dist_mun) as distance  from (SELECT t.var32, t.nombremunicipio, t.var36, t.colonia,
        levenshtein(trim(upper(t.var32)),trim(upper(t.nombremunicipio))) as dist_mun,
        levenshtein(trim(upper(t.var36)),trim(upper(t.colonia))) as dist_col
FROM tmp_andy as t
group by t.var32, t.nombremunicipio, t.var36, t.colonia) as sub
WHERE dist_col + dist_mun > 0
order by distance desc
limit 1000;


-- Create table of all loans with mean location of group appended as last 2 columns
CREATE TABLE tmp_mean_locs AS (
  SELECT *, 
    avg(c.latitud) OVER w as mean_lat,  
    avg(c.longitud) OVER w as mean_long
  FROM loans l LEFT OUTER JOIN cuvs c
  ON l.var40 = c.cuv
  WINDOW w AS (PARTITION BY l.var32, l.var34, l.var36))


-- Create a table interpolating the "avg" gps coordinates for each (municipality, postal code, colonia) group
-- "avg" gps coordinate is computed as the last known gps coordinate which is closest to the mean of the 
-- points in the group.
CREATE TABLE tmp_loc_fix 
  AS (
  WITH sub AS (
    SELECT t.id, 
      t.longitud, 
      t.latitud,
      t.var32,
      t.var34,
      t.var36,
      t.nombreestado,
      t.nombremunicipio,
      t.colonia,
      sqrt((t.longitud - t.mean_long)^2.0 + (t.latitud - t.mean_lat)^2.0),
      ROW_NUMBER() OVER(PARTITION BY t.var32,
              t.var34, 
              t.var36,
              t.nombreestado,
              t.nombremunicipio,
              t.colonia
              ORDER BY 
              sqrt((t.longitud - t.mean_long)^2.0 + (t.latitud - t.mean_lat)^2.0)) as rk
      FROM tmp_andy t
      WHERE t.longitud is not NULL 
        and t.latitud is not NULL
        and t.var36 is not NULL
        and t.colonia is not NULL)
  SELECT sub.* 
    FROM sub
  WHERE sub.rk = 1
);

-- Create indexes for joining
create index idx_tmp_loc_fix_var323436 on tmp_loc_fix (upper(var32),upper(var34),upper(var36));
create index idx_loans_var323436 on loans (upper(var32),upper(var34),upper(var36));


-- Compute max error on predicted locations from locations that we do know
select max(t.longitud - l.longitud), max(t.latitud - l.latitud) from tmp_andy t JOIN tmp_loc_fix l
ON t.var32 = l.var32
AND t.var34 = l.var34
AND t.var36 = l.var36
WHERE (t.longitud is not NULL 
       and t.latitud is not NULL
       and t.var32 is not NULL
       and t.var34 is not NULL
       and t.var36 is not NULL)
LIMIT 10;
--    >>>>    216.4621153;25.829484  

-- Compute average difference between predicted colonias locations and locations we know
select avg(abs(t.longitud - l.longitud)), avg(abs(t.latitud - l.latitud))
from tmp_andy t JOIN tmp_loc_fix l
ON trim(upper(t.var32)) = trim(upper(l.var32))
AND trim(upper(t.var34)) = trim(upper(l.var34))
AND trim(upper(t.var36)) = trim(upper(l.var36))
WHERE (t.longitud is not NULL 
       and t.latitud is not NULL
       and t.var32 is not NULL
       and t.var34 is not NULL
       and t.var36 is not NULL);
-- >>>>> 0.0289043656062516; 0.0144236105148307

-- Create a table to hold all of the exact known loan locations as taken from cuvs
CREATE TABLE loans_loc AS (
  SELECT l.*, c.latitud, c.longitud, c.nombreestado, c.nombremunicipio, c.colonia 
  FROM loans l INNER JOIN cuvs c
  ON l.var40 = c.cuv)


-- Insert the remaining interpolated coordinates from tmp_loc_fix into loans_loc
insert into loans_loc 
select sub.*, tmp.latitud, tmp.longitud, tmp.nombreestado, tmp.nombremunicipio, tmp.colonia
from 
  (select l_sub.* from 
  loans l_sub left outer join loans_loc loc on l_sub.id=loc.id
  where loc.id is null) as sub
join tmp_loc_fix as tmp 
ON trim(upper(sub.var32)) = trim(upper(tmp.var32))
AND trim(upper(sub.var34)) = trim(upper(tmp.var34))
AND trim(upper(sub.var36)) = trim(upper(tmp.var36));




