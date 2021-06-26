-- Question on 'The Pad'
SELECT CONCAT(name, '(', substring(occupation, 1, 1), ')') AS names
FROM occupations
ORDER BY name;

SELECT CONCAT('There are a total of ', COUNT(occupation), ' ', LOWER(occupation), 's.')
FROM occupations
GROUP BY occupation
ORDER BY COUNT(occupation);



-- Question on 'Occupation'
WITH main_table AS (
    SELECT * 
    FROM occupations
    ORDER BY name
), doctor AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Doctor'
), professor AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Professor'
), singer AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Singer'
), actor AS (
    SELECT ROW_NUMBER() OVER () id, name
    FROM main_table
    WHERE occupation LIKE 'Actor'
)

-- Select cluase when Null should be in string
/*
SELECT CASE WHEN (d.name IS Null) THEN 'Null' ELSE d.name END Doctor,
     p.name Professor, 
     CASE WHEN (s.name IS Null) THEN 'Null' ELSE s.name END Singer,
     CASE WHEN (a.name IS Null) THEN 'Null' ELSE a.name END Actor
*/
-- Select cluase when it should be Null
SELECT d.name Doctor, p.name Professor, s.name Singer, a.name Actor
FROM professor p
LEFT JOIN doctor d
ON p.id = d.id
LEFT JOIN singer s
ON p.id = s.id
LEFT JOIN actor a
ON p.id = a.id;



-- Question on Binary Tree Node
SELECT n, CASE WHEN (p IS Null) THEN 'Root' 
               WHEN (n IN (SELECT DISTINCT p FROM BST)) THEN 'Inner' 
               ELSE 'Leaf' 
               END type
FROM BST
ORDER BY n;


-- Medium - New Companies
SELECT c.company_code, c.founder, COUNT(DISTINCT e.lead_manager_code) total_lm,
    COUNT(DISTINCT e.senior_manager_code) total_sm,
    COUNT(DISTINCT e.manager_code) total_m,
    COUNT(DISTINCT e.employee_code) total_emp
FROM Employee e
JOIN Company c
ON c.company_code = e.company_code
GROUP BY 1, 2
ORDER BY 1;



-- Medium - 
SELECT CASE WHEN ((A + B) <= C) OR ((B + C) <= A) OR ((A + C) <= B) THEN 'Not A Triangle'
            WHEN (A = B) AND (B = C)  THEN 'Equilateral'
            WHEN (A = B) OR (B = C) OR (A = C) THEN 'Isosceles'
            ELSE 'Scalene' END AS Types
FROM triangles;


-- https://www.hackerrank.com/challenges/weather-observation-station-18/problem
SELECT ROUND((MAX(lat_n) - MIN(lat_n)) + (MAX(long_w) - MIN(long_w)), 4) s
FROM station;


SELECT ROUND(SQRT(POWER((MAX(lat_n) - MIN(lat_n)), 2) + POWER((MAX(long_w) - MIN(long_w)), 2)), 4) s
FROM station;


SELECT CEILING(AVG(salary) - AVG(CAST(REPLACE(CONCAT(salary, ''), '0', '') AS SIGNED)))
FROM employees;


-- Question - Interviews
SELECT con.contest_id, con.hacker_id, con.name, SUM(stable.total_s) total_s, SUM(stable.total_as) total_as, SUM(vtable.total_v) total_v, SUM(vtable.total_uv) total_uv
FROM contests con
JOIN colleges col
ON con.contest_id = col.contest_id
JOIN challenges cha
ON col.college_id = cha.college_id
LEFT JOIN (
    SELECT challenge_id, SUM(total_views) total_v, SUM(total_unique_views) total_uv
    FROM view_stats
    GROUP BY 1
) vtable
ON vtable.challenge_id = cha.challenge_id
LEFT JOIN (
    SELECT challenge_id, SUM(total_submissions) total_s, SUM(total_accepted_submissions) total_as
    FROM submission_stats
    GROUP BY 1
) stable
ON stable.challenge_id = cha.challenge_id
GROUP BY 1, 2, 3
HAVING SUM(stable.total_s) <> 0 AND SUM(stable.total_as) <> 0 AND SUM(vtable.total_v) <> 0 AND SUM(vtable.total_uv) <> 0
ORDER BY 1;



-- Question - 15 Days of Learning SQL (Solution 1)
-- This solutiono should be fine but it turns out the hacker with the max submission for a given day must not necessarily have made
-- submissions everyday till that particular day. So he must not necessarily be among the "unique hackers who made at least  submission each 
-- day". 
SELECT sub1.submission_date, sub2.unique_hacker_count, sub1.hacker_id, hackers.name
FROM (
    SELECT submission_date, hacker_id, sub_count, sub_per_day, ROW_NUMBER() OVER(PARTITION BY submission_date ORDER BY sub_count DESC, hacker_id) row_num
    FROM (
        SELECT submission_date, hacker_id, COUNT(*) sub_count, RANK() OVER(PARTITION BY hacker_id ORDER BY submission_date) sub_per_day
        FROM submissions
        GROUP BY submission_date, hacker_id
        ORDER BY 1, 3 DESC, 2
    ) ii_sub
    WHERE sub_per_day = (submission_date - CAST('2016-03-01' AS DATE)) + 1 -- Removing this line takes care of the above issue...
) sub1
JOIN (
    SELECT submission_date, COUNT(*) unique_hacker_count
    FROM (
        SELECT submission_date, hacker_id, COUNT(*) sub_count, RANK() OVER(PARTITION BY hacker_id ORDER BY submission_date) sub_per_day
        FROM submissions
        GROUP BY submission_date, hacker_id
        ORDER BY 1, 3 DESC, 2
    ) sub1
    WHERE sub_per_day = (submission_date - CAST('2016-03-01' AS DATE)) + 1
    GROUP BY submission_date
) sub2
ON sub1.submission_date = sub2.submission_date AND sub1.row_num = 1
JOIN hackers
ON hackers.hacker_id = sub1.hacker_id;

-- Question - 15 Days of Learning SQL (Main solution)
SELECT sub1.submission_date, sub2.unique_hacker_count, sub1.hacker_id, hackers.name
FROM (
    SELECT submission_date, hacker_id, sub_count, sub_per_day, ROW_NUMBER() OVER(PARTITION BY submission_date ORDER BY sub_count DESC, hacker_id) row_num
    FROM (
        SELECT submission_date, hacker_id, COUNT(*) sub_count, RANK() OVER(PARTITION BY hacker_id ORDER BY submission_date) sub_per_day
        FROM submissions
        GROUP BY submission_date, hacker_id
        ORDER BY 1, 3 DESC, 2
    ) ii_sub
) sub1
JOIN (
    SELECT submission_date, COUNT(*) unique_hacker_count
    FROM (
        SELECT submission_date, hacker_id, COUNT(*) sub_count, RANK() OVER(PARTITION BY hacker_id ORDER BY submission_date) sub_per_day
        FROM submissions
        GROUP BY submission_date, hacker_id
        ORDER BY 1, 3 DESC, 2
    ) sub1
    WHERE sub_per_day = (submission_date - CAST('2016-03-01' AS DATE)) + 1
    GROUP BY submission_date
) sub2
ON sub1.submission_date = sub2.submission_date AND sub1.row_num = 1
JOIN hackers
ON hackers.hacker_id = sub1.hacker_id;

-- Question - 15 Days of Learning SQL (Went through the discussion forume and saw this solution... Make sense)
SELECT submission_date, 
(
    SELECT COUNT(DISTINCT hacker_id)  
    FROM Submissions s2  
    WHERE s2.submission_date = s1.submission_date AND (
        SELECT COUNT(DISTINCT s3.submission_date) 
        FROM Submissions s3 
        WHERE s3.hacker_id = s2.hacker_id AND s3.submission_date < s1.submission_date) = DATEDIFF(s1.submission_date , '2016-03-01')
) AS unique_hacker_count, 
(
    SELECT hacker_id 
    FROM submissions s2 
    WHERE s2.submission_date = s1.submission_date 
    GROUP BY hacker_id 
    ORDER BY COUNT(submission_id) DESC , hacker_id 
    LIMIT 1
) AS hacker_id_main,
(
    SELECT name 
    FROM hackers 
    WHERE hacker_id = hacker_id_main
) AS hacker_name
FROM (
    SELECT DISTINCT submission_date 
    FROM submissions
) s1
GROUP BY 1;



-- Question - Top Earners
SELECT (
    SELECT salary * months AS total_earnings
    FROM employee
    ORDER BY 1 DESC
    LIMIT 1
) max_earnings, (
    SELECT COUNT(*)
    FROM employee
    WHERE salary * months = (
        SELECT salary * months AS total_earnings
        FROM employee
        ORDER BY 1 DESC
        LIMIT 1
    )
);



-- Question - Weather Observation Station 20 (Solution 1)
SELECT ROUND(lat_n, 4)
FROM (
    SELECT lat_n, NTILE(2) OVER(ORDER BY lat_n) median_seperation
    FROM station
) sub
ORDER BY (LEAD(median_seperation) OVER(ORDER BY lat_n) - median_seperation) DESC
LIMIT 1;

-- Question - Weather Observation Station 20 (Onyis solution)
select round(lat_n,4)
from (select  lat_n, ntile(2) over (order by lat_n) as parts
from station) t1
where parts = 1
order by lat_n desc
limit 1;



-- Question - Draw The Triangle 1 (My solution)
SELECT REPEAT('* ', 20);
SELECT REPEAT('* ', 19);
SELECT REPEAT('* ', 18);
SELECT REPEAT('* ', 17);
SELECT REPEAT('* ', 16);
SELECT REPEAT('* ', 15);
SELECT REPEAT('* ', 14);
SELECT REPEAT('* ', 13);
SELECT REPEAT('* ', 12);
SELECT REPEAT('* ', 11);
SELECT REPEAT('* ', 10);
SELECT REPEAT('* ', 9);
SELECT REPEAT('* ', 8);
SELECT REPEAT('* ', 7);
SELECT REPEAT('* ', 6);
SELECT REPEAT('* ', 5);
SELECT REPEAT('* ', 4);
SELECT REPEAT('* ', 3);
SELECT REPEAT('* ', 2);
SELECT REPEAT('* ', 1);
SELECT REPEAT('* ', 0);

-- Better approach with RECURSIVE CTE - Draw The Triangle 1 (Thank God for loops) https://dev.mysql.com/doc/refman/8.0/en/with.html
WITH RECURSIVE t(n, star) AS (
    SELECT 20, REPEAT('* ', 20)
    UNION ALL
    SELECT n - 1, REPEAT('* ', n - 1)
    FROM t
    WHERE n > 0
)
SELECT star
FROM t;




-- Question - Draw The Triangle 2 
WITH RECURSIVE t(n, star) AS (
    SELECT 1, CAST(REPEAT('* ', 1) AS CHAR(50))
    UNION ALL
    SELECT n + 1, REPEAT('* ', n + 1)
    FROM t
    WHERE n < 20
)
SELECT star
FROM t;




-- Question - The Report
SELECT CASE WHEN g.grade < 8 THEN 'NULL' ELSE s.name END name, g.grade, s.marks
FROM students s
JOIN grades g
ON s.marks BETWEEN g.min_mark AND g.max_mark
ORDER BY 2 DESC, 1, 3;




-- Question - Top Competitors
SELECT h.hacker_id, h.name
FROM submissions s
JOIN challenges c
ON s.challenge_id = c.challenge_id
JOIN difficulty d
ON d.difficulty_level = c.difficulty_level AND s.score = d.score
JOIN hackers h
ON h.hacker_id = s.hacker_id
GROUP BY 1, 2
HAVING COUNT(*) >= 2
ORDER BY COUNT(*) DESC, 1;




-- Question - Ollivander's Inventory
SELECT id, age, coins_needed, power
FROM (
    SELECT w.id, wp.age, w.coins_needed, w.power, RANK() OVER(PARTITION BY wp.age, w.power ORDER BY w.coins_needed) galleon_rank
    FROM wands w
    JOIN wands_property wp
    ON w.code = wp.code AND wp.is_evil = 0 
    ORDER BY 4 DESC, 2 DESC
) sub
WHERE galleon_rank = 1;



-- Question - Challenges 
SELECT hacker_id, name, challenge_count
FROM (
    SELECT h.hacker_id, h.name, COUNT(*) challenge_count, COUNT(*) OVER(PARTITION BY COUNT(*)) num_std_wt_same_ch_count 
    FROM hackers h
    JOIN challenges c
    ON h.hacker_id = c.hacker_id
    GROUP BY h.hacker_id, h.name
) sub
WHERE num_std_wt_same_ch_count = 1 OR challenge_count = (
    SELECT MAX(challenge_count)
    FROM (
        SELECT h.hacker_id, h.name, COUNT(*) challenge_count
        FROM hackers h
        JOIN challenges c
        ON h.hacker_id = c.hacker_id
        GROUP BY h.hacker_id, h.name
    ) sub0
)
ORDER BY 3 DESC, 1;




-- Question - SQL Project Planning
WITH p_seg AS (
    SELECT start_date, end_date, start_date - LAG(start_date) OVER(ORDER BY start_date) start_diff, LEAD(end_date) OVER(ORDER BY end_date) - end_date end_diff
    FROM projects 
), p_start AS (
    SELECT ROW_NUMBER() OVER(ORDER BY start_date) id, start_date
    FROM p_seg
    WHERE start_diff IS NULL OR start_diff > 1
), p_end AS (
    SELECT ROW_NUMBER() OVER(ORDER BY end_date) id, end_date
    FROM p_seg
    WHERE end_diff > 1 OR end_diff IS NULL
)
SELECT start_date, end_date
FROM p_start
JOIN p_end
ON p_start.id = p_end.id
ORDER BY end_date - start_date, 1;

-- Approach 2
SELECT Start_Date, MIN(End_Date) 
FROM (
    SELECT Start_Date FROM Projects WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)
) AS s,
(
    SELECT End_Date FROM Projects WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)
) AS e
WHERE Start_Date < End_Date
GROUP BY Start_Date
ORDER BY DATEDIFF(MIN(End_Date), Start_Date), Start_Date;

-- Approach 3
Select Start_Date, MIN(End_Date)
From (
    Select b.Start_Date
    From Projects as a
    RIGHT Join Projects as b
    ON b.Start_Date = a.End_Date
    WHERE a.Start_Date IS NULL
    ) sd,
    (Select a.End_Date
    From Projects as a
    Left Join Projects as b
    ON b.Start_Date = a.End_Date
    WHERE b.End_Date IS NULL
    ) ed
Where Start_Date < End_Date
GROUP BY Start_Date
ORDER BY datediff(MIN(End_Date), Start_Date), Start_Date




-- Question - Placements
SELECT s.name
FROM (
    SELECT f.id my_id, f.friend_id f_id, p.salary my_sal
    FROM friends f
    JOIN packages p
    ON f.id = p.id
) sub
JOIN packages p
ON sub.f_id = p.id AND p.salary - sub.my_sal > 0
JOIN students s
ON s.id = sub.my_id
ORDER BY p.salary;



-- Question - Symmetric Pairs
SELECT DISTINCT sub1.x, sub1.y
FROM (
    SELECT ROW_NUMBER() OVER(ORDER BY x) id, x, y
    FROM functions
) sub1, (
    SELECT ROW_NUMBER() OVER(ORDER BY x) id, x, y
    FROM functions
) sub2
WHERE sub1.id <> sub2.id AND sub1.x = sub2.y AND sub1.y = sub2.x AND sub1.x <= sub1.y;

-- Better approach 
SELECT A.x, A.y
FROM FUNCTIONS A 
JOIN FUNCTIONS B 
ON A.x = B.y AND A.y = B.x
GROUP BY A.x, A.y
HAVING COUNT(A.x) > 1 OR A.x < A.y
ORDER BY A.x




-- Question - Print Prime Numbers
WITH RECURSIVE numbers (num) AS (
    SELECT 2
    UNION ALL
    SELECT num+1
    FROM numbers
    WHERE num < 997
), primes AS (
    SELECT RANK() OVER(ORDER BY num) id, num, COUNT(*) OVER () primes_count
    FROM numbers n1
    WHERE (
        SELECT num
        FROM numbers n2
        WHERE n1.num > n2.num AND n1.num % n2.num = 0
        LIMIT 1
    ) IS NULL
), primes_text (id, num, prime_txt) AS (
    SELECT 1, 2, CAST(2 AS CHAR(1000))
    UNION ALL
    SELECT primes_text.id + 1, primes.num, CAST(CONCAT(prime_txt, '&', primes.num) AS CHAR(1000))
    FROM primes_text
    JOIN primes
    ON primes_text.id + 1 = primes.id
    WHERE primes_text.id < primes.primes_count
)
SELECT prime_txt
FROM primes_text
ORDER BY id DESC
LIMIT 1;

-- Better approach - Using GROUP_CONCAT()
WITH RECURSIVE numbers (num) AS (
    SELECT 2
    UNION ALL
    SELECT num+1
    FROM numbers
    WHERE num < 997
), primes AS (
    SELECT num
    FROM numbers n1
    WHERE (
        SELECT num
        FROM numbers n2
        WHERE n1.num > n2.num AND n1.num % n2.num = 0
        LIMIT 1
    ) IS NULL
)
SELECT /* GROUP_CONCAT(num SEPARATOR  '&')     [OR]     ARRAY_TO_STRING(ARRAY_AGG(num), '&')*/
FROM primes;