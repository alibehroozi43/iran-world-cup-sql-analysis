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
