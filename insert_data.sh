#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # check if winner team already exists
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found, add it to table
    if [[ -z $WINNER_ID ]]
    then
      INSERT_NEW_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo $INSERT_NEW_TEAM
      echo "Inserted $WINNER"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    # repeat process for loser team
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found, add it to table
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_NEW_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo $INSERT_NEW_TEAM
      echo "Inserted $OPPONENT"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # add new row
    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
     VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")



  fi
done
