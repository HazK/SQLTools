DECLARE @WKT AS VARCHAR(8000);

SET @WKT = 
  STUFF(
    (SELECT ',' + CAST( FY AS CHAR(4) ) + ' ' + CAST( Sales AS VARCHAR(30) )
     FROM #Sales
     ORDER BY FY
     FOR XML PATH('')), 1, 1, '');

SELECT geometry::STGeomFromText( 'LINESTRING(' + @WKT + ')', 0 );
