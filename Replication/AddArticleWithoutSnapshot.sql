-- run sp_helppublication
-- ensure immediate_sync and allow_annoymous = 0
-- add article in usual way, see that only new articles are snapshotted

-- if this fails manually copy table to subscriber and set subscription status to active manually using sp_changesubstatus 
/* Check subscription for active
Subscription status:

 0 = Inactive

 1 = Subscribed

 2 = Active
*/
sp_helpsubscription


--Run on your publication database
EXEC sp_changepublication
@publication = 'REP_P', --Enter your publication_name
@property = 'allow_anonymous' ,
@value = 'false'
GO
EXEC sp_changepublication
@publication = 'REP_P', --Enter your publication name
@property = 'immediate_sync' , 
@value = 'false' 
GO 