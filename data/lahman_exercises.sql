--			LAHMAN questions
--question 1 - what range of years for baseball games played does the db cover?

--SELECT DISTINCT(yearid)
--FROM teams

-- question 2 - find the name & height of the shortest player in the db. How many games did he play in?
--			what is the name of the team for which he played?

--SELECT namefirst, namelast, p.playerid, height, app.g_all AS games_played, t.name AS team
--FROM people as p JOIN appearances as app
--ON p.playerid = app.playerid LEFT JOIN teams AS t
--ON app.teamid = t.teamid
--GROUP BY p.namefirst, p.namelast, p.playerid, app.g_all, t.name
--ORDER BY MIN(height)
--LIMIT 1

-- question 3 - id all players in db who played at vandy; create list with first, lastname as well as 
--  	total salary. Sort list in desc order by total salary

--SELECT DISTINCT cp.playerid, schoolid, namefirst, namelast, SUM(salary) AS total_salary
--FROM collegeplaying AS cp LEFT JOIN people AS p
--ON cp.playerid = p.playerid JOIN salaries AS s
--ON cp.playerid = s.playerid
--WHERE schoolid = 'vandy'
--GROUP BY namefirst, namelast, cp.playerid, schoolid
--ORDER BY SUM(salary) DESC

-- David Price at $245,553,888

-- question 4 - using the fielding table, gropu players based on their position: OF for 'Outfield',
--		'Infield' and pitcher/catcher as 'Battery'; determine number of putouts made by each group
--		in 2016

--SELECT SUM(po) AS total_putouts,
--		CASE WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
--			 WHEN pos IN ('P', 'C') THEN 'Battery'
--			 ELSE 'Outfield' END as position_group
--FROM fielding
--WHERE yearid = '2016'
--GROUP By position_group

--Battery = 41424
--Infield = 58934
--Outfield = 29560

-- question 5 - find avg number of strikeouts per decade since 1920; round to 2 significant digits;
--			do same for homeruns per game. any trends?

--SELECT ROUND((SUM(so::decimal)/SUM(g)), 2) AS strikeout_per_game, 
--	   ROUND((SUM(hr::decimal)/SUM(g)),2) AS homerun_per_game,
--	   CONCAT(LEFT(CAST((yearid) AS VARCHAR(4)), 3), '0s') AS decade
--FROM teams
--WHERE yearid > 1919
--GROUP BY decade, LEFT(CAST((yearid) AS VARCHAR(4)), 3)
--ORDER BY decade

-- question 6 - find the player who had the most success stealing basesin 2016, where "success" is
--		measured as the percentage of stolen base attempts which are successful. consider players
--		with at least 20 attempts

SELECT playerid, sb, cs, yearid
FROM batting
WHERE yearid = 2016


