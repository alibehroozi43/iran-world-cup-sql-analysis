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
