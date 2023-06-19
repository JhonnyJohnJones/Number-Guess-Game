#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( (RANDOM % 999) + 1 ))

echo "Enter your username:"
read USERNAME
USERNAME_IN_DATABASE=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")

if [[ -z $USERNAME_IN_DATABASE ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_OF_GUESSINGS=0

LOGIC () {
  echo $1
  read GUESS
  (( NUMBER_OF_GUESSINGS++ ))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    LOGIC "That is not an integer, guess again:"
  else
    if [[ $GUESS > $NUMBER ]]
    then
      LOGIC "It's lower than that, guess again:"
    elif [[ $GUESS < $NUMBER ]]
    then
      LOGIC "It's higher than that, guess again:"
    fi
  fi
}

LOGIC "Guess the secret number between 1 and 1000:"

echo "You guessed it in $NUMBER_OF_GUESSINGS tries. The secret number was $NUMBER. Nice job!"

INSERT_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = (games_played + 1) WHERE username = '$USERNAME';")
INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSINGS WHERE username = '$USERNAME' AND best_game > $NUMBER_OF_GUESSINGS AND $NUMBER_OF_GUESSINGS > 0;")
