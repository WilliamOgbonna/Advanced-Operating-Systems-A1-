#!/usr/bin/bash 

#Creating log files for jobs and scheduling 
SCHEDULERS_LOG="scheduler_log.txt"
PENDING_JOBS="job_queue.txt" 
COMPLETED_JOBS="completed_jobs.txt"


#Function for creating timestamped logs for scheduling 
log_actions() {
    local action="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ADMIN] $action" >> "$SCHEDULERS_LOG" 
} 


show_pending_jobs(){
    # If the job queue file is found, then output its information
    if [[ -f "job_queue.txt" ]]; then
        echo "Pending Jobs"
        cat "job_queue.txt"
        log_actions "Pending Jobs Logs Accessed"
    else
        #Output if no file found
        echo "No current pending jobs file is found. One will be made shortly"
        #Creating a job queue file incase none is present 
        touch "$PENDING_JOBS"
        log_actions "New Pending jobs file made after none was find."
        return
    fi
    echo


}

submit_request() {
    #get user-inputted job information 
    read -rp "Enter your student ID, must be below 10000, done press Enter: " id
    read -rp "Enter your job name, when done press Enter: " jobname
    read -rp "Enter the job execution time, in seconds, when done press Enter: " exetime
    read -rp "Enter the priority of the job, from 1 to 10 (ascending), when done press Enter: " priority

    # Making sure no inputs are blank
    if [[ -z "$id" ]] || [[ -z "$jobname" ]] || [[ -z "$exetime" ]] || [[ -z "$priority" ]]; then
    echo "No options can be blank, please try again!" 
    log_actions "Job request cancelled due to blank entries"
    return 
    
    #Making sure no StudentID is over 10000
    elif [[ "$id" -gt 10000 ]]; then
    echo "ID input has to be under 10000, please try again!" 
    log_actions "Job request cancelled due to invalid student ID"
    return 

    #Making sure integers inputs are inputted where needed 
    elif [[ -n "${id//[0-9]/}" || -n "${exetime//[0-9]/}" || -n "${priority//[0-9]/}" ]]; then
    echo "Ensure all integer inputs are correctly put, please try again!" 
    log_actions "Job request cancelled due to invalid integer input"
    return 
    
    #Making sure the priority is in the range of 1-10
    elif [[ "$priority" -gt 10 || "$priority" -lt 1 ]]; then
    echo "ID input has to be over 1000, please try again!" 
    log_actions "Job request cancelled due to invalid student ID"
    return 

    else 
    #Confirmation message for job submission 
    echo "Job Sumbiited, StudentID:" "$id" " Job:" "$jobname" "Execution Time:" "$exetime" "Priority:" "$priority"
    
    #storing the user inputs into schedulers and pending job logs 
    msg="$id, $jobname, $exetime, $priority"
    printf "%s %s\n" "$msg" >> "$PENDING_JOBS"
    printf "%s %s\n" "$(date '+%Y -%m -%d %H:%M:%S')" "$msg" "Priority Scheduling" >> "$SCHEDULERS_LOG"
    fi

}

    

process_job_queue() {

    #User inputs their studentID for search
    read -rp "Enter your student ID, when done press Enter: " id 
    
    #Searches pending job logs to find StudentID and the outputs applicable message to user
    if grep -q "$id" job_queue.txt;  then
    echo "The StudentID is currently in the job queue" 
    echo "The job queue will start shortly, this queue is based off priority of the job"
    log_actions "Job queue has been initiated"

    #Sorts the pending job logs based on priority numbers 
    #Reads through job_queue.txt to get studentID, Job, Execution Time & Priority
    sort -t, -k4,4nr "$PENDING_JOBS" | tr -d "\r" | \
    while IFS=',' read -r id jobname exetime priority; do
        #Outputs a message while in progress
        echo "Currently proccesing job" 

        #Acts As Execution Time Delay

        sleep "$exetime"

        #Conformation message for completing job
        echo "StudentID $id - Job: $jobname has been completed" 
    done 
    #Confirmation message for completing all jobs
    echo "All jobs have been completed" 
    
    #Moving information from pending to completed job logs
    cp "$PENDING_JOBS" "$COMPLETED_JOBS"
    echo "Current jobs queue transfered to completed job logs"
    log_actions "Current jobs queue transfered from pending jobs to completed jobs logs"
    
    #Removing information from pending jobs (like a refresh)
    > "$PENDING_JOBS"
    echo "Pending Job log has been cleared"
    log_actions "Pending Job has been cleared"

    else 

    #Output for studnetID that isnt found in pending jobs 
    echo "The StudentID isn't in the job queue, please try again"
    log_actions "Job wasn't processed, The StudentID isn't in the Pending Jobs Log"
    return 

    fi
    
}


show_completed_jobs() {
    
    #If Compeleted jobs log is found then output its information
    if [[ -f "completed_jobs.txt" ]]; then
        echo "All Completed Jobs"
        cat "completed_jobs.txt"
        log_actions "Completed Jobs Logs Accessed"
    else
        #Output if no file is found 
        echo "No current completed jobs file is found. One will be made shortly"
        
        #Creating a completed jobs file incase none is present
        touch "$COMPLETED_JOBS"
        log_actions "New Completed jobs file made after none was find."
        return
    fi
    echo

}

show_schedule_logs() {
    #If Schedulers log is found then output its information
    if [[ -f "scheduler_log.txt" ]]; then
        echo "Scheduler Logs"
        cat "scheduler_log.txt"
        log_actions "Scheduler Logs Accessed"
    else
        #Output if no file is found
        echo "No current schedular file is found. One will be made shortly"
        
        #Creating a completed jobs file incase none is present
        touch "$SCHEDULERS_LOG"
        log_actions "New Schedulers Log file made after none was find."
    fi
    echo
}

#Menu 
display_menu() {
    printf "\033c"  
    echo "-----------------------------------------------------"
    echo "University High Performance Computing Job Scheduler "
    echo "-----------------------------------------------------"
    echo "1. View Pending Jobs"
    echo "2. Submit A Job Request"
    echo "3. Process A Job Queue Using Priority Scheduling"
    echo "4. View Completed Jobs"
    echo "5. View Job Schedule Logs"
    echo "6. Exit"
    echo "-----------------------------------------------------"
}

main() {

    #Creating all the files needed upon porgram start 
    touch "$JOB_QUEUE"
    touch "$SCHEDULERS_LOG"
    touch "$COMPLETED_JOBS"

    printf "\033c"
    while true; do
        display_menu
        #Menu option input
        read -p "Select from option 1-6 and then press enter: " choice
        
        case $choice in
            1) show_pending_jobs;;
            2) submit_request;;
            3) process_job_queue;;
            4) show_completed_jobs;;
            5) show_schedule_logs;; 
            6) 
                #readn user exit input and either exits or stays
                read -p "Are you sure you want to exit? [y/n] " options
                [[ "$options" =~ ^[yY]$ ]] && {
                    exit 0
                }
                ;;
            #Output if none of the options where inputted
            *) echo "Invalid option!"; read -p "";;

        esac
    read -p $'\nPress Enter to go back to menu'
    done
}

main
