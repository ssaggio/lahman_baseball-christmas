--1. What range of years for baseball games played does the provided database cover?

--List of distinct years from the teams table
/*SELECT DISTINCT yearid
FROM teams
ORDER BY yearid;*/

--1871 to 2016

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team 
--for which he played?

--List of players with playerid, name, height, teamid, and number of games played listed in height order
/*SELECT people.playerid,people.namegiven,people.height,appearances.teamid,appearances.g_all
FROM people
LEFT JOIN appearances
ON people.playerid=appearances.playerid
ORDER BY people.height,people.playerid,appearances.yearid*/

--Team name for teamid 'SLA'
/*SELECT DISTINCT teamid,name
FROM teams
WHERE teamid='SLA'*/

--Edward Carl
--43 inches 
--Played in 1 game
--St. Louis Browns

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last 
--names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary 
--earned. Which Vanderbilt player earned the most money in the majors?

--List of MLB players who played at Vanderbuilt with playerid, first name, last name, and total salary listed by order of salary.
/*SELECT DISTINCT playerid,namefirst,namelast,
	SUM(salary) OVER(PARTITION BY playerid) AS player_total_salary
FROM collegeplaying
LEFT JOIN people
USING(playerid)
LEFT JOIN salaries
USING(playerid)
WHERE schoolid='vandy'
ORDER BY player_total_salary DESC*/

--David Price

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as 
--"Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016.

--Total number of putouts for players in 'battery','infield', and 'outfield' during the 2016 season.
/*SELECT SUM(po) AS total_number_of_putouts,
	CASE WHEN pos='OF' THEN 'Outfield'
		WHEN pos='SS' OR pos='1B' OR pos='2B' OR pos='3B' THEN 'Infield'
		WHEN pos='P' OR pos='C' THEN 'Battery' END AS position_group
FROM fielding
WHERE yearid='2016'
GROUP BY position_group*/

--Battery 41424
--Infield 58934
--Outfield 29560

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game. Do you see any trends?


WITH games_by_decade AS 
				(SELECT SUM(g)/2 AS total_games,
				 	CASE WHEN yearid >=1920 AND yearid <1930 THEN '1920s'
						WHEN yearid >=1930 AND yearid <1940 THEN '1930s'
						WHEN yearid >=1940 AND yearid <1950 THEN '1940s'
						WHEN yearid >=1950 AND yearid <1960 THEN '1950s'
						WHEN yearid >=1960 AND yearid <1970 THEN '1960s'
						WHEN yearid >=1970 AND yearid <1980 THEN '1970s'
						WHEN yearid >=1980 AND yearid <1990 THEN '1980s'
						WHEN yearid >=1990 AND yearid <2000 THEN '1990s'
						WHEN yearid >=2000 AND yearid <2010 THEN '2000s'
						WHEN yearid >=2010 AND yearid <2020 THEN '2010s'
						END AS decade
				 FROM teams
				 WHERE yearid>=1920
				 GROUP BY decade),
strikeouts_and_homeruns_by_decade AS 
				(SELECT SUM(so) AS total_strikeouts, SUM(hr) AS total_homeruns,
					CASE WHEN yearid >=1920 AND yearid <1930 THEN '1920s'
						WHEN yearid >=1930 AND yearid <1940 THEN '1930s'
						WHEN yearid >=1940 AND yearid <1950 THEN '1940s'
						WHEN yearid >=1950 AND yearid <1960 THEN '1950s'
						WHEN yearid >=1960 AND yearid <1970 THEN '1960s'
						WHEN yearid >=1970 AND yearid <1980 THEN '1970s'
						WHEN yearid >=1980 AND yearid <1990 THEN '1980s'
						WHEN yearid >=1990 AND yearid <2000 THEN '1990s'
						WHEN yearid >=2000 AND yearid <2010 THEN '2000s'
						WHEN yearid >=2010 AND yearid <2020 THEN '2010s'
						END AS decade
				FROM batting
				WHERE batting.yearid>=1920
				GROUP BY decade)
SELECT decade, 
	ROUND(total_strikeouts::decimal/total_games::decimal,2) AS strikeouts_per_game,
	ROUND(total_homeruns::decimal/total_games::decimal,2) AS homeruns_per_game
FROM games_by_decade
LEFT JOIN strikeouts_and_homeruns_by_decade
USING(decade)


