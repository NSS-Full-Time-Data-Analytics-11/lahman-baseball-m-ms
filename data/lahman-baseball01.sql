/*1. What range of years for baseball games played does the provided database cover?*/

SELECT MIN(yearid) AS most_distant_yr,
	   MAX(yearid) AS most_recent_yr
FROM batting;

/*2. Find the name and height of the shortest player in the database. 
How many games did he play in? What is the name of the team for which he played?*/

SELECT CONCAT(namefirst,' ',namelast) AS full_name,
	   AVG(height),
	   ROUND(AVG(a.G_all),2) AS games_played,
	   t.name AS team_name
FROM people
INNER JOIN appearances AS a
ON people.playerid=a.playerid
INNER JOIN teams AS t
ON a.teamid=t.teamid
GROUP BY full_name, team_name
ORDER BY AVG(height) ASC;

/*3. Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors?*/

SELECT CONCAT(namefirst,' ',namelast) AS full_name,
	   SUM(salary)::numeric::money AS total_salary,
	   schoolname
FROM people
INNER JOIN collegeplaying
USING(playerid)
INNER JOIN schools
USING(schoolid)
INNER JOIN salaries
USING(playerid)
WHERE schoolname ILIKE 'Vanderbilt%'
GROUP BY full_name, schoolname
ORDER BY total_salary DESC;

/*4. Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/

SELECT CASE WHEN f.pos IN ('OF') THEN 'Outfield'
			WHEN f.pos IN ('SS','1B','2B','3B') THEN 'Infield'
			WHEN f.pos IN ('P','C') THEN 'Battery'
			END AS position_name,
			SUM(f.po) AS total_putouts,
			COUNT(*) AS total_players
FROM fielding AS f
INNER JOIN people AS pe
USING(playerid)
WHERE yearid = 2016
GROUP BY position_name
ORDER BY SUM(f.po);

/*5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?*/

SELECT *
FROM	(SELECT ROUND(AVG(pi.so/pi.g),2) AS avg_so_pergame,
			   CASE WHEN pi.yearid BETWEEN 1920 AND 1929 THEN '1920s'
					WHEN pi.yearid BETWEEN 1930 AND 1939 THEN '1930s'
					WHEN pi.yearid BETWEEN 1940 AND 1949 THEN '1940s'
					WHEN pi.yearid BETWEEN 1950 AND 1959 THEN '1950s'
					WHEN pi.yearid BETWEEN 1960 AND 1969 THEN '1960s'
					WHEN pi.yearid BETWEEN 1970 AND 1979 THEN '1970s'
					WHEN pi.yearid BETWEEN 1980 AND 1989 THEN '1980s'
					WHEN pi.yearid BETWEEN 1990 AND 1999 THEN '1990s'
					WHEN pi.yearid BETWEEN 2000 AND 2009 THEN '2000s'
					WHEN pi.yearid BETWEEN 2010 AND 2019 THEN '2010s'
					END AS decade			
		FROM pitching AS pi
		WHERE pi.yearid>=1920
		GROUP BY decade
		ORDER BY decade ASC) AS pitch_avg
FULL JOIN 
		(SELECT ROUND(AVG(ba.so/ba.g),2) AS avg_hr_pergame,
			   CASE WHEN ba.yearid BETWEEN 1920 AND 1929 THEN '1920s'
					WHEN ba.yearid BETWEEN 1930 AND 1939 THEN '1930s'
					WHEN ba.yearid BETWEEN 1940 AND 1949 THEN '1940s'
					WHEN ba.yearid BETWEEN 1950 AND 1959 THEN '1950s'
					WHEN ba.yearid BETWEEN 1960 AND 1969 THEN '1960s'
					WHEN ba.yearid BETWEEN 1970 AND 1979 THEN '1970s'
					WHEN ba.yearid BETWEEN 1980 AND 1989 THEN '1980s'
					WHEN ba.yearid BETWEEN 1990 AND 1999 THEN '1990s'
					WHEN ba.yearid BETWEEN 2000 AND 2009 THEN '2000s'
					WHEN ba.yearid BETWEEN 2010 AND 2019 THEN '2010s'
					END AS decade			
		FROM batting AS ba
		WHERE ba.yearid>=1920
		GROUP BY decade
		ORDER BY decade ASC) AS hr_avg
USING(decade);

/* 6. Find the player who had the most success stealing bases in 2016, where __success__ 
is measured as the percentage of stolen base attempts which are successful.
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases. */

SELECT CONCAT(namefirst,' ',namelast) AS full_name,
	   batting.sb AS stolen_bases,
	   batting.cs AS failed_stolen,
	   batting.cs+batting.sb AS total_attempts,
	   CASE WHEN batting.sb>0 AND batting.cs=0 THEN 100
	   		WHEN batting.sb>0 AND batting.cs>0 THEN ROUND(((batting.sb::decimal)/(batting.sb::decimal+batting.cs::decimal))*100,2)
			WHEN batting.sb=0 AND batting.cs=0 THEN 0
			ELSE 0
	   	    END AS percent_stolen
FROM batting
INNER JOIN people
USING(playerid)
WHERE yearid=2016 AND (batting.cs+batting.sb)>=20
ORDER BY percent_stolen DESC, total_attempts DESC;

/*7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion
– determine why this is the case. 
Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time? */

--2006 SLN w/ 83 wins Yes ws win
SELECT yearid,
	   teamid,
	   wswin,
	   w,
	   ROUND(w::decimal/(w::decimal+l::decimal)*100,2) AS win_perc
FROM teams
WHERE wswin='Y' AND yearid BETWEEN 1970 AND 2016
ORDER BY win_perc ASC
LIMIT 1;

--2001 SEA w/ 116 wins No ws win
SELECT yearid,
	   teamid,
	   w,
	   wswin,
	   ROUND(w::decimal/(w::decimal+l::decimal)*100,2) AS win_perc
FROM teams
WHERE wswin='N' AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC
LIMIT 1;

--most wins and ws win: NYA 1998

SELECT yearid,
	   teamid,
	   wswin,
	   w
FROM teams
WHERE wswin='Y' AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC
LIMIT 1;

--most wins by a team each year

SELECT yearid,
	   MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid
ORDER BY yearid ASC;

--matching teamid to maxwins and ws win status

SELECT teamid,
	   most_wins.yearid,
	   wswin,
	   w,
	   wins
FROM (SELECT yearid,
	   		 MAX(w) AS wins
	  FROM teams
	  WHERE yearid BETWEEN 1970 AND 2016
	  GROUP BY yearid
	  ORDER BY yearid ASC) AS most_wins
JOIN teams
ON teams.w=most_wins.wins AND teams.yearid=most_wins.yearid
ORDER BY yearid ASC;

--using prior query as CTE to calc % of Y in ws win

WITH ws_wins AS (SELECT teamid,
					   most_wins.yearid,
					   wswin,
					   w,
					   wins,
				 	   CASE WHEN wswin='Y' THEN 1
							WHEN wswin='N' THEN 0
							END AS wswin01
				 FROM (SELECT yearid,
							 MAX(w) AS wins
					  FROM teams
					  WHERE yearid BETWEEN 1970 AND 2016
					  GROUP BY yearid
					  ORDER BY yearid ASC) AS most_wins
				 JOIN teams
				 ON teams.w=most_wins.wins AND teams.yearid=most_wins.yearid
				 ORDER BY yearid ASC)

SELECT ROUND(SUM((wswin01::decimal)/46)*100,3) AS most_wins_and_ws_win,
	   ROUND((100-SUM(((wswin01::decimal)/46)*100)),3) AS perc_loser
FROM ws_wins;

/* 8. Using the attendance figures from the homegames table, 
find the teams and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. 
Repeat for the lowest 5 average attendance. */

--Top attendance (limit 7 shows 5 distinct parks)
SELECT h.park, 
	   teams.name,
	   SUM(games) AS tot_games,
	   SUM(h.attendance) AS tot_att,
	   SUM(h.attendance)/SUM(games) AS att_per_game
FROM homegames AS h
LEFT JOIN teams 
ON teams.teamid=h.team
WHERE year=2016
GROUP BY h.park, teams.name
HAVING SUM(games)>=10
ORDER BY att_per_game DESC
LIMIT 7;

--Worst attendance (Limit 9 shows 5 distinct parks)
SELECT h.park, 
	   teams.name,
	   SUM(games) AS tot_games,
	   SUM(h.attendance) AS tot_att,
	   SUM(h.attendance)/SUM(games) AS att_per_game
FROM homegames AS h
LEFT JOIN teams 
ON teams.teamid=h.team
WHERE h.year=2016
GROUP BY h.park, teams.name
HAVING SUM(games)>=10
ORDER BY att_per_game ASC
LIMIT 9;	  

/* 9. Which managers have won the TSN Manager of the Year award 
in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when 
they won the award. */


-- Subquery in WHERE clause finds any managers in aw that have >0 TSN MotY awards in both the NL and AL. Larger query serves to pull name and team info
SELECT CONCAT(p.namefirst,' ',p.namelast) AS full_name,
	   aw.lgid,
	   aw.yearid,
	   t.name,
	   aw.awardid,
	   aw.lgid      
FROM awardsmanagers	AS aw
LEFT JOIN managers AS m
	ON m.playerid=aw.playerid AND m.yearid=aw.yearid
LEFT JOIN people AS p
	ON p.playerid=aw.playerid
LEFT JOIN teams AS t
	ON t.teamid=m.teamid AND t.yearid=aw.yearid
WHERE  m.playerid IN   (SELECT playerid	
						FROM awardsmanagers
						GROUP BY playerid
						HAVING SUM(CASE WHEN awardid='TSN Manager of the Year' AND lgid='NL' THEN 1
										ELSE 0
									END)>0
								AND
								SUM(CASE WHEN awardid='TSN Manager of the Year' AND lgid='AL' THEN 1
										 ELSE 0
									END)>0)
	   AND awardid LIKE 'TSN%';
	   
	   
/* 10. Find all players who hit their career highest number of home runs in 2016. 
Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
Report the players' first and last names and the number of home runs they hit in 2016. */
	   
WITH sixteen_hr AS 	(SELECT playerid,
						   hr AS sixteen_szn_hr
					 FROM batting
					 WHERE yearid=2016 AND playerid IN (SELECT playerid
														FROM batting
														WHERE yearid<=2006)
										AND hr>0
					 ORDER BY hr DESC),


     career_hr AS   (SELECT MAX(hr) AS career_high_hr,
						   playerid
					 FROM batting
					 WHERE playerid IN (SELECT playerid
														FROM batting
														WHERE yearid<=2006)
									AND yearid BETWEEN 2006 AND 2016
					 GROUP BY playerid
					 ORDER BY career_high_hr DESC)

SELECT CONCAT(p.namefirst,' ',p.namelast) AS full_name,
	   sixteen_szn_hr,
	   career_high_hr
FROM sixteen_hr AS shr
INNER JOIN career_hr AS chr
ON shr.playerid=chr.playerid AND shr.sixteen_szn_hr=chr.career_high_hr
INNER JOIN people AS p
ON p.playerid=shr.playerid


SELECT * FROM batting
WHERE playerid='uptonju01'



/* 11. Is there any correlation between number of wins and team salary? 
Use data from 2000 and later to answer this question. As you do this analysis, 
keep in mind that salaries across the whole league tend to increase together, 
so you may want to look on a year-by-year basis. */

WITH wins_perszn AS	   (SELECT teams.yearid,
							   teams.teamid,
							   SUM(w) AS total_wins
						FROM teams
						GROUP BY teams.yearid, teams.teamid
						ORDER BY teams.yearid DESC, teams.teamid ASC),
						
						
	sal_perszn	 AS	   (SELECT SUM(salary) AS tot_sal,
								yearid,
								teamid

						FROM salaries

						GROUP BY yearid, teamid
						ORDER BY yearid DESC, teamid ASC),

       
	combined AS		   (SELECT wins_perszn.yearid,
							   wins_perszn.teamid,
							   sal_perszn.tot_sal AS total_salary,
							   wins_perszn.total_wins AS wins
						FROM wins_perszn
						INNER JOIN sal_perszn
						ON sal_perszn.teamid=wins_perszn.teamid AND sal_perszn.yearid=wins_perszn.yearid)

SELECT corr(combined.wins, combined.total_salary) AS corr_coef,
	   combined.yearid
FROM combined
GROUP BY combined.yearid


/* 12. In this question, you will explore the connection between number of wins and attendance.
      Does there appear to be any correlation between attendance at home games and number of wins? 
      Do teams that win the world series see a boost in attendance the following year? 
	  What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner. */
	
--Gives the year and correlation coefficient of wins to total attendance for that year

WITH wins_att AS   (SELECT SUM(homegames.attendance) AS total_att,
						   teams.name,
						   year,
						   w
					FROM homegames
					INNER JOIN teams
					ON teams.teamid=homegames.team AND teams.yearid=homegames.year
					GROUP BY teams.name, year, w
					ORDER BY year DESC, teams.name)
					
SELECT
	   year,
	   corr(w, total_att) AS corr_coef
FROM wins_att
GROUP BY year
ORDER BY year DESC;


---WS win vs attendance.  Query returns # and % of teams that saw an increase in attendance the year following a WS win.


WITH att_change AS	(SELECT t.attendance AS nxt_yr,
							a.attendance AS Ws_yr,
							a.name,
							CONCAT(a.yearid,'-',t.yearid) AS yr_span,
						    CASE WHEN t.attendance>a.attendance THEN 'Higher'
								 WHEN t.attendance<a.attendance THEN 'Lower'
								 ELSE 'Equal'
								 END AS attendance_change
					 FROM teams AS t, 
							   (SELECT attendance,
									   yearid,
									   name
								FROM teams
								WHERE wswin='Y' AND attendance IS NOT NULL) AS a
					WHERE t.name=a.name AND t.yearid=(a.yearid+1))
					
SELECT SUM (CASE WHEN attendance_change = 'Higher' THEN 1
	             ELSE 0
			     END) AS total_higher,
	   ROUND(SUM (CASE WHEN attendance_change = 'Higher' THEN 1
	             ELSE 0
			     END)::decimal/COUNT(*)::decimal*100,3) AS percent_higher
FROM att_change;


---playoff appearance vs attendance.  Query returns # and % of teams that saw an increase in attendance the year following a playoff appearance.


WITH att_change AS	(SELECT t.attendance AS nxt_yr,
							a.attendance AS Ws_yr,
							a.name,
							CONCAT(a.yearid,'-',t.yearid) AS yr_span,
						    CASE WHEN t.attendance>a.attendance THEN 'Higher'
								 WHEN t.attendance<a.attendance THEN 'Lower'
								 ELSE 'Equal'
								 END AS attendance_change
					 FROM teams AS t, 
							   (SELECT attendance,
									   yearid,
									   name
								FROM teams
								WHERE (divwin='Y' OR wcwin='Y')) AS a
					WHERE t.name=a.name AND t.yearid=(a.yearid+1))
					
SELECT SUM (CASE WHEN attendance_change = 'Higher' THEN 1
	             ELSE 0
			     END) AS total_higher,
	   ROUND(SUM (CASE WHEN attendance_change = 'Higher' THEN 1
	             ELSE 0
			     END)::decimal/COUNT(*)::decimal*100,3) AS percent_higher
FROM att_change;


/* 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. 
Investigate this claim and present evidence to either support or dispute this claim. 
First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame? */

--Gives percentage of pitchers which are left-handed
WITH left_pitch AS	   (SELECT COUNT(*) AS num_p
						FROM people
						WHERE throws='L' AND playerid IN (SELECT DISTINCT playerid
														  FROM pitching
														 WHERE g>0)),

	right_pitch AS	   (SELECT COUNT(*) AS num_p
						FROM people
						WHERE throws='R' AND playerid IN (SELECT DISTINCT playerid
														  FROM pitching
														 WHERE g>0))
														 
SELECT ROUND(((left_pitch.num_p)::decimal/(left_pitch.num_p::decimal+right_pitch.num_p::decimal)*100),3) AS percentage_lefty
FROM left_pitch,
     right_pitch

--This query returns the % of cy young winners who were left-handed.  
--33.0% of cy young winners are left handed and only 27.3% of pitchers are left handed.

		
WITH l_cy AS (SELECT COUNT(*) AS players_l
			  FROM awardsplayers
			  INNER JOIN people
			  USING(playerid)
			  WHERE awardid='Cy Young Award' AND throws='L'),

	 r_cy AS (SELECT COUNT(*) AS players_r
			  FROM awardsplayers
	  		  INNER JOIN people
			  USING(playerid)
			  WHERE awardid='Cy Young Award' AND throws='R')
			  
SELECT ROUND((l_cy.players_l::decimal/(l_cy.players_l::decimal+r_cy.players_r::decimal))*100,3) AS percent_l_cy
FROM l_cy,
	 r_cy
	 
--


