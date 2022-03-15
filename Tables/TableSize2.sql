declare @tblsize table
(name varchar(100),
rows int,
reserved varchar(30),
data varchar(30),
index_size varchar(30),
unused varchar(30)
)
insert @tblsize
exec sp_MSforeachtable 'exec sp_spaceused "?"'
select * from @tblsize
