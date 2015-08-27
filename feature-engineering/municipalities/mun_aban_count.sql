with var_stats as (
        SELECT        
                var11,
                count(*) as anual_count,
                SUM(CASE WHEN var42='ABANDONADA' then 1 else 0 end) as anual_aban_count        
        from loans
        group by var11
),
municipality as (
   select 
        var26,var11,       
          count(*) as mun_count,
          SUM(CASE WHEN var42='ABANDONADA' then 1 else 0 end) as mun_aban_count
     from loans
        group by var26,var11
        order by var26
)
 select  
        m.var11, var26, anual_count, anual_aban_count, mun_count, mun_aban_count
 from municipality m join var_stats v on m.var11=v.var11; 
