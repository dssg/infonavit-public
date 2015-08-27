#!/bin/awk -f
#transform from long to wide for payments data
BEGIN { OFS = ";" }
#for each input line
{
MONTH=1;
COUNT=1;
}
{for(i=5;i<65;i++)  
	if (COUNT == 1) { 
		#print out the first entries of the row with the year and month
		printf "%s;%s;%s;%s;%s",$1,$2,$3,$4,MONTH;
		#add the first column
		printf ";%s", $i;
		COUNT++;
	}
	else if (COUNT == 5) { 
		#print the last column
		printf ";%s", $i;
		
		# add the 2 columns from the end
		printf ";%s", $(64+(MONTH*2-1));
		printf ";%s", $(64+(MONTH*2-1)+1);
	
		printf "\n";
		COUNT=1;
		MONTH++;
	}
	else { 
		#columns between
		printf ";%s", $i;
		COUNT++;
	}
}		
