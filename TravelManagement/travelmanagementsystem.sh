#!/bin/bash

DESTINATIONS_FILE="available_destinations.txt"
BOOKINGS_FILE="bookings.txt"
USER_CREDENTIALS_FILE="user_credentials.txt"


# Initialize destination file if it doesn't exist
create_file_if_not_exists "$DESTINATIONS_FILE"
if [ ! -s "$DESTINATIONS_FILE" ]; then
  cat <<EOL > "$DESTINATIONS_FILE"
Hunza Valley,15000
Shangrila Resort,20000
Nathia Gali,12000
Naran Valley,18000
Babusar Top,25000
Murree,10000
Khewra Salt Mines,8000
EOL
  echo -e "\033[32mDefault destinations added to $DESTINATIONS_FILE.\033[0m"
fi

# Initialize user credentials file if it doesn't exist
 create_file_if_not_exists "$USER_CREDENTIALS_FILE"

#create_file_if_not_exists "$DESTINATIONS_FILE"

# Initialize bookings file if it doesn't exist
create_file_if_not_exists "$BOOKINGS_FILE"

# Utility function for centered, bold, and blue headings
centered_heading() {
  clear
  echo -e "\033[1;34m"
  printf "%*s\n" $(((${#1} + $(tput cols)) / 2)) "$1"
  echo -e "\033[0m"
}
reset_colors() {
  echo -e "\033[0m"
}

# Updated "Press Enter" function based on context
press_enter() {
  echo -e "\033[33m\nPress Enter to continue...\033[0m"
  read
}


# Function to display the main menu
main_menu() {
  clear  
centered_heading "|*|*|*|*|  Welcome to Trip Troop  |*|*|*|*|"
  echo -e "\n\033[1mPlease select an option:\033[0m"
  echo "1. Log in as Admin"
  echo "2. Register as a User"
  echo "3. Log in as User"
  echo "4. Exit"
  echo -n "Enter your choice: "
  read choice
  case $choice in
    1) admin_login ;;
    2) register_user ;;
    3) user_login ;;
    4) echo "Exiting..."; exit 0 ;;
    *) echo -e "\033[31mInvalid option. Please try again.\033[0m"; press_enter; main_menu ;;
  esac
}

# Function to press Enter to continue
press_enter() {
  echo -e "\n\033[33mPress Enter to continue...\033[0m"
  read
}

# Function for Admin Login
admin_login() {
  clear
  centered_heading "~~ADMIN LOGIN~~"
  
  echo -n "Enter Admin Username: "
  read admin_user
  echo -n "Enter Admin Password: "
  read -s admin_pass
  echo
  if [ "$admin_user" == "admin" ] && [ "$admin_pass" == "admin123" ]; then
    echo -e "\033[32mLogin successful!\033[0m"
    press_enter
    admin_menu
  else
    echo -e "\033[31mInvalid credentials. Please try again.\033[0m"
    press_enter
    main_menu
  fi
}

# Function to display Admin Menu
admin_menu() {
  clear
 centered_heading "~~ADMIN DASHBOARD~~"
  echo "1. Manage Destinations"
  echo "2. View Booked Trips"
  echo "3. Generate Reports"
  echo "4. Logout"
  echo -n "Enter your choice: "
  read admin_choice
  case $admin_choice in
    1) manage_destinations ;;
    2) view_booked_trips ;;
    3) generate_reports ;;
    4) main_menu ;;
    *) echo -e "\033[31mInvalid option. Please try again.\033[0m"; press_enter; admin_menu ;;
  esac
}

# Function to register the user
register_user() {
  clear
  centered_heading "~~USER REGISTRATION~~"
    # Prompt for username
    echo -n "Enter username: "
    read username
 if grep -q "^$username," "$USER_CREDENTIALS_FILE"; then
    echo -e "\033[31mError: Username already exists. Please try another username or login.\033[0m"
    press_enter
    main_menu # Return to main menu
    return
  fi

    # Prompt for password (input hidden for security)
    echo -n "Enter password: "
    read -s password
    echo

    # Check if username or password is empty
    if [[ -z "$username" || -z "$password" ]]; then
        echo  -e "\033[0;31mError: Username and password cannot be empty. Please try again.\033[0;31m"
    else
        echo -e "\033[32mRegistered successfully!\033[0m"
        
        # Here, you can add code to save the username and password (e.g., write to a file or database)
    fi
    press_enter
  main_menu
}


# Function for User Login
user_login() {
  clear
  centered_heading "~~USER LOGIN~~"

  # Prompt for username
  echo -n "Enter your username: "
  read username

  # Prompt for password (hidden input)
  echo -n "Enter your password: "
  read -s password
  echo

  # Check if username or password is empty
  if [[ -z "$username" || -z "$password" ]]; then
    echo -e "\033[31mError: Username and password cannot be empty. Please try again.\033[0m"
    press_enter
    user_login # Retry login
  elif grep -q "$username,$password" "$USER_CREDENTIALS_FILE"; then
    echo -e "\033[32mLogin successful!\033[0m"
    press_enter
    user_menu "$username" # Proceed to user menu
  else
    echo -e "\033[31mInvalid credentials. Please try again.\033[0m"
    press_enter
    main_menu # Return to main menu
  fi
   press_enter
  main_menu
}


# Function to display User Menu
user_menu() {
  local username=$1
  user_background
  clear
  centered_heading "~~Welcome, $username~~"
  
  echo "1. View Available Destinations"
  echo "2. Book a Trip"
  echo "3. View Booked Trips"
  echo "4. Cancel a Booking"
  echo "5. Logout"
  echo -n "Enter your choice: "
  read user_choice
  reset_colors
  
   
  case $user_choice in
    1) view_destinations; press_enter; user_menu "$username" ;;
    2) book_trip "$username"; press_enter; user_menu "$username" ;;
    3) view_user_bookings "$username"; press_enter; user_menu "$username" ;;  # Added option
    4) cancel_booking "$username"; press_enter; user_menu "$username" ;;
    5) main_menu ;;
    *) echo -e "\033[31mInvalid option. Please try again.\033[0m"; press_enter; user_menu "$username" ;;
  esac
}

# Function to cancel a booking (User mode)
cancel_booking() {
  local username=$1
  clear
  centered_heading "~~Cancel Booking~~"
  
  # Check if user has any bookings
  if ! grep -q "^$username," "$BOOKINGS_FILE"; then
    echo -e "\033[31mNo bookings found for user: $username\033[0m"
    press_enter
    return
  fi

  echo -e "\033[33mYour current bookings:\033[0m"
  grep "^$username," "$BOOKINGS_FILE" | awk -F',' '{print NR ". Destination: " $2 ", Guests: " $6 ", Dates: " $7 " to " $8}'
  
  echo -n "Enter the booking number to cancel: "
  read booking_number
  
  if ! [[ "$booking_number" =~ ^[0-9]+$ ]]; then
    echo -e "\033[31mInvalid input. Please enter a number.\033[0m"
    press_enter
    return
  fi
  
  # Get the line number of the booking to delete
  line_number=$(grep -n "^$username," "$BOOKINGS_FILE" | sed -n "${booking_number}p" | cut -d: -f1)
  
  if [ -z "$line_number" ]; then
    echo -e "\033[31mNo booking found with the given number.\033[0m"
    press_enter
    return
  fi
  
  # Delete the selected booking
  sed -i "${line_number}d" "$BOOKINGS_FILE"
  echo -e "\033[32mBooking canceled successfully!\033[0m"
  press_enter
}


# Function to display available destinations with proper formatting
view_destinations() {
  clear
  centered_heading "~~AVAILABLE DESTINATIONS~~"
  printf "%-30s %-10s\n" "Destination" "Price (Per Head)"
  printf "%-30s %-10s\n" "-----------" "--------------"
  while IFS=, read -r destination price; do
    printf "%-30s %-10s\n" "$destination" "$price"
  done < "$DESTINATIONS_FILE"
}

# Function to view user bookings
view_user_bookings() {
  local username=$1
  clear
  centered_heading "~~Your Booked Trips~~"

  # Check if user has any bookings
  if ! grep -q "^$username," "$BOOKINGS_FILE"; then
    echo -e "\033[31mYou have no bookings.\033[0m"
    press_enter
    return
  fi

  # Display bookings in a tabular format
  printf "%-15s %-20s %-15s %-15s %-10s %-10s\n" "Username"  "Destination"  "Guests"  "Arrival Date"  "Leaving Date"  "Total Bill"
  printf "%-15s %-20s %-15s %-15s %-10s %-10s\n" "--------"  "-----------"  "------"  "------------"  "-----------"   "----------"

  while IFS=, read -r booked_username destination address contact email guests arrival_date leaving_date; do
    if [[ "$booked_username" == "$username" ]]; then
      # Fetch the price for the destination
      destination_price=$(grep "^$destination," "$DESTINATIONS_FILE" | cut -d',' -f2)

      # Calculate total bill
      total_bill=$((destination_price * guests))

      # Display booking details
      printf "%-15s %-20s %-15s %-15s %-10s %-10s\n" "$username" "$destination" "$guests" "$arrival_date" "$leaving_date" "$total_bill"
    fi
  done < "$BOOKINGS_FILE"
}


# Function to view booked trips (Admin only)
view_booked_trips() {
  clear
  centered_heading "~~BOOKED TRIPS~~"
  if [ ! -s "$BOOKINGS_FILE" ]; then
    echo -e "\033[31mNo bookings found.\033[0m"
  else
    echo -e "\033[33mList of Booked Trips:\033[0m"
    printf "%-15s %-30s %-15s %-15s %-10s %-15s %-15s %-15s\n" "Username" "Destination" "Address" "Contact" "Email" "Guests" "Arrival Date" "Leaving Date"
    while IFS=, read -r username destination address contact email guests arrival_date leaving_date; do
      printf "%-15s %-30s %-15s %-15s %-10s %-15s %-15s %-15s\n" "$username" "$destination" "$address" "$contact" "$email" "$guests" "$arrival_date" "$leaving_date"
    done < "$BOOKINGS_FILE"
  fi
  press_enter
  admin_menu
}
# Function to generate reports (Admin only)
generate_reports() {
  clear
 centered_heading "~~GENERATE REPORTS~~"

  if [ ! -f "$BOOKINGS_FILE" ] || [ ! -s "$BOOKINGS_FILE" ]; then
    echo -e "\033[31mNo bookings found. Please add some bookings first.\033[0m"
    press_enter
    admin_menu
    return
  fi

  total_bookings=0
  total_revenue=0

  echo -e "\033[1mBooking Details:\033[0m"
  printf "%-15s %-20s %-10s %-15s %-10s\n" "Username" "Destination" "Guests" "Price" "Total Cost"

  while IFS=, read -r username destination address contact email guests arrival_date leaving_date; do
    destination_price=$(grep "^$destination," "$DESTINATIONS_FILE" | cut -d',' -f2)

    if [ -z "$destination_price" ]; then
      echo -e "\033[31mError: Price for destination '$destination' not found.\033[0m"
      continue
    fi

    total_cost=$((destination_price * guests))
    printf "%-15s %-20s %-10s %-15s %-10s\n" "$username" "$destination" "$guests" "$destination_price" "$total_cost"

    total_bookings=$((total_bookings + 1))
    total_revenue=$((total_revenue + total_cost))
  done < "$BOOKINGS_FILE"

  echo -e "\n\033[1mSummary:\033[0m"
  echo -e "\033[32mTotal Bookings: $total_bookings\033[0m"
  echo -e "\033[32mTotal Revenue: $total_revenue PKR\033[0m"
  press_enter
  admin_menu
}

 

# Function to book a trip
# Function to book a trip
book_trip() {
  local username=$1
  clear
  centered_heading "~~BOOK A TRIP~~"
  view_destinations

  # Get destination input and validate
  while true; do
    echo -n "Enter destination from the list: "
    read destination
    if [[ -z "$destination" ]]; then
      echo -e "\033[31mError: Destination is required.\033[0m"
    elif ! grep -q "^$destination," "$DESTINATIONS_FILE"; then
      echo -e "\033[31mError: Invalid destination. Please choose from the list.\033[0m"
    else
      break
    fi
  done

  # Get address input and validate
  while true; do
    echo -n "Enter your address: "
    read address
    if [[ -z "$address" ]]; then
      echo -e "\033[31mError: Address is required.\033[0m"
    else
      break
    fi
  done

  # Get contact number input and validate
  while true; do
    echo -n "Enter your contact number: "
    read contact
    if [[ -z "$contact" ]]; then
      echo -e "\033[31mError: Contact number is required.\033[0m"
    elif ! [[ "$contact" =~ ^[0-9]+$ ]]; then
      echo -e "\033[31mError: Contact number must contain only digits.\033[0m"
    else
      break
    fi
  done

  # Get email input and validate
  while true; do
    echo -n "Enter your email: "
    read email
    if [[ -z "$email" ]]; then
      echo -e "\033[31mError: Email is required.\033[0m"
    elif ! [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
      echo -e "\033[31mError: Invalid email format.\033[0m"
    else
      break
    fi
  done

  # Get number of guests input and validate
  while true; do
    echo -n "Enter the number of guests: "
    read guests
    if [[ -z "$guests" ]]; then
      echo -e "\033[31mError: Number of guests is required.\033[0m"
    elif ! [[ "$guests" =~ ^[0-9]+$ ]]; then
      echo -e "\033[31mError: Number of guests must be a valid number.\033[0m"
    else
      break
    fi
  done

  # Get arrival date input and validate
  while true; do
    echo -n "Enter arrival date (YYYY-MM-DD): "
    read arrival_date
    if [[ -z "$arrival_date" ]]; then
      echo -e "\033[31mError: Arrival date is required.\033[0m"
    elif ! [[ "$arrival_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      echo -e "\033[31mError: Invalid date format. Use YYYY-MM-DD.\033[0m"
    else
      break
    fi
  done

  # Get leaving date input and validate
  while true; do
    echo -n "Enter leaving date (YYYY-MM-DD): "
    read leaving_date
    if [[ -z "$leaving_date" ]]; then
      echo -e "\033[31mError: Leaving date is required.\033[0m"
    elif ! [[ "$leaving_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      echo -e "\033[31mError: Invalid date format. Use YYYY-MM-DD.\033[0m"
    elif [[ "$leaving_date" < "$arrival_date" ]]; then
      echo -e "\033[31mError: Leaving date must be after arrival date.\033[0m"
    else
      break
    fi
  done

  # Confirm booking and save to file
  echo -e "\033[32mBooking confirmed!\033[0m"
  echo "$username,$destination,$address,$contact,$email,$guests,$arrival_date,$leaving_date" >> "$BOOKINGS_FILE"
  press_enter
}


manage_destinations() {
  while true; do
    clear
    centered_heading "~~MANAGE DESTINATIONS~~"
    echo -e "\033[33m1. View Destinations\033[0m"
    echo -e "\033[33m2. Add a New Destination\033[0m"
    echo -e "\033[33m3. Update an Existing Destination\033[0m"
    echo -e "\033[33m4. Delete a Destination\033[0m"
    echo -e "\033[33m5. Back to Admin Menu\033[0m"
    echo -n "Enter your choice: "
    read choice

    case $choice in
      1)  # View all destinations
          view_destinations
          press_enter
          ;;
      2)  # Add a new destination
          echo -n "Enter the name of the new destination: "
          read new_destination
          echo -n "Enter the price per head for $new_destination: "
          read new_price
          if [[ "$new_price" =~ ^[0-9]+$ ]]; then
            echo "$new_destination,$new_price" >> "$DESTINATIONS_FILE"
            echo -e "\033[32mDestination added successfully!\033[0m"
          else
            echo -e "\033[31mInvalid price format. Please enter a number.\033[0m"
          fi
          press_enter
          ;;
      3)  # Update an existing destination
          view_destinations
          echo -n "Enter the name of the destination to update: "
          read update_destination
          if grep -q "^$update_destination," "$DESTINATIONS_FILE"; then
            echo -n "Enter the new price for $update_destination: "
            read new_price
            if [[ "$new_price" =~ ^[0-9]+$ ]]; then
              sed -i "s/^$update_destination,.*/$update_destination,$new_price/" "$DESTINATIONS_FILE"
              echo -e "\033[32mDestination updated successfully!\033[0m"
            else
              echo -e "\033[31mInvalid price format. Please enter a number.\033[0m"
            fi
          else
            echo -e "\033[31mDestination not found.\033[0m"
          fi
          press_enter
          ;;
      4)  # Delete a destination
          view_destinations
          echo -n "Enter the name of the destination to delete: "
          read delete_destination
          if grep -q "^$delete_destination," "$DESTINATIONS_FILE"; then
            sed -i "/^$delete_destination,/d" "$DESTINATIONS_FILE"
            echo -e "\033[32mDestination deleted successfully!\033[0m"
          else
            echo -e "\033[31mDestination not found.\033[0m"
          fi
          press_enter
          ;;
      5)  # Return to admin menu
          admin_menu
          ;;
      *)  # Invalid input
          echo -e "\033[31mInvalid option. Please try again.\033[0m"
          press_enter
          ;;
    esac
  done
}



# Call the main menu function
main_menu
