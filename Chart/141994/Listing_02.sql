DECLARE @WKT AS VARCHAR(8000);

SET @WKT = 
  STUFF(
    (SELECT ',((' + 
			CAST( FY - 0.3 AS VARCHAR(30) ) + ' 0,' +
			CAST( FY - 0.3 AS VARCHAR(30) ) + ' ' + CAST( Sales AS VARCHAR(30) ) + ',' +
			CAST( FY + 0.3 AS VARCHAR(30) ) + ' ' + CAST( Sales AS VARCHAR(30) ) + ',' +
			CAST( FY + 0.3 AS VARCHAR(30) ) + ' 0,' +
			CAST( FY - 0.3 AS VARCHAR(30) ) + ' 0))' 
	 FROM	#Sales
	 ORDER BY FY
	 FOR XML PATH('')), 1, 1, '');

SELECT geometry::STGeomFromText( 'MULTIPOLYGON(' + @WKT + ')', 0 );
