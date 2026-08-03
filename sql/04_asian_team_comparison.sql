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
