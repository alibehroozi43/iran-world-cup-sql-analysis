# Iran World Cup Performance Analysis with SQL

A hypothesis-driven SQL project analyzing Iran's historical FIFA World Cup performance.

The project examines tournament trends, group difficulty, goal timing, comparisons with Asian teams, and Iran's most decisive World Cup matches.

## Project Overview

Iran has participated in six FIFA World Cup tournaments in the analyzed database:

| Year | Tournament appearance |
|---:|---|
| 1978 | First analyzed appearance |
| 1998 | Second appearance |
| 2006 | Third appearance |
| 2014 | Fourth appearance |
| 2018 | Fifth appearance |
| 2022 | Sixth appearance |

The project uses SQL to answer five main questions:

1. Has Iran improved over time?
2. Has Iran consistently faced unusually difficult groups?
3. During which match periods is Iran most vulnerable?
4. Why have Japan and South Korea progressed more frequently?
5. Which matches represent the major turning points in Iran's World Cup history?

## Skills Demonstrated

- SQL joins
- Common Table Expressions
- Window functions
- Conditional aggregation
- CASE expressions
- Subqueries
- Ranking
- Historical trend analysis
- Custom metric design
- Hypothesis-driven analysis
- Sports analytics
- Analytical interpretation

## Repository Structure

```text
iran-world-cup-sql-analysis/
│
├── sql/
│   ├── 01_iran_historical_performance.sql
│   ├── 02_group_difficulty_analysis.sql
│   ├── 03_goal_timing_analysis.sql
│   ├── 04_asian_team_comparison.sql
│   ├── 05_decisive_matches.sql
│   └── all_queries.sql
│
├── docs/
│   ├── database_structure.md
│   ├── methodology.md
│   └── insights.md
│
├── report/
│   └── Report_sql.pdf
│
├── README.md
└── LICENSE
```

## Database Tables

The analyses use these main tables:

| Table | Analytical role |
|---|---|
| `teams` | National team names and codes |
| `tournaments` | World Cup editions and years |
| `matches` | Match names and identifiers |
| `team_appearances` | Team-level match performance |
| `group_standings` | Group-stage results |
| `qualified_teams` | Highest tournament stage reached |
| `goals` | Goal timing and event information |

Detailed table descriptions are available in:

```text
docs/database_structure.md
```

## Analysis 1: Historical Performance

### Research Question

Has Iran improved across its six World Cup appearances?

### SQL Techniques

- CTE
- Aggregation
- CASE expression
- `LAG`
- Cumulative `SUM OVER`

### Tournament Results

| Year | Goals For | Goals Against | Goal Difference | Wins | Draws | Losses | Points |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1978 | 2 | 8 | -6 | 0 | 1 | 2 | 1 |
| 1998 | 2 | 4 | -2 | 1 | 0 | 2 | 3 |
| 2006 | 2 | 6 | -4 | 0 | 1 | 2 | 1 |
| 2014 | 1 | 4 | -3 | 0 | 1 | 2 | 1 |
| 2018 | 2 | 2 | 0 | 1 | 1 | 1 | 4 |
| 2022 | 4 | 7 | -3 | 1 | 0 | 2 | 3 |

### Finding

The results do not support a continuous improvement trend.

Iran's strongest overall performance occurred in 2018:

```text
4 points
Goal difference: 0
1 win
1 draw
1 loss
```

Iran scored more goals in 2022, but also conceded seven goals and finished with fewer points than in 2018. :contentReference[oaicite:0]{index=0}

## Analysis 2: Group Difficulty

### Research Question

Has Iran always been unlucky in the World Cup draw?

### Method

A custom performance score is assigned according to the highest stage reached by each team.

| Tournament stage | Performance level |
|---|---:|
| Group stage | 1 |
| Round of 16 | 2 |
| Second group stage | 3 |
| Quarter-final | 4 |
| Semi-final | 5 |
| Final or third-place match | 6 |
| Final round | 7 |

Average performance is then calculated for every group in the tournaments Iran participated in.

### Finding

Iran faced difficult opponents in several tournaments, including:

| Tournament | Notable opponents |
|---:|---|
| 1998 | Germany, Yugoslavia |
| 2006 | Portugal, Mexico |
| 2014 | Argentina, Nigeria |
| 2018 | Spain, Portugal |
| 2022 | England, United States |

However, Iran's group was not consistently the strongest group in every tournament.

The hypothesis of permanent bad luck in the draw is therefore not fully supported. :contentReference[oaicite:1]{index=1}

## Analysis 3: Goal Timing

### Research Question

During which match periods is Iran most vulnerable?

### Time Buckets

| Label | Minutes |
|---|---|
| `01-15` | 1 to 15 |
| `16-30` | 16 to 30 |
| `31-45` | 31 to 45 |
| `46-60` | 46 to 60 |
| `61-75` | 61 to 75 |
| `76-90` | 76 to 90 |
| `90+` | Stoppage time |

### Finding

Iran-related goal events occurred more frequently in the second half, particularly after the 60th minute.

The analyzed output also showed no Iran goal event in the first 15 minutes.

This supports the hypothesis that Iran has historically been more vulnerable during the later stages of matches.

### Limitation

The original query must combine goal events with Iran's home-or-away role to distinguish goals scored from goals conceded with full certainty.

Until that logic is explicitly verified, this analysis should be interpreted cautiously.

## Analysis 4: Comparison with Asian Teams

### Research Question

Why have Japan and South Korea progressed more often than Iran?

### Overall Comparison

| Team | Tournaments | Matches | Wins | Draws | Losses | Goals For | Goals Against | Knockout-stage progressions |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Iran | 6 | 18 | 3 | 4 | 11 | 13 | 31 | 0 |
| Japan | 15 | 58 | 22 | 7 | 29 | 64 | 92 | 8 |
| North Korea | 6 | 20 | 4 | 3 | 13 | 18 | 41 | 2 |
| Saudi Arabia | 6 | 19 | 4 | 2 | 13 | 14 | 44 | 1 |
| South Korea | 14 | 48 | 9 | 10 | 29 | 45 | 105 | 4 |

### Finding

Japan's advantage is especially clear in:

- Total wins
- Goals scored
- Tournament consistency
- Knockout-stage qualifications

South Korea has also progressed beyond the group stage more frequently than Iran.

The main difference is not only defensive performance. Iran has also scored fewer goals and earned fewer wins. :contentReference[oaicite:2]{index=2}

## Analysis 5: Decisive Matches

Matches are ranked using:

```sql
RANK() OVER (
    ORDER BY goal_difference DESC, match_points DESC
)
```

### Highest-Ranked Positive Results

| Rank | Year | Match | Goal Difference | Points |
|---:|---:|---|---:|---:|
| 1 | 2022 | Wales vs Iran | +2 | 3 |
| 2 | 1998 | United States vs Iran | +1 | 3 |
| 2 | 2018 | Morocco vs Iran | +1 | 3 |
| 4 | 2018 | Iran vs Portugal | 0 | 1 |
| 4 | 2006 | Iran vs Angola | 0 | 1 |
| 4 | 2014 | Iran vs Nigeria | 0 | 1 |
| 4 | 1978 | Scotland vs Iran | 0 | 1 |

### Largest Defeats

| Year | Match | Goal Difference |
|---:|---|---:|
| 2022 | England vs Iran | -4 |
| 1978 | Netherlands vs Iran | -3 |
| 1978 | Peru vs Iran | -3 |

### Finding

Iran's World Cup history has been shaped by a small number of strong individual results rather than sustained tournament success.

The victories over Wales, the United States, and Morocco are the three highest-ranked positive results. :contentReference[oaicite:3]{index=3}

## Main Conclusions

| Question | Conclusion |
|---|---|
| Has Iran continuously improved? | No; 2018 was the strongest edition, but the improvement was not sustained |
| Has Iran always had the hardest group? | No; some groups were difficult, but permanent bad luck is not supported |
| When is Iran most vulnerable? | Later stages of matches, especially after the 60th minute |
| Why are Japan and South Korea more successful? | More wins, more goals, and more knockout-stage qualifications |
| What are Iran's best matches? | Wins over Wales, the United States, and Morocco |

## Key SQL Features

### Common Table Expressions

CTEs are used to organize multi-stage calculations:

```sql
WITH iran_performance AS (
    ...
)
SELECT *
FROM iran_performance;
```

### Window Functions

The project uses:

```sql
LAG(points) OVER (ORDER BY year)
```

to compare tournament points with the previous appearance.

It also uses:

```sql
SUM(total_goals_for) OVER (ORDER BY year)
```

for cumulative goals and:

```sql
RANK() OVER (
    ORDER BY goal_difference DESC, match_points DESC
)
```

for ranking decisive matches.

### Conditional Aggregation

Match points and performance levels are created with `CASE` expressions.

### Multiple Joins

The project joins tournament, team, match, standings, qualification, and goal-event data.

## Documentation

| Document | Description |
|---|---|
| `docs/database_structure.md` | Main database tables and relationships |
| `docs/methodology.md` | Analytical questions, metrics, and methods |
| `docs/insights.md` | Detailed findings and interpretations |
| `report/Report_sql.pdf` | Original Persian analytical report |

## How to Run

1. Load the World Cup database into your SQL environment.
2. Select the database:

```sql
USE worldcup;
```

3. Run the files inside `sql/` in numerical order:

```text
01_iran_historical_performance.sql
02_group_difficulty_analysis.sql
03_goal_timing_analysis.sql
04_asian_team_comparison.sql
05_decisive_matches.sql
```

Alternatively, run:

```text
sql/all_queries.sql
```

## Limitations

- Iran has only 18 World Cup matches in the analyzed dataset.
- World Cup formats changed across tournament editions.
- The opponent-strength metric is custom and unofficial.
- Goal-timing logic requires validation of Iran's home-and-away role.
- The project does not include advanced statistics such as expected goals.
- The analysis identifies historical patterns rather than causal effects.

## Future Improvements

- Validate scored-versus-conceded goal timing
- Add FIFA rankings or Elo ratings
- Normalize metrics per match
- Add opponent-adjusted performance
- Add views and stored procedures
- Add automated tests for query outputs
- Create a Power BI or Tableau dashboard
- Integrate SQL results with Python
- Add advanced match statistics

## Author

**Ali Behroozi**

Transportation Engineer and Data Science Researcher interested in:

- SQL analytics
- Sports analytics
- Data visualization
- Machine learning
- Transportation data science
- Business intelligence

## License

This project is available under the MIT License.
