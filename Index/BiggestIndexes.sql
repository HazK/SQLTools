Declare @PageSize as int
Select @PageSize= low/1024.0 from master.dbo.spt_values Where Number=1 And type='E'
select object_name(i.object_id) as [Table Name],
i.name as [Index Name]
, Convert(numeric(18,3),Convert(numeric,@PageSize * SUM(a.used_pages - CASE WHEN a.type <> 1 
THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END)) / 1024) 
As [Data Space Used (In Mbs)]
 
,Convert(numeric(18,3), Convert(numeric(18,3),@PageSize * SUM(CASE WHEN a.type <> 1 THEN a.used_pages WHEN p.index_id < 2 THEN a.data_pages ELSE 0 END)) / 1024)  
As [Index Space Used  (In Mbs)]
, SUM(Case When p.index_id=1 and a.type=1 Then p.rows else 0 end) 
As [Total No of Rows]
 
FROM sys.indexes as i
JOIN sys.partitions as p ON p.object_id = i.object_id and p.index_id = i.index_id
JOIN sys.allocation_units as a ON a.container_id = p.partition_id
LEFT Join sys.tables t ON i.object_id=t.object_id 
 
Where t.type='U'
Group By object_name(i.object_id),
i.name
Order By object_name(i.object_id)
