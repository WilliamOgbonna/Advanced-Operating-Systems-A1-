#!/usr/bin/bash 

#Creating Log file
LOG_FILE="system_monitor_log.txt" 

log_adminactions() {
    local action="$1"
    #Stores log file with date stamp 
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ADMIN] $action" >> "$LOG_FILE"
}


system_usage() {
    echo "Current CPU and Memory Usage"
    #Display System Usage in one batch interaction 
    top -bn1 
    echo 

    echo "Memory"
    #Display Memory Available
    free -h 
    echo
    log_adminactions "System CPU and Memory Usage shown"
}

 
top_processes() {
    echo "Top 10 Current Memory Processes"
    #Shows The Top 10 processes with pid, user, cpu and memory 
    ps -eo pid,user,%cpu,%mem --sort=-%mem | head -n 11 
    echo 
    log_adminactions "Top 10 memory processes shown"
}


terminate_a_process() {
    #User Input for PID option
    read -p "Enter PID of process to terminate: " PID
    #Making sure input isn't blank 
    [[ -z "$PID" ]] && { echo "No PID has been chosen. "; return; }
    
    #Finding Associated User In Input
    PID_USER=$(ps -p "$PID" -o user= 2>/dev/null)

    #Makes Inputted PID is valid
    if [[ -z "$PID_USER" ]]; then
        echo "PID $PID wasn't found."
        return
    fi
    #Checking User type for critical system protection
    if [[ "$PID_USER" == "root" ]]; then
        echo "Not executed: PID $PID is a crictical system."
        return
    fi
    #User input confirmation for termination 
    read -p "Are you sure you want to terminate PID $PID? [y/n] " Option
    if [[ "$Option" =~ ^[yY]$ ]]; then
       #Terminate PID if user confirmed 
        if kill "$PID" 2>/dev/null; then
            echo "Process $PID has been terminated."
            log_adminactions "Terminated PID $PID (user: $PID_USER)"
        else
           #Output if termination denied
            echo "terminating of $PID can't be executed."
        fi
    else
       #Output if not confirmed
        echo "Termination won't take place anymore"
    fi
    echo
}

check_archive_dir() {
    #Checks if Arhcive Logs Exist 
    if [[ ! -d "ArchiveLogs" ]]; then
        #Makes An Archived Logs If there isn't one 
        mkdir -p "ArchiveLogs"
        log_adminactions "ArchiveLogs directory has been created"
        echo "ArchiveLogs directory has been created"
    fi
} 

check_archive_size() {
    #Gets the total size of the Archived Logs
    local size=$(du -sh "ArchiveLogs" 2>/dev/null | cut -f1 || echo "0")
    #Checks if Arhcived Logs has reached 1G and Sends A Warning if so 
    if [[ "$size" > "1G" ]]; then
        echo "WARNING! ArchiveLogs ($size) currently exceeds 1GB"
        log_adminactions "WARNING! ArchiveLogs ($size) currently exceeds 1GB"
    fi 
} 

disk_inspection() {
    echo "Disk Usage"
    #Display Disk Space For Specified Directory 
    du -sh /mnt/c/Users/willi/.vscode/Coding
    echo
    
    echo "Log Files Larger Than 50MB"
    #Find Directory Files oVer 50MB
    sudo find /mnt/c/Users/willi -type f -name "*.log" -size +50M || echo "No Large Logs Files Found."
    echo 

    check_archive_dir
    check_archive_size

    #Finds Files Above 50MB
    sudo find /mnt/c/Users/willi -type f -name "*.log" -size +50M 2>/dev/null | while IFS= read -r log_file; do
        if [[ -f "$log_file" ]]; then
            #Create timestamp variable 
            timestamp=$(date +%Y%m%d_%H%M%S)
            #Compresses File & Removes Original File
            archive_name="${log_file##*/}_${timestamp}.zip"
            sudo zip -q "ArchiveLogs/$archive_name" "$log_file" && \
            sudo rm "$log_file" && \
            echo "Archived: $archive_name"
            log_adminactions "Archived log file: $log_file converted to ArchiveLogs/$archive_name"
        fi
    done
    
    log_adminactions "Disk inspection and log archiving done."
}


admin_logs() {
    #Checks if there is a monitor_log.txt file 
    if [[ -f "system_monitor_log.txt" ]]; then
        echo "Admin Actions"
        #Displays Logs 
        cat "system_monitor_log.txt"
    else
        echo "No log file found."
    fi
    echo
}

#User Menu
display_menu() {
    printf "\033c"
    clear
    echo "--------------------------------------------------------------"
    echo "University Data Centre Process and Resource Management System "
    echo "--------------------------------------------------------------"
    echo "1. Current CPU and Memory Usage"
    echo "2. Top 10 Current Memory Processes"
    echo "3. Terminate A Process"
    echo "4. Disk Usage & Log Archiving"
    echo "5. View Admin Logs"
    echo "6. Exit"
    echo "--------------------------------------------------------------"
}


main() {
    #Creating log file upon program start 
    touch "$LOG_FILE"
    printf "\033c"

    while true; do
        display_menu
        #get user inputted menu option 
        read -p "Select from option 1-6 and then press enter: " choice
        #get function calls based on user option 
        case $choice in
            1) system_usage;;
            2) top_processes;;
            3) terminate_a_process;;
            4) disk_inspection;;
            5) admin_logs;; 
            6) 
            #Gets User Exit Option
                read -p "Are you sure you want to exit? [y/n] " options
                [[ "$options" =~ ^[yY]$ ]] && {
                    exit 0
                }
                ;;
            *) echo "Invalid option!"; read -p "";;

        esac
        #output if invalid options is entered 
    read -p $'\nPress Enter to go back to menu'
    done
}

main

