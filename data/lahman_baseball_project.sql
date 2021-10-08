-- Lahman Baseball Project
--1. What range of years for baseball games played does the provided database cover?
-- 146 1871-2016
Select DISTINCT(year)
From homegames
ORDER BY year;

--2. Find the name and height of the shortest player in the database. 
--How many games did he play in? What is the name of the team for which he played?
--Edward Carl --Height-43" --Games-1 --Team-SLA(Saint Louis Browns)

SELECT namegiven, MIN(height), a.teamid, a.G_all, p.playerid
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
GROUP BY namegiven, a.teamid, a.G_all, p.playerid
ORDER BY MIN(height);

--3. Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
--David Price - $245,553,888

SELECT DISTINCT cp.playerid, schoolid, namefirst, namelast, (SUM(salary)) AS total_salary
FROM collegeplaying AS cp LEFT JOIN people AS p
ON cp.playerid = p.playerid JOIN salaries AS s
ON cp.playerid = s.playerid
WHERE schoolid = 'vandy'
GROUP BY namefirst, namelast, cp.playerid, schoolid
ORDER BY SUM(salary) DESC;

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", 
--those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016.
--Battery 41,424
--Infield 58,934
--Outfield 29,560

SELECT	SUM(po) AS total_number_of_putouts,
		CASE WHEN pos ='OF' THEN 'Outfield'
			WHEN pos ='SS' OR pos='1B' OR pos='2B' OR pos='3B' THEN 'Infield'
			WHEN pos='P' OR pos='C' THEN 'Battery' END AS position_group			
FROM fielding
WHERE yearid='2016'
GROUP BY position_group;

--5.Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--Answer - strikeouts per game rose each decade. Home runs increased each decade with the exception of a few years. 
--The 2000's had the > amt of HR.
WITH games_by_decade AS
				(SELECT SUM(g)/2 AS Total_games, 
					CASE WHEN yearid >= 1920 AND yearid < 1930 THEN '1920 - 1929'
						 WHEN yearid >= 1930 AND yearid < 1940 THEN '1930 - 1939'
						 WHEN yearid >= 1940 AND yearid < 1950 THEN '1940 - 1949'
				 		 WHEN yearid >= 1950 AND yearid < 1960 THEN '1950 - 1959'
						 WHEN yearid >= 1960 AND yearid < 1970 THEN '1960 - 1969'
						 WHEN yearid >= 1970 AND yearid < 1980 THEN '1970 - 1979'
						 WHEN yearid >= 1980 AND yearid < 1990 THEN '1980 - 1989'
						 WHEN yearid >= 1990 AND yearid < 2000 THEN '1990 - 1999'
						 WHEN yearid >= 2000 AND yearid < 2010 THEN '2000 - 2009'
						 WHEN yearid >= 2010 AND yearid < 2017 THEN '2010 - 2017'
				 	     END AS decade
					FROM teams
					WHERE yearid >= 1920
					GROUP BY decade),
--total strikeouts & homeruns by decade from batting table
strikeouts_and_homeruns_by_decade AS
				(SELECT SUM(so) AS total_strikeouts, SUM(HR) AS total_homeruns,
					CASE WHEN yearid >= 1920 AND yearid < 1930 THEN '1920 - 1929'
						 WHEN yearid >= 1930 AND yearid < 1940 THEN '1930 - 1939'
				 		 WHEN yearid >= 1940 AND yearid < 1950 THEN '1940 - 1949'
				 		 WHEN yearid >= 1950 AND yearid < 1960 THEN '1950 - 1959'
						 WHEN yearid >= 1960 AND yearid < 1970 THEN '1960 - 1969'
						 WHEN yearid >= 1970 AND yearid < 1980 THEN '1970 - 1979'
				 		 WHEN yearid >= 1980 AND yearid < 1990 THEN '1980 - 1989'
						 WHEN yearid >= 1990 AND yearid < 2000 THEN '1990 - 1999'
						 WHEN yearid >= 2000 AND yearid < 2010 THEN '2000 - 2009'
						 WHEN yearid >= 2010 AND yearid < 2017 THEN '2010 - 2017'
					 	 END AS decade
				FROM batting
				WHERE batting.yearid>=1920
				GROUP BY decade)
--The data set below will combine the two tables above to get strikeouts per game and homeruns per game by decade
SELECT decade,
		ROUND(total_strikeouts::decimal/total_games::decimal,2) AS strikeouts_per_game,
		ROUND(total_homeruns::decimal/total_games::decimal,2) AS homeruns_per_game
FROM games_by_decade
LEFT JOIN strikeouts_and_homeruns_by_decade
USING(decade);

--6.Find the player who had the most success stealing bases in 2016, where success is measured as the percentage
--of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
--Consider only players who attempted at least 20 stolen bases.
--Answer / Chris Ownings - 91.30% success
 
WITH total_attempts_table AS (SELECT playerid, SUM(sb) AS stolen_bases, SUM(cs) AS caught_stealing
							FROM batting
							WHERE yearid = 2016
							GROUP BY playerid),
table_with_total_steal_attempts AS
							(SELECT *, stolen_bases + caught_stealing AS total_steal_attempts
							FROM total_attempts_table)

SELECT people.namefirst, people.namelast,
		ROUND(stolen_bases::decimal/total_steal_attempts::decimal*100,2) AS percent_bases_stolen
		FROM table_with_total_steal_attempts
		LEFT JOIN people
		USING (playerid)
		WHERE total_steal_attempts > 20
		ORDER BY percent_bases_stolen DESC;
		

--7a. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
--Answer / Seattle Mariners in 2001 with 116 wins
SELECT name, yearid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
GROUP BY w, name, yearid, wswin
ORDER BY w DESC;

--7b. What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually
--small number of wins for a world series champion – determine why this is the case. 
--Answer / LOS Angeles Dodgers in 1981 with 63 wins. This was due to the player strike in 1981
SELECT name, yearid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
GROUP BY w, name, yearid, wswin
ORDER BY w ASC

--7c. Then redo your query, excluding the problem year. 
--Answer / The St. Louis Cardinals in 2006 with 83 wins
SELECT name, yearid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND yearid <> 1981
AND wswin = 'Y'
GROUP BY w, name, yearid, wswin
ORDER BY w ASC

--7d. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--Answer = 26.67%
WITH ws_win_percentage AS (SELECT yearid, name, wswin,
							(CASE WHEN w = MAX(w) OVER(PARTITION BY yearid) AND wswin = 'Y' THEN 1 ELSE 0 END) AS max_wins
							FROM teams
							WHERE yearid BETWEEN 1970 AND 2016
							AND yearid <> '1981')
SELECT ROUND(SUM(max_wins)::DECIMAL / COUNT(wswin) * 100,2) AS max_win_percentage
FROM ws_win_percentage
WHERE wswin = 'Y';

--Elliot's solution
/*WITH fixed_table AS
				(SELECT yearid, name, w,
					MAX(w) OVER(PARTITION BY yearid) AS max_w_count, wswin
					FROM teams
					WHERE yearid>=1970 AND yearid<=2016
					ORDER BY yearid, w DESC),
--Same as above table with an additional column for winningest teams (over a given year)
	second_table AS
				(SELECT *, w=max_w_count AS winningest_team
				FROM fixed_table),
--List of teams by year that are either WS winner or winningest team over a season. Teams are classified based on prior criteria.
	final_table AS
				(SELECT yearid, name, w, max_w_count, wswin, winningest_team,
					CASE WHEN wswin='Y' AND winningest_team=true THEN 'WS winner with most wins'
						 WHEN wswin='Y' AND winningest_team=false THEN 'WS winner without most wins'
						 ELSE 'Team with most total wins' END AS classification
					FROM second_table
					WHERE wswin='Y'
					OR winningest_team=true)
SELECT *
FROM final_table
WHERE classification = 'Team with most total wins'
ORDER BY w DESC*/

--8a. Using the attendance figures from the home games table, find the teams and parks which had the top 5 average attendance per game in 2016
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
SELECT park_name, teams.name AS team_name, ROUND(hg.attendance::numeric / hg.games) AS avg_attendance
FROM homegames AS hg
LEFT JOIN parks
USING (park)
LEFT JOIN teams
USING (attendance)
WHERE year = 2016 AND games >= 10
ORDER BY hg.attendance/hg.games DESC
LIMIT 5

--8b. Repeat for the lowest 5 average attendance.
SELECT park_name, teams.name AS team_name, ROUND(hg.attendance::numeric / hg.games) AS avg_attendance
FROM homegames AS hg
LEFT JOIN parks
USING (park)
LEFT JOIN teams
USING (attendance)
WHERE year = 2016 AND games >= 10
ORDER BY hg.attendance/hg.games ASC
LIMIT 5

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.
-- Answer Jim Leyland with Pittsburgh Pirates 3 times 'NL' & Detroit Tigers 1 time 'AL'.
-- Davey Johnson with Baltimore Orioles 'AL' & Washington Nationals 'NL'
SELECT CONCAT(people.namefirst, ' ', people.namelast) AS fullname, teams.name, awardsmanagers.lgid, awardsmanagers.yearid, awardsmanagers.awardid
FROM awardsmanagers
LEFT JOIN people
ON awardsmanagers.playerid = people.playerid
LEFT JOIN managers
ON  managers.yearid = awardsmanagers.yearid
AND managers.playerid = awardsmanagers.playerid
LEFT JOIN teams
ON teams.teamid = managers.teamid
AND teams.yearid = managers.yearid
WHERE awardsmanagers.playerid in 
								(SELECT playerid
								  FROM awardsmanagers
								  WHERE awardid ILIKE 'TSN%'
								  AND lgid = 'AL'
								  INTERSECT
								  SELECT playerid
								  FROM awardsmanagers
								  WHERE awardid ILIKE 'TSN%'
								  AND lgid = 'NL')								  
AND awardsmanagers.awardid ILIKE 'TSN%';
								
--10. Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.
WITH homeruns_calc AS
					(SELECT DISTINCT yearid, playerid, batting.hr AS homeruns,
							MAX(batting.hr) OVER(PARTITION BY playerid) AS max_homeruns
						FROM batting
					 	FULL JOIN pitching
					 	USING(playerid, yearid)
					 	FULL JOIN fielding
					 	USING(playerid,yearid)),					
	 season_calc AS
					(SELECT *, COUNT(yearid) OVER(PARTITION BY playerid) AS num_seasons
						FROM homeruns_calc)
SELECT CONCAT(people.namefirst, ' ', people.namelast) AS full_name,season_calc.homeruns 
FROM season_calc
LEFT JOIN people
USING (playerid)
WHERE season_calc.yearid = '2016'
AND season_calc.num_seasons >= 10
AND season_calc.homeruns = season_calc.max_homeruns
AND max_homeruns > 0
ORDER BY full_name;

/*  Adam Rosales 		- 13
	Adam Wainwright 	- 2
	Angel Pagan			- 12
	Bartolo Colon		- 1
	Bobby Wilson		- 4
	Edwin Encarnacion	- 42
	Francisco Liriano	- 1
	Justin Upton		- 31
	Mike Napoli			- 34
	Rajai Davis			- 12
	Robinson Cano		- 39 */

--Open-ended questions
--1. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
--2. In this question, you will explore the connection between number of wins and attendance.
--a. Does there appear to be any correlation between attendance at home games and number of wins?
--b. Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
--3. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

