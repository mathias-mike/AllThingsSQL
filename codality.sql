/* Given a table events with the following structure:

  create table events (
      event_type integer not null,
      value integer not null,
      time timestamp not null,
      unique(event_type, time)
  );

write an SQL query that, for each event_type that has been registered more than once,
returns the difference between the latest (i.e. the most recent in terms of time) and the second 
latest value.The table should be ordered by event_type (in ascending order).
*/
SELECT event_type, diff_value
FROM (
    SELECT 
        event_type, 
        value - LEAD(value) OVER (PARTITION BY event_type ORDER BY time DESC) diff_value,
        ROW_NUMBER() OVER (PARTITION BY event_type ORDER BY time DESC) row_num
    FROM events
)t1
WHERE diff_value IS NOT NULL AND row_num = 1;


/* You are given two tables, teams and matches, with the following structures:

  create table teams (
      team_id integer not null,
      team_name varchar(30) not null,
      unique(team_id)
  );

  create table matches (
      match_id integer not null,
      host_team integer not null,
      guest_team integer not null,
      host_goals integer not null,
      guest_goals integer not null,
      unique(match_id)
  );
Each record in the table teams represents a single soccer team. Each record in the table matches represents 
a finished match between two teams. Teams (host_team, guest_team) are represented by their IDs in the teams 
table (team_id). No team plays a match against itself. You know the result of each match (that is, the number 
of goals scored by each team).

You would like to compute the total number of points each team has scored after all the matches described in 
the table. The scoring rules are as follows:

If a team wins a match (scores strictly more goals than the other team), it receives three points.
If a team draws a match (scores exactly the same number of goals as the opponent), it receives one point.
If a team loses a match (scores fewer goals than the opponent), it receives no points.
Write an SQL query that returns a ranking of all teams (team_id) described in the table teams. For each team 
you should provide its name and the number of points it received after all described matches (num_points). 
The table should be ordered by num_points (in decreasing order). In case of a tie, order the rows by team_id 
(in increasing order).
*/
SELECT team_id, team_name, SUM(points) num_poinst
FROM (
    SELECT 
        t.team_id team_id, 
        t.team_name team_name,
        CASE 
            WHEN t.team_id = m.host_team THEN 
                CASE WHEN m.host_goals - m.guest_goals > 0 THEN 3
                    WHEN m.host_goals - m.guest_goals = 0 THEN 1
                    ELSE 0 END
            ELSE 
                CASE WHEN m.guest_goals - m.host_goals > 0 THEN 3
                WHEN m.guest_goals - m.host_goals = 0 THEN 1
                ELSE 0 END
            END points
    FROM teams t
    LEFT JOIN matches m
    ON t.team_id = m.host_team OR team_id = m.guest_team
) t1
GROUP BY 1, 2
ORDER BY 3 DESC, 1;
