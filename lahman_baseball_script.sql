--1. What range of years for baseball games played does the provided database cover? 1871-2016

SELECT DISTINCT (yearid)
FROM teams;

--2. Find the name and height of the shortest player in the database. Eddie Gaedel, Height 43. 
----How many games did he play in? 1
----What is the name of the team for which he played? 
   
SELECT playerid, namefirst, namelast, height
FROM people
ORDER BY height
LIMIT 1;

SELECT playerid, g_all
FROM appearances
WHERE playerid IN (SELECT playerid
				   FROM people
				   ORDER BY height
				   LIMIT 1);

   
   SELECT p.playerid, p.namefirst, p.namelast, p.height, a.g_all, a.teamid, t.name
   FROM people AS p INNER JOIN appearances AS a USING (playerid)
   					INNER JOIN teams AS t USING (teamid)
   GROUP BY p.playerid, a.g_all, a.teamid, t.name
   ORDER BY p.height
   LIMIT 1;
  
   

--3. Find all players in the database who played at Vanderbilt University. 
----Create a list showing each player’s first and last names as well as the total salary they 
----earned in the major leagues. Sort this list in descending order by the total salary earned. 
----Which Vanderbilt player earned the most money in the majors?
	
	SELECT cp.playerid, p.namefirst, p.namelast, SUM(S.salary) AS total_salary
	FROM collegeplaying AS cp LEFT JOIN people AS p USING (playerid)
							  LEFT JOIN salaries AS s USING (playerid)
	WHERE cp.schoolid = 'vandy'
	GROUP BY cp.playerid, p.namefirst, p.namelast
	ORDER BY total_salary DESC NULLS LAST;
	

	

--4. Using the fielding table, group players into three groups based on their position: 
----label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
----and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these 
----three groups in 2016. 


SELECT SUM(po) AS sum_putouts, CASE WHEN pos = 'OF' THEN 'Outfield'
			   						WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			   						WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
			   						END AS position_group
FROM fielding
GROUP BY position_group;


--5. Find the average number of strikeouts per game by decade since 1920. 
----Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   
SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
			WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
			END AS decade,
			ROUND(AVG(so), 2) AS avg_strikeouts,
			ROUND(AVG(hr), 2) AS avg_homeruns
FROM pitching
WHERE yearid BETWEEN 1920 AND 2019
GROUP BY decade
ORDER BY decade;



--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured
----as the percentage of stolen base attempts which are successful. 
----(A stolen base attempt results either in a stolen base or being caught stealing.) 
----Consider only players who attempted _at least_ 20 stolen bases.


WITH bases AS (SELECT playerid, namefirst, namelast, SB, CS, (SB + CS) AS base_attempt
			   FROM batting LEFT JOIN people USING (playerid)
			   WHERE yearid = 2016 AND (SB + CS) >= 20
			   GROUP BY playerid, SB, CS, namefirst, namelast)

SELECT *, (ROUND((sb::decimal/base_attempt::decimal)*100, 2)) || '%' AS percent_success
FROM bases
ORDER BY percent_success DESC
LIMIT 1;


--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 2001 Sea Mariners

SELECT yearid, teamid, w, name
FROM teams
WHERE (yearid BETWEEN 1970 and 2016) AND wswin = 'N'
GROUP BY yearid, teamid, w, name
ORDER BY w DESC;

----What is the smallest number of wins for a team that did win the world series? 

SELECT yearid, teamid, w, name
FROM teams
WHERE (yearid BETWEEN 1970 and 2016) AND wswin = 'Y'
GROUP BY yearid, teamid, w, name
ORDER BY w;

----Doing this will probably result in an unusually small number of wins for a world series champion – determine why 
----this is the case. Baseball Strike Then redo your query, excluding the problem year. 

SELECT yearid, teamid, w, name
FROM teams
WHERE (yearid BETWEEN 1970 and 2016) AND wswin = 'Y' AND yearid <> 1981
GROUP BY yearid, teamid, w, name
ORDER BY w;

----How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
----What percentage of the time?

SELECT yearid, name, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid, name, w
ORDER BY name



--8. Using the attendance figures from the homegames table, find the teams and parks which had the 
----top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided
----by number of games). Only consider parks where there were at least 10 games played. 
----Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


