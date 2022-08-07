#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo -e "How may I help you?\n"


MAIN_MENU() {
  #display a numbered list of the services you offer before the first prompt for input, each with the format #) <service>

  #get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  #display services
  # sed method echo "$SERVICES" | sed -E 's/^ *| *$//g' | sed -E 's/ \|/)/g'
  
  #while read method
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done


  #read selection
  read SERVICE_ID_SELECTED
  
  #check if in db
  SERVICE_ID_SELECTED_DB=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  #if not found
  if [[ -z $SERVICE_ID_SELECTED_DB ]]
  then

    #send to main menu
    MAIN_MENU "Please enter a valid service number."
  
  else

    #get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    #check if already a customer
    CUSTOMER_ID_DB=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    #if not found
    if [[ -z $CUSTOMER_ID_DB ]]
    then

      #get name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      #insert into customers phone & name
      CUSTOMER_PHONE_NAME_IN_DB=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")

      #get customer id
      CUSTOMER_ID_DB=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    
    fi

    #ask for time
    echo -e "\nWhat time would you like?"
    read SERVICE_TIME


    #insert into appointments customer_id & service_id & time
    CUSTOMER_ID_SERVICE_ID_TIME_IN_DB=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_DB, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    
    #get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

    #retrieve customer name
    CUSTOMER_NAME_DB=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    #output message
    echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME_DB."
  
  fi

}

MAIN_MENU


