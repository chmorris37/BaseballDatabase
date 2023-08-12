#Proposed question from Milestone 1:
#Who are the best players to not make the Hall of Fame?
#Are these players the suspected steroid users we might expect?
#We will be looking at the top HR hitters along with players with the most wins/hits.

#Look at batting statistics: HRs
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
