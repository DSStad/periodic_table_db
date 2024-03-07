#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

ELEMENT=$1

if [[ -z $ELEMENT ]]
then
  echo -e "Please provide an element as an argument."
fi 

if [[ $ELEMENT =~ ^[0-9]+$ ]] 
then
  IS_IN_DB=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $ELEMENT")
  if [[ -z $IS_IN_DB ]]
  then
    echo "I could not find that element in the database."
  else
    ELEMENT_NUMBER_NAME=$($PSQL "SELECT name, symbol FROM elements WHERE atomic_number = $ELEMENT")
    ELEMENT_NAME_FORMATTED="The element with atomic number $ELEMENT is $(echo $ELEMENT_NUMBER_NAME | sed 's/|/ (/'))."

    TYPE_MASS=$($PSQL "SELECT type, atomic_mass FROM types INNER JOIN properties USING(type_id) WHERE atomic_number = $ELEMENT")
    TYPE_FORMATTED="It's a $(echo $TYPE_MASS | sed 's/|/, with a mass of /') amu."

    MELTING_BOILING=$($PSQL "SELECT melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number = $ELEMENT")
    NAME_MELTING_BOILING_FORMATTED="$(echo $ELEMENT_NUMBER_NAME | sed 's/|[a-zA-Z]*$/ has a melting point of/') $(echo $MELTING_BOILING | sed 's/|/ celsius and a boiling point of /') celsius." 

    echo "$ELEMENT_NAME_FORMATTED $TYPE_FORMATTED $NAME_MELTING_BOILING_FORMATTED"
  fi
fi

if [[ $ELEMENT =~ ^[A-Za-z]+$ ]]
then
  IS_ELEMENT_IN_DB=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$ELEMENT' OR name = '$ELEMENT'")
  if [[ -z $IS_ELEMENT_IN_DB ]]
  then
    echo "I could not find that element in the database."
  else
    ELEMENT_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$ELEMENT' OR name = '$ELEMENT'")

    ELEMENT_NAME_SYMBOL=$($PSQL "SELECT name, symbol FROM elements WHERE symbol = '$ELEMENT' OR name = '$ELEMENT'")
    ELEMENT_NAME_SYMBOL_FORMATTED="$(echo $ELEMENT_NAME_SYMBOL | sed 's/|/ (/'))."

    TYPE_MASS=$($PSQL "SELECT type, atomic_mass FROM types INNER JOIN properties USING(type_id) INNER JOIN elements USING(atomic_number) WHERE symbol = '$ELEMENT' OR name = '$ELEMENT'")
    TYPE_MASS_FORMATTED="$(echo $TYPE_MASS | sed 's/|/, with a mass of /') amu."

    MELTING_BOILING=$($PSQL "SELECT melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) WHERE name = '$ELEMENT' OR symbol = '$ELEMENT'")
    MELTING_BOILING_FORMATTED="$(echo $MELTING_BOILING | sed 's/|/ celsius and a boiling point of /') celsius."

    echo "The element with atomic number $ELEMENT_NUMBER is $ELEMENT_NAME_SYMBOL_FORMATTED It's a $TYPE_MASS_FORMATTED $(echo $ELEMENT_NAME_SYMBOL | sed 's/|[A-Za-z]*$/ /')has a melting point of $MELTING_BOILING_FORMATTED"
  fi
fi


