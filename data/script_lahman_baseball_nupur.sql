select *
from allstarfull;
--1. What range of years for baseball games played does the provided database cover?
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM batting;

--2. Find the name and height of the shortest player in the database.
--How many games did he play in? What is the name of the team for which he played?

SELECT namefirst AS name, height
FROM people
ORDER BY height ASC
LIMIT 1;
select *
FROM teams;




SELECT g AS games_played, g_all As Total_games_played
FROM teams
INNER JOIN Appearances USING(yearid)
INNER JOIN people USING(playerid)
WHERE namefirst = 'Eddie';

SELECT p.namefirst,p.namelast, p.height, ap.g_all, t.name
   FROM people AS p INNER JOIN appearances AS ap USING(playerid)
                    INNER JOIN teams AS t USING(teamid)
   WHERE height = (SELECT MIN(height)
				   FROM people)
   GROUP BY p.namefirst,p.namelast, p.height, t.name, ap.g_all

3.--Find all players in the database who played at Vanderbilt University.
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT *
FROM Players
WHERE university = 'Vanderbilt University';

SELECT p.namefirst, p.namelast, sc.schoolname,  SUM(s.salary::numeric)::money AS tot_salary
FROM people as p INNER JOIN salaries AS s USING(playerid )
                 INNER JOIN collegeplaying AS cp USING(playerid)
				 INNER JOIN schools AS sc USING(schoolid)
WHERE sc.schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast, sc.schoolname
ORDER BY tot_salary DESC
--4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
CASE 
   WHEN pos = 'OF' THEN 'outfield'
   WHEN pos IN ('SS','1B','2B','3B') THEN 'infield'
   WHEN pos IN ('P','C') THEN 'Battery'
   END AS position, 
   SUM(po) AS total_putouts
FROM fielding
WHERE yearid= '2016'
GROUP BY position







