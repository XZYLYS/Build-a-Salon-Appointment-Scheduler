#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU(){
  echo -e "\n~~~~~ Salon Services ~~~~~"
  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id") 
  
  #list of services
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME" | sed 's/ | / /'
  done
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"

  # enter service ID
  echo -e "Enter Service ID:"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e '\nInvalid Input, Try Again'
    MAIN_MENU 
  else
    IS_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $IS_AVAILABLE ]]
    then

      #if service doesn't exist prompt to the services again
      echo -e "\nInvalid Service $SERVICE_ID_SELECTED"
      MAIN_MENU
    else
      echo -e "\nEnter Phone number: "
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
      # if phone number doesn't exist
      if [[ -z $CUSTOMER_ID ]]
      then

        # get customer name
        echo -e "\nEnter Name: "
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi

      # get service schedule
      echo -e "\nEnter Schedule Time(HH:MM): "
      read SERVICE_TIME

      #get customers id,name and service
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      # insert the appointments
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      # display info
      echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME,$CUSTOMER_NAME."
    fi
  fi
}
MAIN_MENU