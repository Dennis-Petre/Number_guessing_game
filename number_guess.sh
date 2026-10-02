#! /bin/bash

# create link to db
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

# set up game perms
TARGET=$(($RANDOM % 1000 + 1))
COUNTER=0
CORRECT=false

# get name from user
echo "Enter your username: "
read USERNAME
# query db for existing name
USER=$($PSQL "SELECT username FROM gamers WHERE username = '${USERNAME}'")

# add name if not found
if [[ -z $USER ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_NEW_USER=$($PSQL "INSERT INTO gamers(username,score,played) VALUES('$USERNAME',1000,0)")
    SCORE=1000
# query db for info if found
  else
    PLAYED=$($PSQL "SELECT played FROM gamers WHERE username = '$USER'")
    SCORE=$($PSQL "SELECT score FROM gamers WHERE username = '$USER'")
    # return responce
    echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $SCORE guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while [[ "$CORRECT" == "false" ]]; do
  # get guess
  read GUESS
 
  # check if int
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
  # if not short circuit return
    then
      echo "That is not an integer, guess again:" 
    continue
  fi
# increment guess count (not sure if this is to include non int guesses)
 (( COUNTER++ ))

  # return if correct
  if [[ "$GUESS" -eq "$TARGET" ]] 
  then
    echo "You guessed it in $COUNTER tries. The secret number was $TARGET. Nice job!"
    CORRECT=true

  # return if guess is high
  elif [[ "$GUESS" -gt "$TARGET" ]]
  then
    echo "It's lower than that, guess again:"

	# return if guess is low
  else
    echo "It's higher than that, guess again:"
  fi

# exit loop
done


# Query lowest guess count in db and increment down if applicable
if [[ "$SCORE" -gt "$COUNTER" ]]
then
  UPDATE_BEST=$($PSQL "UPDATE gamers SET score=$COUNTER WHERE username='$USERNAME'")
fi


(( PLAYED++ ))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE gamers SET played=$PLAYED WHERE username='$USERNAME'")
