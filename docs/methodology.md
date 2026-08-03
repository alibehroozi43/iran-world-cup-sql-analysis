# Methodology

This document explains the analytical approach used in the Iran World Cup SQL Analysis project.

## Project Goal

The goal of this project is to analyze Iran's historical performance in the FIFA World Cup using SQL.

The project converts football-related questions and hypotheses into structured SQL queries and interpretable analytical results.

The analysis focuses on five main areas:

1. Historical performance trends
2. Group difficulty and opponent strength
3. Goal timing and match vulnerability
4. Comparison with Asian national teams
5. Decisive and historically important matches

---

# Analytical Workflow

The general workflow used in the project is:

```text
Raw World Cup database
        ↓
Table joins and filtering
        ↓
Aggregation and feature construction
        ↓
Window functions and ranking
        ↓
Hypothesis evaluation
        ↓
Analytical interpretation
```

Each analysis begins with a hypothesis or research question.

SQL is then used to extract the required data, calculate the relevant metrics, and evaluate whether the hypothesis is supported by the observed results.

---

# 1. Historical Performance Analysis

## Research Question

Has Iran improved across its six FIFA World Cup appearances?

## Hypothesis

Iran performed better in recent tournaments, especially from 2014 onward.

The expected indicators of improvement were:

- More points
- More wins
- More goals scored
- Fewer goals conceded
- Better goal difference

## SQL Approach

The historical analysis aggregates Iran's tournament performance by year.

The following indicators are calculated:

```text
Total goals scored
Total goals conceded
Goal difference
Wins
Losses
Draws
Points
Previous tournament points
Cumulative goals scored
```

The query uses:

- `SUM`
- `CASE`
- `GROUP BY`
- `LAG`
- Cumulative `SUM OVER`

## Points Calculation

Match points are calculated using:

```sql
CASE
    WHEN win = 1 THEN 3
    WHEN draw = 1 THEN 1
    ELSE 0
END
```

## Trend Comparison

The `LAG` window function compares each tournament's points with the previous appearance.

```sql
LAG(points) OVER (ORDER BY year)
```

A cumulative sum is also used to track Iran's total World Cup goals over time.

```sql
SUM(total_goals_for) OVER (ORDER BY year)
```

## Interpretation Rule

The hypothesis is supported only if improvement is relatively consistent across multiple performance indicators.

A single strong tournament is not considered evidence of continuous improvement.

---

# 2. Group Difficulty Analysis

## Research Question

Has Iran consistently been placed in unusually difficult World Cup groups?

## Hypothesis

Iran's opponents were, on average, stronger than the opponents in other groups.

## Analytical Approach

The analysis first identifies Iran's group in each tournament.

It then extracts all teams in the same group and evaluates their tournament performance.

The following indicators are considered:

```text
Group points
Wins
Draws
Goals scored
Goals conceded
Goal difference
Highest tournament stage reached
```

## Performance-Level Metric

A custom performance-level variable is created from the final stage reached by each team.

Example structure:

```text
Group stage               = 1
Round of 16               = 2
Second group stage        = 3
Quarter-final             = 4
Semi-final                = 5
Final or third-place      = 6
Final round               = 7
```

A higher value represents a stronger tournament performance.

## Weighted Variant

A weighted version of the metric gives more importance to teams reaching the later knockout stages.

For example:

```text
Quarter-final       = 4 × 2
Semi-final          = 5 × 2
Final               = 6 × 2
Final round         = 7 × 2
```

This weighting is a project-specific analytical choice.

It is intended to reflect the idea that reaching the final stages indicates substantially stronger performance than only advancing from the group stage.

It should not be interpreted as an official FIFA ranking system.

## Group Comparison

For each tournament group, the query calculates:

```text
Average points
Average goals scored
Average goals conceded
Average performance level
```

Iran's group is then compared with the other groups in the same tournament.

## Interpretation Rule

The hypothesis of permanent bad luck is supported only if Iran's group consistently ranks among the strongest groups.

If Iran's group is only unusually strong in some tournaments, the conclusion should be limited to those specific editions.

---

# 3. Goal Timing Analysis

## Research Question

During which periods of a match is Iran most vulnerable?

## Hypothesis

Iran concedes more goals in the second half, especially after the 60th minute.

The project also tests whether Iran scores fewer goals in the first 15 minutes.

## Time Buckets

Goals are grouped into the following intervals:

```text
01–15
16–30
31–45
46–60
61–75
76–90
90+
```

The time bucket is created using:

```sql
CASE
    WHEN minute_regulation BETWEEN 1 AND 15 THEN '01-15'
    WHEN minute_regulation BETWEEN 16 AND 30 THEN '16-30'
    WHEN minute_regulation BETWEEN 31 AND 45 THEN '31-45'
    WHEN minute_regulation BETWEEN 46 AND 60 THEN '46-60'
    WHEN minute_regulation BETWEEN 61 AND 75 THEN '61-75'
    WHEN minute_regulation BETWEEN 76 AND 90 THEN '76-90'
    ELSE '90+'
END
```

## Metrics

The analysis considers:

```text
Goals by match period
Goals by tournament
Home-team goal indicator
Away-team goal indicator
Own goals
Penalties
```

## Methodological Limitation

The original goal table records whether the scoring team was the home or away team.

Therefore, identifying goals scored and conceded specifically by Iran requires combining the goal record with Iran's home or away role in each match.

If this relationship is not explicitly applied, the output should be interpreted as a distribution of Iran-related goal events rather than a definitive scored-versus-conceded classification.

This limitation should be considered when interpreting the results.

---

# 4. Asian Team Comparison

## Research Question

Why have Japan and South Korea progressed from the group stage more often than Iran?

## Hypothesis

Japan and South Korea have been more successful because of stronger goal scoring and more consistent tournament performance.

## Teams Included

The analysis compares:

```text
Iran
Japan
South Korea
North Korea
Saudi Arabia
```

## Metrics

The following indicators are aggregated across tournament appearances:

```text
Tournament appearances
Total matches
Wins
Losses
Draws
Goals scored
Goals conceded
Goal difference
Knockout-stage appearances
```

## Knockout-Stage Count

The number of times a team reached beyond the group stage is calculated from the `qualified_teams` table.

This is used as an indicator of tournament success.

## Interpretation Rule

The comparison does not assume that one metric alone explains success.

The conclusion is based on a combination of:

- Total wins
- Goals scored
- Goal difference
- Number of tournament appearances
- Number of knockout-stage qualifications

---

# 5. Decisive Match Analysis

## Research Question

Which matches represent the most important positive and negative turning points in Iran's World Cup history?

## Hypothesis

Iran's most historically important positive results are matches with:

- Positive goal difference
- Three points
- No defeat

## Ranking Method

Each match is assigned:

```text
Goal difference
Match points
```

Match points are defined as:

```text
Win  = 3
Draw = 1
Loss = 0
```

Matches are ranked using:

```sql
RANK() OVER (
    ORDER BY goal_difference DESC, match_points DESC
)
```

This method prioritizes:

1. Higher goal difference
2. Higher match points

## Interpretation

Matches with the highest positive goal difference and full points are identified as Iran's strongest World Cup results.

Heavy defeats are identified through strongly negative goal differences.

---

# SQL Techniques Demonstrated

This project uses the following SQL techniques:

```text
INNER JOIN
Common Table Expressions
Conditional aggregation
CASE expressions
GROUP BY
Subqueries
Window functions
LAG
RANK
Cumulative SUM
COUNT DISTINCT
Custom analytical metrics
```

---

# Analytical Principles

The project follows these principles:

## Hypothesis-Driven Analysis

Each query begins with a clear analytical question.

## Tournament-Level Comparison

Results are compared across World Cup editions rather than presented as isolated records.

## Multiple Metrics

Conclusions are based on multiple performance measures instead of a single statistic.

## Explicit Limitations

Custom metrics and limitations are documented to avoid overstating the findings.

## Reproducibility

Each analysis is stored in a separate SQL file so it can be executed and reviewed independently.

---

# Limitations

The project has several limitations:

- Iran has played only 18 World Cup matches in the dataset.
- Small samples can produce unstable comparisons.
- Different tournament formats may affect historical comparisons.
- The custom opponent-strength metric is not an official ranking system.
- The analysis does not include expected goals, possession, shots, or player-level data.
- Knockout-stage qualification is influenced by tournament format and group composition.
- Goal timing analysis requires careful identification of Iran's home and away role.
- The project identifies associations rather than causal relationships.

---

# Future Improvements

Future versions could include:

- Match-level expected goals
- FIFA ranking at tournament start
- Elo ratings
- Possession and shot statistics
- Opponent-adjusted performance
- Goal-scoring and conceding rates per match
- Tournament-format normalization
- Statistical significance testing
- Visualization in Power BI or Tableau
- Automated SQL views
- Stored procedures
- Python integration
