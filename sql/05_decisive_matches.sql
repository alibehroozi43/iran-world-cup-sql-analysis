WITH ASIAN_TEAMS AS (
SELECT 
	TA.team_id,
	TM.team_name,
	T.year,
	SUM(CAST(TA.goals_for AS INT)) AS TOTAL_GOALS_FOR,
	SUM(CAST(TA.goals_against AS INT)) AS TOTAL_GOALS_AGAINST,
	SUM(CAST(TA.goal_differential AS INT)) AS DIFFERNTIAL_GOALS,
	SUM(CAST(ta.win AS INT)) AS wins,
	SUM(CAST(ta.draw AS INT)) AS draws,
	SUM(CAST(ta.lose AS INT)) AS losses,
	COUNT(*) AS matches,
	SUM(CAST(ta.win AS INT))*3
	+ SUM(CAST(ta.draw AS INT)) AS points
FROM team_appearances	TA
JOIN teams TM ON TA.team_id = TM.team_id
JOIN tournaments T ON T.tournament_id = TA.tournament_id
WHERE TM.team_name LIKE '%Iran%'
   OR TM.team_name LIKE '%Japan%'
   OR TM.team_name LIKE '%Korea%'
   OR TM.team_name LIKE '%Saudi Arabia%'
GROUP BY TA.team_id, TM.team_name, T.year)
SELECT
	team_name,
	COUNT(DISTINCT year) AS TPURNUENT,
	SUM(matches) AS TOTAL_MATCHES,
	SUM(wins) AS TOITAL_WINS,
	SUM(losses) AS TOTLA_LOSSES,
	SUM(draws) AS TOTAL_DRAWS,
	SUM(TOTAL_GOALS_FOR) AS GF,
	SUM(TOTAL_GOALS_AGAINST) AS GA,
	SUM(DIFFERNTIAL_GOALS) AS DG,
	(SELECT COUNT(*) FROM qualified_teams QT
	JOIN teams TM2 ON TM2.team_id = QT.team_id
	WHERE TM2.team_name = AST.team_name
	AND QT.performance NOT LIKE '%GROUP%') AS REACHING
FROM ASIAN_TEAMS AST
GROUP BY team_name
