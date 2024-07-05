#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

secret_number=$(( $RANDOM % 1000 + 1 ))

guess=0

number_of_guesses=0


echo "Enter your username:"

read user_username

result=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$user_username'")



if [[ -z $result ]]; then
    echo "Welcome, $user_username! It looks like this is your first time here."

   update_user=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$user_username', 0, 0);")

  else
    IFS='|' read -ra user_data <<< "$result"

    user_games_played="${user_data[1]}"

    user_best_game="${user_data[2]}"

    echo "Welcome back, $user_username! You have played $user_games_played games, and your best game took $user_best_game guesses."
  fi


echo "Guess the secret number between 1 and 1000:"

  while [ $guess -ne $secret_number ]; do
    read guess

    if ! [[ $guess =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"

    elif [ $guess -lt $secret_number ]; then
      echo "It's higher than that, guess again:"

    elif [ $guess -gt $secret_number ]; then
      echo "It's lower than that, guess again:"
    fi

    ((number_of_guesses++))
  done

  echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"

update_game_played=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$user_username'")

if [[ -z $user_best_game || $user_best_game -gt $number_of_guesses ]]; then
    update_best_game=$($PSQL "UPDATE users SET best_game = $number_of_guesses WHERE username = '$user_username'")
  fi
