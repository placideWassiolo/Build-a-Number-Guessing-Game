#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"
#PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# output function
MESSAGE(){
  if [[ $1 ]]
  then
    echo -e "$1"
  else
    echo  -e "Enter your username:"
  fi
}
GUESS_NUMBER(){
  NUMBER=$(( RANDOM % 1000 + 1 ))
  MESSAGE "Guess the secret number between 1 and 1000:"
  read GUESS_NUMBER
  SUM_GUESS=1

  while [[ $GUESS_NUMBER != $NUMBER ]]
  do
    
    if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      
      MESSAGE "That is not an integer, guess again:"
      read GUESS_NUMBER
      (( SUM_GUESS++ ))
      
    else
      if [[ $GUESS_NUMBER -lt $NUMBER ]]
      then
        
        MESSAGE "It's lower than that, guess again:"
        read GUESS_NUMBER
        (( SUM_GUESS++ ))

      elif [[ $GUESS_NUMBER -gt $NUMBER ]]
      then
        
        MESSAGE "It's higher than that, guess again:"
        read GUESS_NUMBER
        (( SUM_GUESS++ ))

      fi
    fi
  done
  MESSAGE "You guessed it in $SUM_GUESS tries. The secret number was $NUMBER. Nice job!"
  
}

INSERT_USERNAME(){
  if [[ $1 ]]
  then
    INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$1')")
  fi
}

INSERT_GAME(){
  if [[ $2 ]]
  then
    INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guess, user_id) VALUES('$1', '$2')")
  fi
}

GAME_PLAYED(){
  MESSAGE
  read NAME
  USERNAME=$NAME
  
  USERNAME_RESULT=$($PSQL "SELECT user_id, username FROM users WHERE username='$USERNAME'")

  if [[ -z $USERNAME_RESULT ]]
  then
    MESSAGE "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USERNAME $USERNAME
    GET_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    GUESS_NUMBER
    INSERT_GAME $SUM_GUESS $GET_USER_ID
  else
    
        # get user games and minimum tries
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
        GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
        BEST_GAME=$($PSQL "SELECT  MIN(number_of_guess) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
        MESSAGE "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

        GUESS_NUMBER
        INSERT_GAME $SUM_GUESS $USER_ID
  fi
}

GAME_PLAYED