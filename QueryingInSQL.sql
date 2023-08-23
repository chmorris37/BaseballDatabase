#Question 1: Who are the best players to not make the Hall of Fame?

#Assumption: These are players suspected of taking illegal enhancement performers
#or betting on games
#Note: I can't include players in this last who are still playing or were not HOF eligible before 2015.

#Look at batting statistics: HRs
#Search for the players with the most HRs yet are not in the HOF
SELECT nameFirst, nameLast, Career_HR
FROM players
INNER JOIN 
(SELECT playerID, SUM(HR) AS Career_HR
FROM batting_stats
GROUP BY playerID) AS hr_stats
ON players.playerID = hr_stats.playerID
WHERE players.playerID NOT IN
(SELECT playerID
FROM hall_of_fame) AND (finalGame < '2007-12-31')
ORDER BY Career_HR DESC;

#Look at batting statistics: Hits
#Search for the players with the most hits yet are not in the HOF
SELECT nameFirst, nameLast, Career_H
FROM players
INNER JOIN 
(SELECT playerID, SUM(H) AS Career_H
FROM batting_stats
GROUP BY playerID) AS h_stats
ON players.playerID = h_stats.playerID
WHERE players.playerID NOT IN
(SELECT playerID
FROM hall_of_fame) AND (finalGame < '2007-12-31')
ORDER BY Career_H DESC;

#Look at pitching statistics: Wins
#Search for the players with the most Wins yet are not in the HOF
SELECT nameFirst, nameLast, Career_W
FROM players
INNER JOIN 
(SELECT playerID, SUM(W) AS Career_W
FROM pitching_stats
GROUP BY playerID) AS w_stats
ON players.playerID = w_stats.playerID
WHERE players.playerID NOT IN
(SELECT playerID
FROM hall_of_fame) AND (finalGame < '2007-12-31')
ORDER BY Career_W DESC;



#Question 2: What the best individual season performance by a pitcher or hitter?

#Hitting: Order by the sabermetric stat OPS (which is slugging percentage + on base percentage)
SELECT CONCAT(nameFirst, ' ', nameLast) AS "fullName", year, name AS "team", ROUND((H + 2B + 2 * 3B + 3 * HR)/(AB)+ (H + BB)/(AB + BB), 3) AS "OPS", AB, H, 2B, 3B, HR, BB
FROM batting_stats AS bs
INNER JOIN players AS p
ON bs.playerID = p.playerID
INNER JOIN teams AS t
ON bs.teamID = t.teamID
WHERE AB > 200
ORDER BY OPS DESC;

#Hitting: Order by the Strike out to Walk Rate. I also do some otherwise filtering
SELECT CONCAT(nameFirst, ' ', nameLast) AS "fullName", year, name AS "team", G, W, L, GS, SV, BB, SO, ERA
FROM pitching_stats AS ps
INNER JOIN players AS p
ON ps.playerID = p.playerID
INNER JOIN teams AS t
ON ps.teamID = t.teamID
WHERE SO > 100 AND ERA < 3 AND (W >= 18 OR SV > 30)
ORDER BY SO/BB DESC;



#Question 3: Is there a relationship among players between winning a World Series and Hall of Fame consideration?

#Count of players in HOF who have won a WS
SELECT COUNT(*) INTO @hallOfFameWSCount
FROM hall_of_fame
WHERE playerID IN 
	(SELECT playerID
    FROM batting_stats AS bs
    INNER JOIN world_series AS ws
    ON bs.year = ws.year AND bs.teamID = ws.teamIDwinner
    UNION
    SELECT playerID
    FROM pitching_stats AS ps
    INNER JOIN world_series AS ws
    ON ps.year = ws.year AND ps.teamID = ws.teamIDwinner);
#Answer is 135

#Count of players in the Hall of Fame
SELECT COUNT(*) INTO @hallOfFameCount
FROM hall_of_fame;
#Answer is 287


#Count of all players who have won a world series
SELECT COUNT(*) INTO @playersWSCount
FROM players
WHERE playerID IN 
	(SELECT playerID
    FROM batting_stats AS bs
    INNER JOIN world_series AS ws
    ON bs.year = ws.year AND bs.teamID = ws.teamIDwinner
    UNION
    SELECT playerID
    FROM pitching_stats AS ps
    INNER JOIN world_series AS ws
    ON ps.year = ws.year AND ps.teamID = ws.teamIDwinner);
#Answer is 2,633


#Count of all players
SELECT COUNT(*) INTO @playersCount
FROM players;
#Answer is 17,725


#Count of players in HOF who have at least 2 WS
WITH P_2WS AS
	(SELECT playerID
    FROM pitching_stats AS ps
    INNER JOIN world_series AS ws
    ON ps.year = ws.year AND ps.teamID = ws.teamIDwinner
    GROUP BY playerID
    HAVING COUNT(*) > 1),
    B_2WS AS
    (SELECT playerID
    FROM batting_stats AS bs
    INNER JOIN world_series AS ws
    ON bs.year = ws.year AND bs.teamID = ws.teamIDwinner
    GROUP BY playerID
    HAVING COUNT(*) > 1),
    All_2WS AS 
    (SELECT playerID
    FROM P_2WS
    UNION 
    SELECT playerID
    FROM B_2WS)
SELECT COUNT(*) INTO @hallOfFameWSCount2
FROM hall_of_fame
WHERE playerID IN 
	(SELECT playerID
    FROM All_2WS);
#Answer 68
    
#Count of all players who have at least 2 WS
WITH P_2WS AS
	(SELECT playerID
    FROM pitching_stats AS ps
    INNER JOIN world_series AS ws
    ON ps.year = ws.year AND ps.teamID = ws.teamIDwinner
    GROUP BY playerID
    HAVING COUNT(*) > 1),
    B_2WS AS
    (SELECT playerID
    FROM batting_stats AS bs
    INNER JOIN world_series AS ws
    ON bs.year = ws.year AND bs.teamID = ws.teamIDwinner
    GROUP BY playerID
    HAVING COUNT(*) > 1),
    All_2WS AS 
    (SELECT playerID
    FROM P_2WS
    UNION 
    SELECT playerID
    FROM B_2WS)
SELECT COUNT(*) INTO @playersWSCount2
FROM All_2WS;
#Answer 689

#Summary table
SELECT @hallOfFameWSCount/@hallOfFameCount * 100 AS "Percent of HOF with a WS", @playersWSCount/@playersCount * 100 AS "Percent of players with a WS",
@hallOfFameWSCount2/@hallOfFameCount * 100 AS "Percent of HOF with a 2+ WS", @playersWSCount2/@playersCount * 100 AS "Percent of players with a 2+ WS";


