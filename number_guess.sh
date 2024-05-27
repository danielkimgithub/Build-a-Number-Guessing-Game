#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read username

USERNAME=$($PSQL "select username from player where username = '$username';")

if [[ -z $USERNAME ]]
then
  echo Welcome, $username! It looks like this is your first time here.
  INSERT_NEW_PLAYER=$($PSQL "insert into player(username) values('$username');")
else
  best_game=$($PSQL "select min(num_of_guesses) from games left join player using (player_id) where username = '$username';")
  games_played=$($PSQL "select count(game_id) from games left join player using (player_id) where username = '$username';")

  echo Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses.
fi

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

NUM_OF_GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"
read user_guess

until [[ $user_guess == $RANDOM_NUMBER ]]
do
  if [[ ! $user_guess =~ ^[0-9]*$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read user_guess

    ((NUM_OF_GUESSES++))
  
  else
    if [[ $user_guess < $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      read user_guess

      ((NUM_OF_GUESSES++))

    else
      echo -e "\nIt's lower than that, guess again:"
      read user_guess

      ((NUM_OF_GUESSES++))
    fi
  fi
done

((NUM_OF_GUESSES++))

ID=$($PSQL "select player_id from player where username = '$username';")

INSERT_GAME_INFO=$($PSQL "insert into games(player_id, secret_number, num_of_guesses) values($ID, $RANDOM_NUMBER, $NUM_OF_GUESSES);")
echo -e "\n You guessed it in $NUM_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
