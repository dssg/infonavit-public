with var_stats as (
        SELECT        
                var11,
                count(*) as count_all,
                SUM(CASE WHEN var42='ABANDONADA' then 1 else 0 end) as count_aban        
        from loans
        group by var11
),
municipality as (
   select 
        var26,var11,       
          count(*) as freq,
          SUM(CASE WHEN var42='ABANDONADA' then 1 else 0 end) as abandoned_freq
     from loans
        group by var26,var11
        order by var26
)
 select  
        var26, freq, freq/CAST(count_all as numeric) as percent,
        abandoned_freq,
        abandoned_freq/CAST(count_aban as numeric) as abandoned_percent,
    abandoned_freq/CAST(freq as numeric) as ratio  
 from municipality m join var_stats v on m.var11=v.var11; 

