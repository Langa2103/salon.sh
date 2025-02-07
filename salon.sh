#!/bin/bash
# Connect to the database and get the list of services
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~ Welcome to the Salon Appointment Scheduler ~~~\n"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Prompt for a valid service selection
while true; do
  echo -e "\nPlease select a service:"
  display_services
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  
  if [[ -n $SERVICE_NAME ]]; then
    break
  else
    echo -e "\nInvalid selection. Please try again."
  fi
done

# Get customer phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]; then
  # New customer, get their name
  echo -e "\nIt looks like you're a new customer! What's your name?"
  read CUSTOMER_NAME
  
  # Insert new customer into the database
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
fi

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# Get appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

# Confirm appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
