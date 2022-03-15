;WITH cte AS (
    SELECT
        *,
        CHECKSUM(*) AS chksum,
        ROW_NUMBER() OVER(ORDER BY GETDATE()) AS row_num
    FROM
        My_Table
)
SELECT
    *
FROM
    CTE T1
INNER JOIN CTE T2 ON
    T2.chksum = T1.chksum AND
    T2.row_num <> T1.row_num