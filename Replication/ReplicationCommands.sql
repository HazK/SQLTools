/* List of useful replication commands

All commands here:  https://msdn.microsoft.com/en-us/library/ms174364.aspx

sp_browsesnapshotfolder -- returns latest snapshot generated for a publicaiton. exec against publication db
sp_helparticle -- Displays info about a article -- Execute against Publication DB
sp_helpdistributiondb -- displays info about the distributiondb -- Execute against distributiondb
sp_helpdistributor -- displays info about the distributiondb -- exece against distributiondb
sp_helppublication -- displays info an a publisher -- Execute against Publication DB
sp_helpdistpublisher -- returns properties of publishers using distributors -- Execute against Distribution DB
sp_helpsubscription -- returns info about a subscriber -- execute against publisher
sp_replcmds -- Returns the commands for transactions marked for replication -- Exec against pub
sp_replshowcmds -- Returns the commands for transactions marked for replication in readable format. sp_replshowcmds can be run only when client connections (including the current connection) are not reading replicated transactions from the log. This stored procedure is executed at the Publisher on the publication database.
sp_repltrans -- Returns a result set of all the transactions in the publication database transaction log that are marked for replication but have not been marked as distributed. -- Exec against pub

sys.dm_repl_articles -- Returns information about database objects published as articles in a replication topology.
sys.dm_repl_schemas -- Returns information about table columns published by replication.
sys.dm_repl_tranhash -- Returns information about transactions being replicated in a transactional publication.
sys.dm_repl_traninfo -- Returns information on each replicated or change data capture transaction.

select * from distribution.dbo.MSrepl_commands
select * from distribution.dbo.MSrepl_transactions
sp_browsereplcmds

/*