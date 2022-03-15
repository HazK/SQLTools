USE distribution; 

SET NOCOUNT ON;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT DISTINCT

@@SERVERNAME

--,A.article_id

,A.Article

,P.Publication

--,S.agent_id

,Agents.[name]

,UndelivCmdsInDistDB

,DelivCmdsInDistDB  

-- ,UndelivCmdsInDistDB + DelivCmdsInDistDB  AS TaotalTrans

FROM dbo.MSdistribution_status AS s

INNER JOIN dbo.MSdistribution_agents AS Agents ON Agents.[id] = S.agent_id

INNER JOIN dbo.MSpublications AS P ON P.publication = Agents.publication

INNER JOIN dbo.MSarticles AS A ON A.article_id = S.article_id and P.publication_id = A.publication_id

WHERE 1=1 AND UndelivCmdsInDistDB <> 0 AND Agents.subscriber_db NOT LIKE 'virtual'

--AND P.Publisher_db = '%%'

--AND A.Article LIKE  '%%'

--AND P.Publication = '%%'

ORDER BY UndelivCmdsInDistDB DESC

OPTION(RECOMPILE);
