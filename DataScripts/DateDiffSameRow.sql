
29
down vote
accepted
If your table is t, and your datetime column is ts, and you want the answer in seconds:

SELECT DATEDIFF(SECOND, MIN(ts), MAX(ts) ) 
       /
       (COUNT(DISTINCT(ts)) -1) 
FROM t
This will be miles quicker for large tables as it has no n-squared JOIN

This uses a cute mathematical trick which helps with this problem. Ignore the problem of duplicates for the moment. The average time difference between consecutive rows is the difference between the first timestamp and the last timestamp, divided by the number of rows -1.

Proof: The average distance between consecutive rows is the sum of the distance between consective rows, divided by the number of consecutive rows. But the sum of the difference between consecutive rows is just the distance between the first row and last row (assuming they are sorted by timestamp). And the number of consecutive rows is the total number of rows -1.