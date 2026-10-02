#!/bin/bash

MAX_ATTEMPTS=3
ZIP_FILE="future_folder.zip"

# Global frame counter to keep the flag waving smoothly across screen updates
FLAG_FRAME=0

# Always on top: Displays a shifting wave pattern for the USA flag canvas
display_graphic() {
    clear
    local BLUE='\033[0;37;44m'     
    local RED='\033[0;37;41m'      
    local WHITE='\033[0;30;47m'    
    local RESET='\033[0m'          
    
    # Calculate offsets dynamically based on the global frame counter
    local offset1=$(( FLAG_FRAME % 3 ))
    local offset2=$(( (FLAG_FRAME + 1) % 3 ))
    local offset3=$(( (FLAG_FRAME + 2) % 3 ))
    
    # If the frame is 0 (initial state), force all offsets to 0 for a perfect straight frame alignment
    if [ $FLAG_FRAME -eq 0 ]; then
        offset1=0
        offset2=0
        offset3=0
    fi

    # Render flag canvas with precise formatting strings to prevent edge distortion
    if [ $offset1 -gt 0 ]; then printf "%${offset1}s" ""; fi; echo -e "${BLUE} * * * * * * * ${RED}====================================${RESET}"
    if [ $offset2 -gt 0 ]; then printf "%${offset2}s" ""; fi; echo -e "${BLUE}  * * * * * *  ${WHITE}====================================${RESET}"
    if [ $offset3 -gt 0 ]; then printf "%${offset3}s" ""; fi; echo -e "${BLUE} * * * * * * * ${RED}====================================${RESET}"
    if [ $offset2 -gt 0 ]; then printf "%${offset2}s" ""; fi; echo -e "${BLUE}  * * * * * *  ${WHITE}====================================${RESET}"
    if [ $offset1 -gt 0 ]; then printf "%${offset1}s" ""; fi; echo -e "${RED}===================================================${RESET}"
    if [ $offset2 -gt 0 ]; then printf "%${offset2}s" ""; fi; echo -e "${WHITE}===================================================${RESET}"
    if [ $offset3 -gt 0 ]; then printf "%${offset3}s" ""; fi; echo -e "${RED}===================================================${RESET}"
    echo ""
}

# Replaced with the original persistent $$$ graphics display header content
print_flag_frame() {
    echo -e "\033[1;32m" # Vibrant green color for money symbols
    echo '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
    echo '$$$                                                              $$$'
    echo '$$$                    [ ACCESS INTERFACE ]                      $$$'
    echo '$$$                                                              $$$'
    echo '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
    echo -e "\033[1;36m       [ SYSTEM SECURITY INTERFACE // MAIN ACCESS ]       \033[0m"
    echo ""
}

# Loop-based flashing sequence for incorrect input
display_error_banner() {
    for blink in {1..10}; do
        # Increment frame counter here to trigger a wave frame transformation
        FLAG_FRAME=$(( (FLAG_FRAME + 1) % 8 ))
        display_graphic
        print_flag_frame
        sleep 0.3
        
        FLAG_FRAME=$(( (FLAG_FRAME + 1) % 8 ))
        display_graphic
        echo -e "\033[1;31m[!] INCORRECT ACCESS KEY DETECTED [!]\033[0m"
        echo ""
        sleep 0.3
    done
}

# Simulates a shifting wave pattern animation block for success routine
display_waving_flag() {
    # Cycles displacements across 8 animation iterations
    for frame in {1..8}; do
        FLAG_FRAME=$(( (FLAG_FRAME + 1) % 8 ))
        display_graphic
        echo -e "\033[1;32m[✓] SUCCESS: CREATING UNLOCK SIGNAL...\033[0m\n"
        sleep 0.25
    done
}

# Boris Intro Sequence
clear
echo "Initializing secure connection..."
sleep 0.8
echo "Bypassing mainframe relays..."
sleep 0.8

if [ ! -f "$ZIP_FILE" ]; then
    echo -e "\033[1;31m[!] Error: \$ZIP_FILE not found in this folder.\033[0m"
    exit 1
fi

for ((i=1; i<=MAX_ATTEMPTS; i++))
do
    # Keeps FLAG_FRAME static at 0 so it stays perfectly aligned while waiting for input
    FLAG_FRAME=0
    display_graphic
    echo -e "\033[1;33m--- SECURITY ATTEMPT $i OF $MAX_ATTEMPTS ---\033[0m"
    echo ""
    
    read -s -p "Enter Access Password: " user_password
    echo "" 
    
    # --- DEV DEBUG PRINT ---
    echo -e "\033[1;34m[DEBUG] Checking string match:\033[0m"
    echo " -> Password Value: $user_password"
    echo " -> Zip Target:     $ZIP_FILE"
    echo " ---------------------------------------"
    sleep 1  
    
    unzip -p -P "$user_password" "$ZIP_FILE" &>/dev/null
    UNZIP_STATUS=$?
    echo " -> Unzip Exit Code: $UNZIP_STATUS (0 means success)"
    echo ""
    sleep 1 
    
    if [ $UNZIP_STATUS -eq 0 ]; then
        # Play flag-waving routine safely nested underneath the graphic header
        display_waving_flag
        clear
        # Reset to beautiful flat alignment on final access granted panel
        FLAG_FRAME=0
        display_graphic
        echo -e "\033[1;32m"
        echo "========================================================="
        echo "           ACCESS GRANTED. DECRYPTION SYSTEM ONLINE.     "
        echo "========================================================="
        echo -e "\033[0m"
        echo "“I am invincible!”"
        echo "Extracting files..."
        echo ""
        
        unzip -q -P "$user_password" "$ZIP_FILE"
        echo -e "\033[1;32m[✓] Success! Target folder has been cleanly unlocked.\033[0m"
        exit 0
    else
        # Run flashing alert sequences
        display_error_banner
        clear
        FLAG_FRAME=0
        display_graphic
        echo -e "\033[1;31m\n[*] ERROR: NATALYA BYPASS DETECTED. ATTEMPT BLOCKED.\033[0m"
        echo "Resetting array in 4 seconds..."
        sleep 4
    fi
done

# Failure sequence
clear
FLAG_FRAME=0
display_graphic
echo -e "\033[1;31m"
echo "========================================================="
echo "                  TERMINAL LOCKED                        "
echo "========================================================="
echo -e "\033[0m"
echo "“Bye, try later.”"
echo ""
sleep 2
clear
exit 1

