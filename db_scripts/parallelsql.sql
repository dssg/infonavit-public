--TODO add description and push to public github
CREATE OR REPLACE FUNCTION public.parallelsql(db text, table_to_chunk text, pkey text, query text, output_table text, table_to_chunk_alias text default '', num_chunks integer default 2, replacement_string text default '1=1')
  RETURNS text AS
$BODY$
DECLARE 
  sql     TEXT;
  min_id  bigint;
  max_id  bigint;
  step_size bigint;
  lbnd bigint;
  ubnd bigint;
  subquery text;
  insert_query text;
  i bigint;
  conn text;
  n bigint;
  num_done bigint;
  status bigint;
  dispatch_result bigint;
  dispatch_error text;
  part text;
  rand text;
  array_procs int[];

BEGIN
  --find minimum pkey id
  sql := 'SELECT min(' || pkey || ') from ' || table_to_chunk || ' ' || table_to_chunk_alias || ';';
  execute sql into min_id;

  --find maximum pkey id
  sql := 'SELECT max(' || pkey || ')  from ' || table_to_chunk || ' ' || table_to_chunk_alias ||';';
  execute sql into max_id;

  -- determine size of chunks based on min id, max id, and number of chunks
  sql := 'SELECT ( ' || max_id || '-' || min_id || ')/' || num_chunks || ';';
  
  EXECUTE sql into step_size;

  --initialize array for keeping track of finished processes
  sql := 'SELECT array_fill(0, ARRAY[' || num_chunks+1 ||']);';
  EXECUTE sql into array_procs;

  -- loop through chunks
  <<chunk_loop>>
  for lbnd,ubnd,i in 
	SELECT  generate_series(min_id,max_id,step_size) as lbnd, 
		generate_series(min_id+step_size,max_id+step_size,step_size) as ubnd,
		generate_series(1,num_chunks+1) as i
  LOOP
--for debugging
   RAISE NOTICE 'Chunk %: % >= % and % < %', i,pkey,lbnd,pkey,ubnd;

    --make a new db connection
    conn := 'conn_' || i; 
    RAISE NOTICE 'New Connection name: %',conn;
 
    sql := 'SELECT dblink_connect(' || QUOTE_LITERAL(conn) || ',' || QUOTE_LITERAL('user=XXXX password=XXXX dbname=' || db) ||');';
    execute sql;

    -- cancel a previous crashed query
    sql := 'SELECT dblink_cancel_query(' || QUOTE_LITERAL(conn) ||');';	
    execute sql;	

    -- create a subquery string that will be added to the where in the original query markes as 1=1
    --if the last chuck is read, add greater then and is null
    if i <> num_chunks+1 then
	part := ' ' || pkey || ' >= ' || lbnd || ' AND ' || pkey || ' < ' || ubnd;
    else
        part := ' ' || pkey || ' >= ' || lbnd || ' OR ' || pkey || ' is NULL';
    end if;
   

    --edit the input query using the subsquery string
    sql := 'SELECT REPLACE(' || QUOTE_LITERAL(query) || ',' || QUOTE_LITERAL(replacement_string) || ',' || QUOTE_LITERAL(part) || ');'; 
    --debug RAISE NOTICE 'SQL COMMAND: %',sql;	  
    execute sql into subquery;
    
    insert_query := 'INSERT INTO ' || output_table || ' ' || subquery || ';';
    raise NOTICE '%', insert_query;
--     --send the query asynchronously using the dblink connection
    sql := 'SELECT dblink_send_query(' || QUOTE_LITERAL(conn) || ',' || QUOTE_LITERAL(insert_query) || ');';
    execute sql into dispatch_result;

    -- check for errors dispatching the query
    if dispatch_result = 0 then
	sql := 'SELECT dblink_error_message(' || QUOTE_LITERAL(conn)  || ');';
	execute sql into dispatch_error;
        RAISE '%', dispatch_error;
    end if;
    
  end loop chunk_loop;

  -- wait until all queries are finished
  num_done := 0;
  Loop
	  for i in 1..num_chunks+1
	  Loop
		if array_procs[i]<>1 THEN
			conn := 'conn_' || i;
			sql := 'SELECT dblink_is_busy(' || QUOTE_LITERAL(conn) || ');';
			execute sql into status;
			if status = 0 THEN	
				-- check for error messages
				sql := 'SELECT dblink_error_message(' || QUOTE_LITERAL(conn)  || ');';
				execute sql into dispatch_error;
				if dispatch_error <> 'OK' THEN
					RAISE '%', dispatch_error;
				end if;
			    num_done := num_done + 1;
			    RAISE NOTICE 'Process done:  %',conn;
			    array_procs[i]=1;
			END if;
		END if;
	  end loop;
	  if num_done >= num_chunks+1 then
		exit;
	  end if;
-- modifed due to suggestions from git hub comments klaus
  sql := 'select pg_sleep(1)';
  execute sql;

  END loop;

  -- disconnect the dblinks
  FOR i in 1..num_chunks+1
  LOOP
	conn := 'conn_' || i;
	sql := 'SELECT dblink_disconnect(' || QUOTE_LITERAL(conn) || ');';
	execute sql;
  end loop;

  RETURN 'Success';

-- error catching to disconnect dblink connections, if error occurs
exception when others then
  BEGIN
  RAISE NOTICE '% %', SQLERRM, SQLSTATE;
  for n in 
	SELECT generate_series(1,i) as n
  LOOP
    	
    conn := 'conn_' || n;

    -- cancel a previous crashed query
    sql := 'SELECT dblink_cancel_query(' || QUOTE_LITERAL(conn) ||');';	
    execute sql;
    	

    sql := 'SELECT dblink_disconnect(' || QUOTE_LITERAL(conn) || ');';
    execute sql;
  END LOOP;
  exception when others then
    RAISE NOTICE '% %', SQLERRM, SQLSTATE;
  end;
  
END
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100;
