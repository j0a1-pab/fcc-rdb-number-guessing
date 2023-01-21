#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

WELCOME() {

  echo -e "\n~~~ Number Guessing Game ~~~\n"

  echo -e "\nEnter your username:"
  read USERNAME

  USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  if [[ -z $USERNAME_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
  else
    echo $USERNAME_RESULT | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi

}

NUMBER_GUESS() {

  SECRET=$[ $RANDOM % 1000 + 1 ]
  GUESSCOUNT=1

  echo Guess the secret number between 1 and 1000:
  read GUESS
  
  while [[ $GUESS -ne $SECRET ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"      
    elif [[ $GUESS -lt $SECRET ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET ]]
    then
      echo "It's lower than that, guess again:"
    fi
    read GUESS
    GUESSCOUNT=$(($GUESSCOUNT+1))
  done

  if [[ $GUESS -eq $SECRET ]]
  then    
    ADD_GAME=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)) WHERE username = '$USERNAME'")
    if [[ -z $BEST_GAME || $GUESSCOUNT -lt $BEST_GAME ]]
    then
      ADD_BEST=$($PSQL "UPDATE users SET best_game = $GUESSCOUNT WHERE username = '$USERNAME'")
    fi
    echo "You guessed it in $GUESSCOUNT tries. The secret number was $SECRET. Nice job!"
  fi

}

WELCOME

NUMBER_GUESS

