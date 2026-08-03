USE worldcup;

WITH IRAN_PERFORMANCE AS (
SELECT 
	T.year,
	SUM(TA.goals_for) AS TOTAL_GOALS_FOR,
	SUM(TA.goals_against) AS TOTAL_GOALS_AGAINST,
	SUM(goal_differential) AS TOTAL_GOAL_DIFF,
	SUM(CAST(TA.win AS int)) AS TOTAL_WIN,
	SUM(CAST(TA.lose AS int)) AS TOTAL_LOSES,
	SUM(CAST(TA.draw AS int)) AS TOTAL_DRAW,
	SUM(
		CASE
			WHEN TA.WIN = 1 THEN 3
			WHEN TA.draw = 1 THEN 1
			ELSE 0
		END
		) AS POINTS
FROM team_appearances TA
JOIN teams TM ON TM.team_id = TA.team_id
JOIN tournaments T ON TA.tournament_id = T.tournament_id
WHERE TM.team_name = 'Iran'
GROUP BY T.year
)
SELECT 
	*,
	LAG(POINTS) OVER(ORDER BY year) AS PREVIOUS_POINTS,
	SUM(TOTAL_GOALS_FOR) OVER (ORDER BY year) AS cumulative_goals_scored
FROM IRAN_PERFORMANCE
ORDER BY year


WITH IranGroups AS (
SELECT DISTINCT
	GS.tournament_id,
	GS.group_name
FROM group_standings GS
JOIN teams TM ON GS.team_id = TM.team_id
WHERE TM.team_code = 'IRN'
AND GS.stage_name IN ('group stage')

),
GroupTeams AS (
SELECT
	IG.tournament_id,
	IG.group_name,
	TM.team_name,
	GS.team_id

FROM IranGroups IG
JOIN group_standings GS ON IG.tournament_id = GS.tournament_id
AND IG.group_name = GS.group_name
JOIN teams TM ON TM.team_id = GS.team_id
AND GS.stage_name IN ('group stage')
),
QUALIFIED_PERFORMANCE AS (
SELECT 
	team_id,
	tournament_id,
	MAX(
		CASE
			WHEN performance = 'group stage' THEN 1
            WHEN performance = 'round of 16' THEN 2
            WHEN performance = 'second group stage' THEN 3
            WHEN performance IN ('quarter-final','quarter-finals') THEN 4
            WHEN performance = 'semi-finals' THEN 5
            WHEN performance IN ('final','third-place match') THEN 6
            WHEN performance = 'final round' THEN 7
		END) AS PERFORMANCE_LEVEL
FROM qualified_teams
GROUP BY team_id, tournament_id
),
GroupPerformance AS
(
SELECT
	GT.team_id,
    GT.tournament_id,
    GT.group_name,
    GT.team_name,
    GS.points,
    GS.wins,
    GS.draws,
    GS.goals_for,
    GS.goals_against,
    GS.goal_difference
FROM GroupTeams GT
JOIN group_standings GS
    ON GS.tournament_id = GT.tournament_id
   AND GS.team_id = GT.team_id
)

SELECT G.*,
		QP.PERFORMANCE_LEVEL
FROM GroupPerformance G
JOIN QUALIFIED_PERFORMANCE QP ON QP.team_id = G.team_id AND QP.tournament_id = G.tournament_id
ORDER BY G.tournament_id, group_name, points DESC;

--========================================

WITH IranTournoment AS (
SELECT DISTINCT
	GS.tournament_id
FROM group_standings GS
JOIN teams TM ON GS.team_id = TM.team_id
WHERE TM.team_code = 'IRN'
AND GS.stage_name IN ('group stage')

),
GroupTeams AS (
SELECT
	IT.tournament_id,
	GS.group_name,
	TM.team_name,
	GS.team_id

FROM IranTournoment IT
JOIN group_standings GS ON IT.tournament_id = GS.tournament_id
JOIN teams TM ON TM.team_id = GS.team_id
AND GS.stage_name IN ('group stage')
),
QUALIFIED_PERFORMANCE AS (
SELECT 
	team_id,
	tournament_id,
	MAX(
		CASE
			WHEN performance = 'group stage' THEN 1
            WHEN performance = 'round of 16' THEN 2
            WHEN performance = 'second group stage' THEN 3
            WHEN performance IN ('quarter-final','quarter-finals') THEN 4 * 2
            WHEN performance = 'semi-finals' THEN 5 * 2
            WHEN performance IN ('final','third-place match') THEN 6 * 2
            WHEN performance = 'final round' THEN 7 * 2
		END) AS PERFORMANCE_LEVEL
FROM qualified_teams
GROUP BY team_id, tournament_id
),
GroupPerformance AS
(
SELECT
    GT.tournament_id,
    GT.group_name,
    AVG(GS.points) AS AVG_POINS,
    AVG(GS.goals_for) AS AVG_GOALS_FOR,
    AVG(GS.goals_against) AS AGAINST_GOALS
FROM GroupTeams GT
JOIN group_standings GS
    ON GS.tournament_id = GT.tournament_id
   AND GS.team_id = GT.team_id
GROUP BY GT.tournament_id, GT.group_name
),
GroupAvgPerformance AS (
    SELECT
        GT.tournament_id,
        GT.group_name,
        AVG(QP.PERFORMANCE_LEVEL) AS AVG_PERFORMANCE
    FROM GroupTeams GT
    JOIN QUALIFIED_PERFORMANCE QP
        ON QP.team_id = GT.team_id
       AND QP.tournament_id = GT.tournament_id
    GROUP BY GT.tournament_id, GT.group_name
)

SELECT G.*,
       GAP.AVG_PERFORMANCE
FROM GroupPerformance G
JOIN GroupAvgPerformance GAP
    ON G.tournament_id = GAP.tournament_id
   AND G.group_name = GAP.group_name
ORDER BY G.tournament_id, G.group_name, G.AVG_POINS DESC;


SELECT
    G.tournament_id,
    G.team_id,
	G.match_period,
    CASE
        WHEN G.minute_regulation BETWEEN 1 AND 15 THEN '01-15'
        WHEN G.minute_regulation BETWEEN 16 AND 30 THEN '16-30'
        WHEN G.minute_regulation BETWEEN 31 AND 45 THEN '31-45'
        WHEN G.minute_regulation BETWEEN 46 AND 60 THEN '46-60'
        WHEN G.minute_regulation BETWEEN 61 AND 75 THEN '61-75'
        WHEN G.minute_regulation BETWEEN 76 AND 90 THEN '76-90'
        ELSE '90+'
    END AS period_label,
    SUM(CAST(G.home_team AS INT)) AS HOME_GOALS,
	SUM(CAST(G.away_team AS INT)) AS AWAY_GOALS,
	SUM(CAST(G.own_goal AS INT)) AS TOTAL_OWN_GOLAS,
	SUM(CAST(G.penalty AS INT))	AS TOTAL_PENALTY
FROM goals G
JOIN teams TM ON G.team_id = TM.team_id
WHERE TM.team_code = 'IRN'
GROUP BY
    G.tournament_id,
    G.team_id,
	G.match_period,
    CASE
        WHEN G.minute_regulation BETWEEN 1 AND 15 THEN '01-15'
        WHEN G.minute_regulation BETWEEN 16 AND 30 THEN '16-30'
        WHEN G.minute_regulation BETWEEN 31 AND 45 THEN '31-45'
        WHEN G.minute_regulation BETWEEN 46 AND 60 THEN '46-60'
        WHEN G.minute_regulation BETWEEN 61 AND 75 THEN '61-75'
        WHEN G.minute_regulation BETWEEN 76 AND 90 THEN '76-90'
        ELSE '90+'
    END;

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


WITH IRAN_MATCH AS (
SELECT 
	T.year,
	M.match_name,
	TA.goal_differential AS DIFF_GOAL,
	CASE
		WHEN TA.win =1 THEN 3
		WHEN TA.draw = 1 THEN 1
		ELSE 0
	END AS MATCH_POINTS

FROM team_appearances TA
JOIN tournaments T ON TA.tournament_id = T.tournament_id
JOIN teams TM ON TA.team_id = TM.team_id
JOIN matches M ON TA.match_id = M.match_id AND TA.tournament_id = M.tournament_id
WHERE tm.team_name='Iran'
)
SELECT 
	*,
	RANK() OVER (ORDER BY IM.DIFF_GOAL DESC, MATCH_POINTS DESC) AS RANK_
FROM IRAN_MATCH IM

