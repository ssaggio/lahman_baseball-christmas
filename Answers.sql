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

--Total games by decade,strikeouts by decade, and homeruns by decade from the 'teams' table
/*WITH games_by_decade AS 
				(SELECT SUM(g)/2 AS total_games,SUM(so) AS total_strikeouts,SUM(hr) AS total_homeruns,
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
				 GROUP BY decade)
--Calculating strikeouts and homeruns per game by decade
SELECT decade, 
	ROUND(total_strikeouts::decimal/total_games::decimal,2) AS strikeouts_per_game,
	ROUND(total_homeruns::decimal/total_games::decimal,2) AS homeruns_per_game
FROM games_by_decade
ORDER BY decade*/

--Generally both strikeouts and homeruns per game have increased over time.

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen 
--base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider 
--only players who attempted _at least_ 20 stolen bases.

--Stolen bases and caught stealing numbers grouped to playerid for all players in 2016.
/*WITH total_attempts_table AS 
								(SELECT playerid,SUM(sb) AS stolen_bases,SUM(cs) AS caught_stealing
								FROM batting
								WHERE yearid=2016
								GROUP BY playerid),
--Table from above with additional total steal attempts column.
	table_with_total_steal_attempts AS 
								(SELECT *,stolen_bases+caught_stealing AS total_steal_attempts
								FROM total_attempts_table)
--First name, last name, and percent bases stolen for players with 20 or more attempts.							
SELECT people.namefirst,people.namelast,
	ROUND(stolen_bases::decimal/total_steal_attempts::decimal*100,2) AS percent_bases_stolen
FROM table_with_total_steal_attempts
LEFT JOIN people
USING(playerid)
WHERE total_steal_attempts>=20
ORDER BY percent_bases_stolen DESC*/

--Chris Owings

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest 
--number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins 
--for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 
--1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--Teams grouped by year with a column showing max win count for a given year 
/*WITH fixed_table AS
				(SELECT yearid,name,w,
					MAX(w) OVER(PARTITION BY yearid) AS max_w_count,
					wswin
				FROM teams
				WHERE yearid>=1970 AND yearid<=2016
				ORDER BY yearid,w DESC),
--Same as above table with an additional column for winningest teams (over a given year) 
	second_table AS
				(SELECT *,w=max_w_count AS winningest_team
				FROM fixed_table),
--List of teams by year that are either WS winner or winningest team over a season. Teams are classified based on prior criteria. 
	final_table AS 
				(SELECT yearid,name,w,max_w_count,wswin,winningest_team,
				CASE WHEN wswin='Y' AND winningest_team=true THEN 'WS winner with most wins'
					 WHEN wswin='Y' AND winningest_team=false THEN 'WS winner without most wins'
					 ELSE 'Team with most total wins' END AS classification
				FROM second_table
				WHERE wswin='Y' 
				OR winningest_team=true)*/				
--Code for winningest team without WS
/*SELECT* 
FROM final_table
WHERE classification='Team with most total wins'
ORDER BY w DESC*/
--Code for WS winner with lowest # of wins
/*SELECT*
FROM final_table
WHERE wswin='Y'
ORDER BY w*/
--WS winner with lowest # of wins, excluding 1981
/*SELECT*
FROM final_table
WHERE wswin='Y'
AND yearid<>1981
ORDER BY w*/
--Number of years covered by table
/*SELECT COUNT(yearid)
FROM final_table
WHERE wswin='Y'*/
--46 years
--Number of years WS winner also had most wins
/*SELECT COUNT(yearid)
FROM final_table
WHERE classification='WS winner with most wins'*/
--12 years
--12/46= 26%

--116 (largest # of wins for team that didn't win WS)
--63 (smallest # of wins for team that won WS)
--1981 featured a player's strike causing the season to be shorter.
--83 (smallest # of wins for team that won WS, excluding 1981)
--26% (% of the time WS winner is also winningest team)

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 
--2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at 
--least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Parks with team name and avergage attendance 
/*SELECT parks.park_name,fixed_teams.name AS team_name,ROUND(homegames.attendance::decimal/homegames.games::decimal,0) AS avg_attendance
FROM homegames
LEFT JOIN parks
USING(park)
LEFT JOIN 
--Tidying up teams table before joining- filtering to only 2016 prevents duplicates with team names
	(SELECT DISTINCT teamid,name 
	 FROM teams
	 WHERE yearid='2016') 
	 AS fixed_teams
ON(homegames.team=fixed_teams.teamid)
WHERE year='2016'
AND games>='10'
ORDER BY avg_attendance DESC*/

--Top 5 avg attendance
--"Dodger Stadium"	"Los Angeles Dodgers"	45720
--"Busch Stadium III"	"St. Louis Cardinals"	42525
--"Rogers Centre"	"Toronto Blue Jays"	41878
--"AT&T Park"	"San Francisco Giants"	41546
--"Wrigley Field"	"Chicago Cubs"	39906

--Bottom 5 avg attendance
--"Tropicana Field"	"Tampa Bay Rays"	15879
--"Oakland-Alameda County Coliseum"	"Oakland Athletics"	18784
--"Progressive Field"	"Cleveland Indians"	19650
--"Marlins Park"	"Miami Marlins"	21405
--"U.S. Cellular Field"	"Chicago White Sox"	21559

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.

/*WITH count_of_leagues AS
--Manager ids for managers winning TSN award after 1985 with a count of the number of distinct leagues they have won the award in
				(SELECT playerid,COUNT(DISTINCT lgid)
				FROM awardsmanagers
				WHERE awardid='TSN Manager of the Year'
				AND yearid>='1986'
				GROUP BY playerid),
	list_of_managers AS
--List of managers who have won TSN award in both the National and American league
				(SELECT *
				FROM count_of_leagues
				WHERE count>1),
--Awardsmanagers table with only TSN awards after 1985 shown
	nice_table AS 
				(SELECT*
				FROM awardsmanagers
				WHERE awardid='TSN Manager of the Year'
				AND yearid>='1986')
--For two coaches described above, every year they won an award and the team they did it with, organized by year descending
SELECT nice_table.yearid AS year,people.namefirst AS first_name,people.namelast AS last_name,teams.name AS team_name
FROM list_of_managers
LEFT JOIN nice_table
USING(playerid)
LEFT JOIN people
USING(playerid)
LEFT JOIN managers
USING(playerid,yearid)
LEFT JOIN teams
USING(teamid,yearid)
ORDER BY yearid*/

--Jim Leyland and Davey Johnson
--1988	"Jim"	"Leyland"	"Pittsburgh Pirates"
--1990	"Jim"	"Leyland"	"Pittsburgh Pirates"
--1992	"Jim"	"Leyland"	"Pittsburgh Pirates"
--1997	"Davey"	"Johnson"	"Baltimore Orioles"
--2006	"Jim"	"Leyland"	"Detroit Tigers"
--2012	"Davey"	"Johnson"	"Washington Nationals"

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league 
--for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home 
--runs they hit in 2016.

--Player id with homeruns in a year and maximum career homeruns, using data from the batting, pitching, and fielding tables
/*WITH homeruns_table AS
				(SELECT DISTINCT yearid,playerid,batting.hr AS homeruns,
					MAX(batting.hr) OVER(PARTITION BY playerid) AS max_homeruns
				FROM batting
				FULL JOIN pitching
				USING(playerid,yearid)
				FULL JOIN fielding
				USING(playerid,yearid)),
	final_table AS
--Player id with homeruns in a year, max career homeruns, and number of seasons on career
				(SELECT *,
					COUNT(yearid) OVER(PARTITION BY playerid) AS num_seasons
				FROM homeruns_table)
--Players with 10+ seasons played with their career high homeruns in 2016.
SELECT people.namefirst,people.namelast,final_table.homeruns
FROM final_table
LEFT JOIN people
USING(playerid)
WHERE final_table.yearid='2016'
AND final_table.num_seasons>=10
AND final_table.homeruns=final_table.max_homeruns
AND max_homeruns>0
ORDER BY people.namelast*/

--"Robinson"	"Cano"		39
--"Bartolo"	"Colon"			1
--"Rajai"	"Davis"			12
--"Edwin"	"Encarnacion"	42
--"Francisco"	"Liriano"	1
--"Mike"	"Napoli"		34
--"Angel"	"Pagan"			12
--"Adam"	"Rosales"		13
--"Justin"	"Upton"			31
--"Adam"	"Wainwright"	2
--"Bobby"	"Wilson"		4


--BONUS QUESTIONS--

--1. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do 
--this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year 
--basis.

SELECT*
FROM salaries
