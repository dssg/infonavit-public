.open desinventar.db
.header on
.mode csv
.once disaster.csv
SELECT d.*, g.GeographyCode
FROM Disaster d
LEFT JOIN Geography g
ON d.GeographyId=g.GeographyId;