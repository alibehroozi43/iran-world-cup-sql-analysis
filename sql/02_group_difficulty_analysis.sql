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
