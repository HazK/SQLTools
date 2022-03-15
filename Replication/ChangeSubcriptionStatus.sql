sp_helpsubscription

/* Check subscription for active
Subscription status:

 0 = Inactive

 1 = Subscribed

 2 = Active
*/

sp_changesubstatus 

-- if that does not work, at the distribution db:


SELECT * FROM MSPublications

select * From distribution..MSsubscriptions WHERE publication_id = 64

UPDATE distribution..MSsubscriptions
SET [status] = 2
WHERE publication_id = 64