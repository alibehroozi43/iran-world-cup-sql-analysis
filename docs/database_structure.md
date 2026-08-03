# Database Structure

This document summarizes the main database tables and fields used in the Iran World Cup SQL Analysis project.

## Database

```sql
USE worldcup;
```

The project uses a relational World Cup database containing tournament, team, match, goal, qualification, and group-stage records.

## Main Tables

The SQL analyses use the following tables:

| Table | Purpose |
|---|---|
| `teams` | Stores national team identifiers, names, and codes |
| `tournaments` | Stores FIFA World Cup tournament editions |
| `matches` | Stores individual World Cup matches |
| `team_appearances` | Stores team-level performance for each match |
| `group_standings` | Stores group-stage results and standings |
| `qualified_teams` | Stores tournament stage reached by each team |
| `goals` | Stores individual goal events and match timing |

---

# Table Relationships

The project joins tables through identifiers such as:

```text
team_id
tournament_id
match_id
```

A simplified relationship structure is:

```text
teams
  |
  | team_id
  |
team_appearances
  |
  | tournament_id
  |
tournaments
```

For match-level analysis:

```text
matches
   |
   | match_id + tournament_id
   |
team_appearances
```

For group-stage analysis:

```text
teams
   |
   | team_id
   |
group_standings
   |
   | tournament_id
   |
tournaments
```

For stage-progression analysis:

```text
teams
   |
   | team_id
   |
qualified_teams
```

For goal-timing analysis:

```text
teams
   |
   | team_id
   |
goals
```

---

# 1. teams

The `teams` table provides team identity information.

Fields used in this project include:

| Field | Description |
|---|---|
| `team_id` | Unique team identifier |
| `team_name` | Full national team name |
| `team_code` | Short team code such as `IRN` |

Example filters:

```sql
WHERE team_name = 'Iran'
```

or:

```sql
WHERE team_code = 'IRN'
```

---

# 2. tournaments

The `tournaments` table stores World Cup editions.

Fields used include:

| Field | Description |
|---|---|
| `tournament_id` | Unique tournament identifier |
| `year` | Tournament year |

This table is used to compare Iran's performance across:

```text
1978
1998
2006
2014
2018
2022
```

---

# 3. matches

The `matches` table stores individual match records.

Fields used include:

| Field | Description |
|---|---|
| `match_id` | Match identifier |
| `tournament_id` | Tournament identifier |
| `match_name` | Match description, such as `Wales vs Iran` |

The table is joined to `team_appearances` using both:

```text
match_id
tournament_id
```

Example:

```sql
JOIN matches AS m
    ON ta.match_id = m.match_id
   AND ta.tournament_id = m.tournament_id
```

---

# 4. team_appearances

This is the main table for team-level match performance.

Fields used include:

| Field | Description |
|---|---|
| `team_id` | Team identifier |
| `tournament_id` | Tournament identifier |
| `match_id` | Match identifier |
| `goals_for` | Goals scored by the team |
| `goals_against` | Goals conceded by the team |
| `goal_differential` | Goals scored minus goals conceded |
| `win` | Win indicator |
| `draw` | Draw indicator |
| `lose` | Loss indicator |

This table supports:

- Historical tournament analysis
- Match-point calculation
- Goal-difference analysis
- Asian-team comparisons
- Decisive-match ranking

## Match Points

Points are calculated using:

```sql
CASE
    WHEN win = 1 THEN 3
    WHEN draw = 1 THEN 1
    ELSE 0
END
```

---

# 5. group_standings

The `group_standings` table stores group-stage performance.

Fields used include:

| Field | Description |
|---|---|
| `tournament_id` | Tournament identifier |
| `team_id` | Team identifier |
| `group_name` | Group name |
| `stage_name` | Tournament stage |
| `points` | Group-stage points |
| `wins` | Number of wins |
| `draws` | Number of draws |
| `goals_for` | Goals scored |
| `goals_against` | Goals conceded |
| `goal_difference` | Goal difference |

This table is used to identify:

- Iran's group
- Teams in Iran's group
- Average group points
- Average goals
- Group difficulty

The analyses filter this table using:

```sql
stage_name = 'group stage'
```

---

# 6. qualified_teams

The `qualified_teams` table stores the final stage reached by each team.

Fields used include:

| Field | Description |
|---|---|
| `team_id` | Team identifier |
| `tournament_id` | Tournament identifier |
| `performance` | Highest tournament stage reached |

Possible performance values in the project include:

```text
group stage
round of 16
second group stage
quarter-final
quarter-finals
semi-finals
final
third-place match
final round
```

A custom performance score is created with a `CASE` expression.

| Stage | Basic score |
|---|---:|
| Group stage | 1 |
| Round of 16 | 2 |
| Second group stage | 3 |
| Quarter-final | 4 |
| Semi-final | 5 |
| Final or third-place match | 6 |
| Final round | 7 |

A weighted alternative gives additional importance to later knockout stages.

This score is project-specific and is not an official FIFA metric.

---

# 7. goals

The `goals` table contains individual goal events.

Fields used include:

| Field | Description |
|---|---|
| `tournament_id` | Tournament identifier |
| `team_id` | Team associated with the goal event |
| `match_period` | First half, second half, or stoppage time |
| `minute_regulation` | Regulation minute of the goal |
| `home_team` | Home-team goal indicator |
| `away_team` | Away-team goal indicator |
| `own_goal` | Own-goal indicator |
| `penalty` | Penalty-goal indicator |

Goal minutes are grouped into:

| Period | Minute range |
|---|---|
| `01-15` | 1 through 15 |
| `16-30` | 16 through 30 |
| `31-45` | 31 through 45 |
| `46-60` | 46 through 60 |
| `61-75` | 61 through 75 |
| `76-90` | 76 through 90 |
| `90+` | Stoppage time or other values |

## Important Limitation

The fields `home_team` and `away_team` indicate the side associated with a goal event.

To determine whether Iran scored or conceded a goal, the query must also identify whether Iran was the home or away team in the corresponding match.

Without that match-role logic, results should only be interpreted as Iran-related goal events.

---

# Tables Used by Analysis

| Analysis | Main tables |
|---|---|
| Historical performance | `team_appearances`, `teams`, `tournaments` |
| Iran group opponents | `group_standings`, `teams`, `qualified_teams` |
| Group comparison | `group_standings`, `qualified_teams`, `teams` |
| Goal timing | `goals`, `teams` |
| Asian comparison | `team_appearances`, `teams`, `tournaments`, `qualified_teams` |
| Decisive matches | `team_appearances`, `matches`, `teams`, `tournaments` |

---

# Data Model Considerations

## Composite Match Join

The project joins `matches` and `team_appearances` using:

```text
match_id + tournament_id
```

This reduces the risk of matching records from different tournament editions.

## Team Filtering

Iran is identified using either:

```sql
team_name = 'Iran'
```

or:

```sql
team_code = 'IRN'
```

Using `team_code` is generally preferable when it is consistent and unique.

## Stage Name Variations

The `performance` field contains variations such as:

```text
quarter-final
quarter-finals
```

Both values must be included in the `CASE` expression.

## Historical Format Differences

World Cup tournament formats have changed over time.

Therefore:

- Group-stage comparisons are not perfectly identical across all editions.
- A performance-stage score is an approximation.
- Results should be interpreted as historical comparisons rather than exact normalized ratings.
