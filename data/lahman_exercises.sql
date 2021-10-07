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

/*SELECT ROUND((SUM(so::decimal)/SUM(g/2)), 2) AS strikeout_per_game, 
	   ROUND((SUM(hr::decimal)/SUM(g/2)),2) AS homerun_per_game,
	   CONCAT(LEFT(CAST((yearid) AS VARCHAR(4)), 3), '0s') AS decade
FROM teams
WHERE yearid > 1919
GROUP BY decade, LEFT(CAST((yearid) AS VARCHAR(4)), 3)
ORDER BY decade*/

-- question 6 - find the player who had the most success stealing basesin 2016, where "success" is
--		measured as the percentage of stolen base attempts which are successful. consider players
--		with at least 20 attempts


/*WITH total_attempts_table AS
		(SELECT playerid, SUM(sb) AS stolen_bases, SUM(cs) AS caught_stealing
		 FROM batting
		 WHERE yearid = 2016
		 GROUP BY playerid),
	 total_sb_attempts AS
	 	(SELECT *, stolen_bases + caught_stealing AS total_sb_attempts
		 FROM total_attempts_table)

SELECT people.namefirst, people.namelast,
	   ROUND(stolen_bases::decimal / total_sb_attempts::decimal * 100, 2) AS successful_sb_percentage
FROM total_sb_attempts LEFT JOIN people
	USING(playerid)
WHERE total_sb_attempts >= 10
ORDER BY successful_sb_percentage DESC*/
		
--Answer Chris Owings with success rate of 91.30%

-- question 7 - from 1970 to 2016, what is the largest number of wins for a team that did not win the
-- 			world series?  What is the smallest number of wins for a team that did win the world
--			series?  the answer is unusually small. Exclude that year in calculations. redo query
--			What was the percentage where the team with most wins also won the series?


--SELECT yearid, teamid, MAX(w), wswin
--FROM teams
--WHERE yearid >= 1970 AND wswin <> 'Y'
--GROUP BY yearid, teamid, wswin
--ORDER BY MAX(w) DESC
--LIMIT 5;

--Answer to 7A - largest wins w/o ws win - 2001 Seattle Mariners with 116 wins

--SELECT yearid, teamid, MAX(w), wswin
--FROM teams
--WHERE yearid >= 1970 AND yearid <> '1981' AND wswin = 'Y'
--GROUP BY yearid, teamid, wswin
---ORDER BY MAX(w)
--LIMIT 5

-- Answer to 7B - removed strike year of 1981(LA Dodgers) - fewest wins with ws win - 2006 St.Louis 
--					Cardinals with 83 wins

--With percentage_maxwins_and_wswins AS (SELECT yearid, name, wswin,
--									  (CASE WHEN w = MAX(w) OVER(PARTITION BY yearid)AND wswin = 'Y'
--									   THEN 1 ELSE 0 END) AS max_wins
--									   FROM teams
--									   WHERE yearid >= 1970)
--SELECT ROUND(SUM(max_wins)::DECIMAL / COUNT(wswin) * 100,2)
--			  AS percentage_maxwins_and_wswins
--FROM percentage_maxwins_and_wswins
--WHERE wswin = 'Y'

-- Answer to 7C - 26.09 percent

--SELECT yearid, teamid, MAX(w), wswin
--FROM teams
--WHERE yearid >= 1970 AND wswin = 'Y'
--GROUP BY yearid, teamid, wswin
--HAVING percentage_maxwins_and_wswins
--ORDER BY MAX(w) DESC


-- question 8 - using attendance figures from homegames table, find teams and parks which had top 5
--			average attendance in 2016 (where avg attendance is total attendance divided by number
--			of games). Only consider parks where at least 10 games have been played. report park name,
--			team name, and avg attendance.  repeat for lowest 5 avg attendance

--SELECT team, p.park_name, SUM(attendance / games) AS avg_attendance
--FROM homegames AS hg JOIN parks AS p ON hg.park = p.park
--WHERE year = 2016 AND games >= 10
--GROUP BY hg.team, p.park_name, hg.attendance
--ORDER BY SUM(attendance / games)
--LIMIT 5

--TOP 5 are:
--LA Dodger 				Dodger Stadium			45,719
--St. Louis Cardinals		Busch Stadium III		42,524
--Toronto BlueJays			Rogers Centre			41,877
--San Francisco Giants		AT&T Park				41,546
--Chicago White Sox			Wrigley Field			39,906

--Bottom 5 are:
--Tampa Bay Rays		Tropicana Field						15,878
--Oakland A's			Oakland-Alameda County Coliseum		18,784
--Cleveland Indians		Progressive Field					19,650
--Florida Marlins		Marlins Park						21,405
--Chicago Cubs			U.S. Cellular Field					21,559

-- question 9 - Which managers have won the TSN Manager of the Year award in both the NL and AL?  give
--			their full names and teams they managed when winning award

--SELECT p.namefirst, p.namelast, t.name AS team_name, am.awardid,  
--		am.yearid, am2.yearid AS DUP_yearid, 
--		am.lgid, am2.lgid AS DUP_lgid 
--FROM awardsmanagers AS am INNER JOIN awardsmanagers AS am2
--	USING (playerid) JOIN managers as m
--	ON am.playerid = m.playerid AND am.yearid = m.yearid JOIN teams AS t
--	ON m.teamid = t.teamid AND m.yearid = t.yearid JOIN people as p
--	ON  am.playerid = p.playerid 
--WHERE am.awardid = 'TSN Manager of the Year' AND am2.awardid = 'TSN Manager of the Year'
--		AND am.lgid = 'NL' AND am2.lgid = 'AL'

-- answer two managers and four times Jim Leyland and Davey Johnson


-- question 10 - find all players who hit their career highest hrs in 2016. consider only players
--			who have played in the league for at least 10 years, and who hit at least 1 hr in 2016.
--			report the players first & last name and the number of hrs they hit in 2016

SELECT playerid, namefirst, namelast, yearid, hr, AS 2016_hr,
		MAX(hr) OVER(PARTITION BY playerid, yearid) AS max_hr
		
FROM batting AS b JOIN people AS p
USING (playerid)
--WHERE yearid = '2016' AND hr >= 1

WITH hr_2016 AS (SELECT yearid, playerid, SUM(hr) AS hr_2016
				FROM batting
				WHERE yearid = '2016'
				GROUP BY yearid, playerid)

SELECT playerid, batting.yearid, hr, hr_2016, debut
FROM batting join hr_2016 USING (playerid) JOIN people USING (playerid)
WHERE hr = hr_2016 AND hr >= 1 AND debut::date <= '2006-01-01'
--HAVING MAX(hr) = SUM(hr_2016) AND SUM(hr_2016) >= 1
