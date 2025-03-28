#!/bin/bash

# Enhanced Password Generator with Animation
# by anoraK

# Animation settings
FLIP_DELAY=0.05
CYCLES=3

# Hide cursor
tput civis
clear

# ASCII art headers
echo -e "\e[36m
██████╗ ██╗    ██╗██████╗  ██████╗ ███████╗███╗   ██╗
██╔══██╗██║    ██║██╔══██╗██╔════╝ ██╔════╝████╗  ██║
██████╔╝██║ █╗ ██║██║  ██║██║  ███╗█████╗  ██╔██╗ ██║
██╔═══╝ ██║███╗██║██║  ██║██║   ██║██╔══╝  ██║╚██╗██║
██║     ╚███╔███╔╝██████╔╝╚██████╔╝███████╗██║ ╚████║
╚═╝      ╚══╝╚══╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝
\e[0m"

echo -e "\e[33m
              █████╗ ███╗   ██╗ ██████╗ ██████╗  █████╗ ██╗  ██╗
             ██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔══██╗██║ ██╔╝
             ███████║██╔██╗ ██║██║   ██║██████╔╝███████║█████╔╝ 
             ██╔══██║██║╚██╗██║██║   ██║██╔══██╗██╔══██║██╔═██╗ 
             ██║  ██║██║ ╚████║╚██████╔╝██║  ██║██║  ██║██║  ██╗
             ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
\e[0m"

# Function to get validated input
get_input() {
  local prompt="$1"
  local default="$2"
  local min="$3"
  local max="$4"
  local input
  
  while true; do
    read -p "$prompt (default: $default): " input
    input=${input:-$default}
    
    if [[ "$input" =~ ^[0-9]+$ ]] && (( input >= min )) && (( input <= max )); then
      echo "$input"
      break
    else
      echo -e "\e[31mPlease enter a number between $min and $max\e[0m"
    fi
  done
}

# Get password length
length=$(get_input "Enter password length" 12 4 64)

# Character sets
lower="abcdefghijklmnopqrstuvwxyz"
upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
digits="0123456789"
basic_symbols="!@#$%^&*"
advanced_symbols="-_=+[]{};:,.<>?/|~"

# Character type selection
echo -e "\n\e[34mSelect character types to include:\e[0m"
chars=""
while true; do
  # Lowercase
  read -p "Include lowercase letters? [Y/n] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Nn]$ ]] && chars+="$lower"
  
  # Uppercase
  read -p "Include uppercase letters? [Y/n] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Nn]$ ]] && chars+="$upper"
  
  # Numbers
  read -p "Include numbers? [Y/n] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Nn]$ ]] && chars+="$digits"
  
  # Basic symbols
  read -p "Include basic symbols (!@#$%^&*)? [Y/n] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Nn]$ ]] && chars+="$basic_symbols"
  
  # Advanced symbols
  read -p "Include advanced symbols (-_=+[]{};:,.<>?/|~)? [Y/n] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Nn]$ ]] && chars+="$advanced_symbols"
  
  # Verify at least one character type was selected
  if [ -n "$chars" ]; then
    break
  else
    echo -e "\e[31mError: You must select at least one character type!\e[0m"
  fi
done

# Function to generate random character
random_char() {
  echo -n "${chars:$((RANDOM % ${#chars})):1}"
}

# Animation function
animate_password() {
  local final_pass="$1"
  local pass_length=${#final_pass}
  local temp_pass=""
  
  # Initial random characters
  for ((i=0; i<pass_length; i++)); do
    temp_pass+=$(random_char)
  done
  
  # Animation cycles
  for ((cycle=0; cycle<CYCLES; cycle++)); do
    # Gradually reveal the password
    for ((pos=0; pos<pass_length; pos++)); do
      # Randomize some characters
      for ((i=pos; i<pass_length; i++)); do
        if (( RANDOM % 3 == 0 )); then  # 33% chance to flip each character
          temp_pass="${temp_pass:0:i}$(random_char)${temp_pass:i+1}"
        fi
      done
      
      # Gradually reveal correct characters
      if (( cycle == CYCLES-1 )); then
        temp_pass="${temp_pass:0:pos}${final_pass:pos:1}${temp_pass:pos+1}"
      fi
      
      # Display
      echo -ne "\r\e[32m${temp_pass}\e[0m"
      sleep "$FLIP_DELAY"
    done
  done
  
  # Final reveal
  echo -ne "\r\e[32m${final_pass}\e[0m"
  echo
}

# Generate final password
final_password=""
for ((i=0; i<length; i++)); do
  final_password+=$(random_char)
done

# Run animation
echo -e "\nGenerating your custom password..."
animate_password "$final_password"

# Calculate password strength
score=0
(( length >= 8 )) && (( score++ ))
(( length >= 12 )) && (( score++ ))
(( length >= 16 )) && (( score++ ))
[[ "$chars" =~ [a-z] ]] && (( score++ ))
[[ "$chars" =~ [A-Z] ]] && (( score++ ))
[[ "$chars" =~ [0-9] ]] && (( score++ ))
[[ "$chars" =~ [!@#$%^&*] ]] && (( score++ ))
[[ "$chars" =~ [-_=+\[\]{};:,.<>?/|~] ]] && (( score++ ))

# Show password details
echo -e "\n\e[34mPassword Details:\e[0m"
echo -e "Length:    $length characters"
echo -e "Character set:"
[[ "$chars" =~ [a-z] ]] && echo -e " - Lowercase letters"
[[ "$chars" =~ [A-Z] ]] && echo -e " - Uppercase letters"
[[ "$chars" =~ [0-9] ]] && echo -e " - Numbers"
[[ "$chars" =~ [!@#$%^&*] ]] && echo -e " - Basic symbols"
[[ "$chars" =~ [-_=+\[\]{};:,.<>?/|~] ]] && echo -e " - Advanced symbols"

# Show strength rating
echo -ne "Strength:  "
case $score in
  [0-3]) echo -e "\e[31m★☆☆☆☆ Weak\e[0m" ;;
  [4-5]) echo -e "\e[33m★★★☆☆ Moderate\e[0m" ;;
  [6-7]) echo -e "\e[36m★★★★☆ Strong\e[0m" ;;
  *)     echo -e "\e[32m★★★★★ Very Strong\e[0m" ;;
esac

# Offer to copy to clipboard
if command -v xclip &> /dev/null; then
  read -p "Copy to clipboard? [Y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo -n "$final_password" | xclip -selection clipboard
    echo "Password copied to clipboard!"
  fi
elif command -v pbcopy &> /dev/null; then
  read -p "Copy to clipboard? [Y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo -n "$final_password" | pbcopy
    echo "Password copied to clipboard!"
  fi
fi

# Restore cursor
tput cnorm

echo -e "\nPress any key to exit..."
read -n 1 -s
clear
