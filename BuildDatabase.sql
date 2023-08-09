CREATE DATABASE baseball;
USE baseball;

#Create column of active with boolean values
UPDATE franchises
SET active = 
	CASE 
		WHEN active2 = 'Y' THEN TRUE
        ELSE FALSE
	END;
    
#Create teams table
CREATE TABLE teams AS
(SELECT DISTINCT franchID, teamID, name
FROM team_stats);

#Find teams with different names
SELECT franchID, teamID
FROM teams
GROUP BY franchID, teamID
HAVING COUNT(name) > 1
ORDER BY franchID, teamID;

#Make it so teams have only their most important name
UPDATE teams
SET name = 
	CASE 
		WHEN franchID = 'ANA' AND teamID = 'LAA' THEN 'Los Angeles Angels'
        WHEN franchID = 'ATL' AND teamID = 'BSN' THEN 'Boston Braves'
        WHEN franchID = 'BFL' AND teamID = 'BUF' THEN 'Buffalo Blues'
        WHEN franchID = 'BOS' AND teamID = 'BOS' THEN 'Boston Red Sox'
        WHEN franchID = 'CHC' AND teamID = 'CHN' THEN 'Chicago Cubs'
        WHEN franchID = 'CHH' AND teamID = 'CHF' THEN 'Chicago Whales'
        WHEN franchID = 'HOU' AND teamID = 'HOU' THEN 'Houston Astros'
        WHEN franchID = 'CIN' AND teamID = 'CIN' THEN 'Cincinnati Reds'
        WHEN franchID = 'CLE' AND teamID = 'CLE' THEN 'Cleveland Indians'
        WHEN franchID = 'LAD' AND teamID = 'BR3' THEN 'Brooklyn Grays'
        WHEN franchID = 'LAD' AND teamID = 'BRO' THEN 'Brooklyn Dodgers'
        WHEN franchID = 'NYY' AND teamID = 'NYA' THEN 'New York Yankees'
        WHEN franchID = 'PHI' AND teamID = 'PHI' THEN 'Philadelphia Phillies'
        WHEN franchID = 'PIT' AND teamID = 'PIT' THEN 'Pittsburgh Pirates'
        WHEN franchID = 'STL' AND teamID = 'SLN' THEN 'St. Louis Cardinals'
        WHEN franchID = 'TBD' AND teamID = 'TBA' THEN 'Tampa Bay Rays'
        ELSE name
	END;

#now remove the duplicates (added an id column just to do this)
DELETE T1 FROM teams AS T1  
INNER JOIN teams AS T2   
WHERE T1.id < T2.id AND T1.name = T2.name AND T1.franchID = T2.franchID AND T1.teamID=T2.teamID;  

#update my chosen name change for a certain teamID, so no repeats
#IMPORTANT
UPDATE teams
SET teamID = 
	CASE 
		#this is the case for all years < 1920
        WHEN franchID = 'WAS' AND teamID = 'WAS' THEN 'WSS'
        ELSE teamID
	END;

#update my chosen name change for a certain teamID
UPDATE team_stats
SET teamID = 
	CASE 
		#this is the case for all years < 1920
        WHEN yearID < 1920 AND teamID = 'WAS' THEN 'WSS'
        ELSE teamID
	END;
    
#keep only world series rounds from at least 1891
DELETE FROM world_series
WHERE round != 'WS';
DELETE FROM world_series
WHERE yearID < 1891;


#Create Countries table
CREATE TABLE countries AS
SELECT DISTINCT(birthCountry)
FROM players;

#Add Countries id to the players table
UPDATE players
SET countryID = 
	(SELECT DISTINCT(countries.countryID)
	FROM countries
    WHERE countries.birthCountry = players.birthCountry);
    
#Fil in the NUll values for date value
UPDATE players
SET debut = 
	CASE 
		WHEN debut = '' THEN NULL
        ELSE debut
	END;

#Remove the nominees not inducted to hall of fame
DELETE FROM hallOfFame
WHERE inducted != 'Y';

#Update the team name change I instituted earlier
#for batting statistics
UPDATE batting_stats
SET teamID = 
	CASE 
		#this is the case for all years < 1920
        WHEN year < 1920 AND teamID = 'WAS' THEN 'WSS'
        ELSE teamID
	END;


#Get rid of the few amount of rows of players who played with the same team twice
#in one year, for 2 separate occasions (got rid of the stats for small number of games)
DELETE FROM batting_stats
WHERE id IN (1148, 1760, 2310, 2712, 4682, 5671, 6774, 7964, 9383, 11903, 21831, 24288, 24675, 24994, 25460, 27104, 27259, 31304, 31402, 40101, 49302, 
60916, 61126, 62145, 63098, 63141, 63150, 65040, 65519, 66261, 68978, 70820, 71571, 75021, 76590, 82129, 84117, 84404, 86348);
DELETE FROM pitching_stats
WHERE id IN (4016, 4880,6152, 10720, 11607, 14680, 14808, 30379, 31096, 31933, 35223, 36973);

#Get rid of rows with players/teams not in the other tables
DELETE FROM batting_stats
WHERE playerID NOT IN 
(SELECT DISTINCT(playerID) FROM players) OR teamID NOT IN 
(SELECT DISTINCT(teamID) FROM teams);

DELETE FROM pitching_stats
WHERE playerID NOT IN 
(SELECT DISTINCT(playerID) FROM players) OR teamID NOT IN 
(SELECT DISTINCT(teamID) FROM teams);

DELETE FROM salaries
WHERE (playerID NOT IN 
(SELECT DISTINCT(playerID) FROM players)) OR (teamID NOT IN 
(SELECT DISTINCT(teamID) FROM teams));

#update my chosen name change for a certain teamID
#this is the case for all years < 1920
UPDATE salaries
SET teamID = 
	CASE 
		#this is the case for all years < 1920
        WHEN yearID < 1920 AND teamID = 'WAS' THEN 'WSS'
        ELSE teamID
	END;


#there are already these awards for the NL and AL leagues
DELETE FROM awardsplayers
WHERE awardID = "Baseball Magazine All-Star" and lgID = "ML";


#Create awardsTypes table
CREATE TABLE awardTypes AS
(SELECT DISTINCT awardID
FROM awardsplayers);

#Add awards type ID to awards table
UPDATE awards
SET awardID = 
	(SELECT DISTINCT(awardTypes.awardID)
	FROM awardTypes
    WHERE awardTypes.award = awards.awardIDs);

#Remove players that don't have a player_ID in players
DELETE FROM fielding 
WHERE playerID NOT IN 
(SELECT DISTINCT(playerID) FROM players); 

#Create new table called "errors" by grouping by playerID, position, year
CREATE TABLE errors AS
(SELECT playerID, year, POS, SUM(G) AS G, SUM(E) AS E
FROM fielding
GROUP BY playerID, year, POS);

#Create positions table
CREATE TABLE positions AS
(SELECT DISTINCT(POS)
FROM errors);

#Add positionID to errors
UPDATE errors
SET positionID = 
	(SELECT DISTINCT(positions.positionID)
	FROM positions
    WHERE positions.position = errors.POS);
    
