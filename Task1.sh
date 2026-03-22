#!/usr/bin/bash 

LOG_FILE="system_monitor_log.txt" 

log_adminactions() {
    local action="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ADMIN] $action" >> "$LOG_FILE"
}


system_usage() {
    echo "Current CPU and Memory Usage"
    top -bn1 
    echo 

    echo 
    free -h 
    echo
    log_adminactions "System CPU and Memory Usage shown"
}

 
top_processes() {
    echo "Top 10 Current Memory Processes"
    ps -eo pid,user,%cpu,%mem --sort=-%mem | head -n 11 
    echo 
    log_adminactions "Top 10 memory processes shown"
}


terminate_a_process() {
    read -p "Enter PID of process to terminate: " PID
    [[ -z "$PID" ]] && { echo "No PID has been chosen. "; return; }

    PID_USER=$(ps -p "$PID" -o user= 2>/dev/null)

    if [[ -z "$PID_USER" ]]; then
        echo "PID $PID wasn't found."
        return
    fi

    if [[ "$PID_USER" == "root" ]]; then
        echo "Not executed: PID $PID is a crictical system."
        return
    fi

    read -p "Are you sure you want to terminate PID $PID? [y/n] " Option
    if [[ "$Option" =~ ^[yY]$ ]]; then
        if kill "$PID" 2>/dev/null; then
            echo "Process $PID has been terminated."
            log_adminactions "Terminated PID $PID (user: $PID_USER)"
        else
            echo "terminating of $PID can't be executed."
        fi
    else
        echo "Termination won't take place anymore"
    fi
    echo
}

check_archive_dir() {
    if [[ ! -d "ArchiveLogs" ]]; then
        mkdir -p "ArchiveLogs"
        log_adminactions "ArchiveLogs directory has ben created"
        echo "ArchiveLogs directory has ben created"
    fi
} 

check_archive_size() {
    local size=$(du -sh "ArchiveLogs" 2>/dev/null | cut -f1 || echo "0")
    if [[ "$size" > "1G" ]]; then
        echo "WARNING! ArchiveLogs ($size) currently exceeds 1GB"
        log_adminactions "WARNING! ArchiveLogs ($size) currently exceeds 1GB"
    fi 
} 

disk_inspection() {
    echo "Disk Usage"
    du -sh /mnt/c/Users/willi/.vscode/Coding
    echo

    echo "Log Files Larger Than 50MB"
    sudo find /mnt/c/Users/willi -type f -name "*.log" -size +50M || echo "No Large Logs Files Found."
    echo 

    check_archive_dir
    check_archive_size

    sudo find /mnt/c/Users/willi -type f -name "*.log" -size +50M 2>/dev/null | while IFS= read -r log_file; do
        if [[ -f "$log_file" ]]; then
            timestamp=$(date +%Y%m%d_%H%M%S)
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
    if [[ -f "system_monitor_log.txt" ]]; then
        echo "Admin Actions"
        cat "system_monitor_log.txt"
    else
        echo "No log file found."
    fi
    echo
}


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
    touch "$LOG_FILE"
    printf "\033c"
    while true; do
        display_menu
        read -p "Select from option 1-6 and then press enter: " choice
        
        case $choice in
            1) system_usage;;
            2) top_processes;;
            3) terminate_a_process;;
            4) disk_inspection;;
            5) admin_logs;; 
            6) 
                read -p "Are you sure you want to exit? [y/n] " options
                [[ "$options" =~ ^[yY]$ ]] && {
                    exit 0
                }
                ;;
            *) echo "Invalid option!"; read -p "";;

        esac
    read -p $'\nPress Enter to go back to menu'
    done
}

main

