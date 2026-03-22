#!/bin/bash 

SUBMISSIONS_LOGS="submission_log.txt"
CURRENT_DIR="/mnt/c/Users/willi/.vscode/Coding/Github/Advanced-Operating-Systems-A1-"
ASSIGNMENTS_SUBMITTED="/mnt/c/Users/willi/.vscode/Coding/Github/Advanced-Operating-Systems-A1-/Submitted_Assignments"
mkdir -p "$ASSIGNMENTS_SUBMITTED"


log_subactions(){
 local action="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ADMIN] $action" >> "$SUBMISSIONS_LOGS"
}

login_attempt() {
  echo "---------------------------------------------------------------"

  ATTEMPTS_LIMIT=4
  ATTEMPT_DUR=()
  CURRENT_ATTEMPT=1

  while [[ "$ATTEMPTS_LIMIT" -gt "$CURRENT_ATTEMPT" ]]; do

  read -p "Please Enter your Username, when done press Enter " username
  read -p "Please Enter your Password, when done press Enter " password
  
  echo "Verifying"

    if [[ "$username" == "student1" && "$password" == "Password2!" ]]; then 
     
     echo "You're now logged in"
     log_subactions "User logged in"

     return 

   else 
      echo "Password Or Username incorrect, please try again"
      log_subactions "Failed login attempt no. $CURRENT_ATTEMPT"
      echo "Total Allowed Attempts: $CURRENT_ATTEMPT of 3" 

      ATTEMPT_DUR="$(date '+%Y-%m-%d %H:%M;%S')"

      EPOCH=$(date =%s)
      ATTEMPT_DUR+=("$EPOCH")

       if [[ ${#ATTEMPT_DUR[@]} -eq 3 ]]; then
         if ((ATTEMPT_DUR[2] - ATTEMPT_DUR[0] <= 60)); then
           echo "Suspicious activity has been detected"
           log_subactions "User had three login attempts within a minute"

          fi
      ATTEMPT_DUR=()
       fi
     fi

    ((CURRENT_ATTEMPT++))
  done

  echo "The login attempt limit has been reached, You hvae beebn locked out"
  log_subactions "User has been locked out due to log attempt limit"

  kill $$
}



submit_file() {



if [[ ! -d "$ASSIGNMENTS_SUBMITTED" ]]; then
    echo "There is no active directory to submit assignments"
    login_subactions "No active directory to submit assignments was found"
    return
fi


read -rp "Please enter your StudentID (number below 10000): " id


if [[ -z "$id" ]]; then
    echo "The studentID input cannot be empty, please try again"
    log_subactions "Submission cancelled due to empty entry from user"
    return


elif [[ -n ${id//[0-9]/} ]]; then
    echo "The studentID input must be an integer, please try again"
    log_subactions "Submission cancelled due to non-integer entry from user"
    return


elif [[ "$id" -gt 10000 ]]; then
    echo "The studentID input must be under 10000, please try again"
    log_subactions "Submission cancelled due to invalid range"
    return

else
    echo "StudentID is valid"
fi


read -r -p "Type the file name (including .pdf or .docx): " file

FILE_CHECK="$CURRENT_DIR/$file"
DEST_FILE="$ASSIGNMENTS_SUBMITTED/$file"



if [[ ! -f "$FILE_CHECK" ]]; then
    echo "File does not exist in the current directory"
    log_subactions "File not found in directory"
    return
fi

echo "File has been found in the directory"


if [[ -f "$DEST_FILE" ]]; then
    echo "File with the same name already exists"
    log_subactions "Submission cancelled of $file for StudentID $id due to duplicate name"
    return


elif [[ $file != *.pdf && $file != *.docx ]]; then
    echo "File type uploaded is not supported"
    log_subactions "Submission cancelled of $file for StudentID $id due to unsupported file type"
    return

else
   
    size=$(du -sm "$FILE_CHECK" | cut -f1)
    if (( size > 5 )); then
        echo "File is over 5MB"
        log_subactions "Submission cancelled of $file for StudentID $id due to large file"
        return
    fi
fi


no_spaces_file=$(tr -d '\000[:space:]' < "$FILE_CHECK" 2>/dev/null)

for existing in "$ASSIGNMENTS_SUBMITTED"/*; do
    [[ "$existing" == "$FILE_CHECK" ]] && continue

    no_spaces_all=$(tr -d '\000[:space:]' < "$existing" 2>/dev/null)

    if [[ "$no_spaces_file" == "$no_spaces_all" ]]; then
        echo "Another file with matching content has been found"
        log_subactions "Submission cancelled of $file for StudentID $id due to exact matching content"
        return
    fi
done


echo "$file is being uploaded"
cp "$FILE_CHECK" "$ASSIGNMENTS_SUBMITTED"

echo "$file has been uploaded"
log_subactions "Submission of $file for StudentID $id has been completed"


}

is_file_present() 
{
    echo "--------------------------------------------------------------------------------------"

  read -rp "Please enter the full file name with the extension, when done press Enter: " file

 if [[ ! -d "$ASSIGNMENTS_SUBMITTED" ]]; then
   echo "There is no active directory for assignments"
   log_subactions "There is no active directory for submitted assignments"
   return 
 fi 

 
 if [ -f "$CURRENT_DIR/$file" ]; then
    echo "File exists has been found in the directory!"
    
    if [[ -f "$ASSIGNMENT_SUBMITTED/$file" ]]; then 
      echo "File with the same name has already exists"
      log_subactions "Files with submission to duplicate name"
      return
    else
     echo "No files currently have a matching name"
     log_subactions "No Files with duplicate names have been found"
     return 

    fi
    else 
    echo "This file was not found"
 fi
}

list_files() {
  
   if [[ ! -d "$ASSIGNMENTS_SUBMITTED" ]]; then
      echo "There is no active directory for assignments"
      log_subactions "There is no active directory for submitted assignments"
      return 
   else 
      echo "All Submitted Files"
      ls $ASSIGNMENTS_SUBMITTED
   fi 

}


show_submission_logs() {
    
    if [[ -f "submission_log.txt" ]]; then
        echo "Submission Log"
        cat "submission_log.txt"
        log_subactions "Submission Logs Accessed"
    else
        
        echo "There are no current submission logs found. One will be made shortly"
        
        
        mkdir -p "$ASSIGNMENTS_SUBMITTED"
        log_subactions "New Schedulers Log file made after none was find."
    fi
    

}


display_menu() {
    printf "\033c"  
    echo "-------------------------------------------------------"
    echo "Secure Examination Submission and Access Control System"
    echo "-------------------------------------------------------"
    echo "1. Submit An Assignment"
    echo "2. Check If File Has Been Submitted"
    echo "3. List All Submitted Files"
    echo "4. View All Submission Logs"
    echo "5. Exit"
    echo "-------------------------------------------------------"
}

main() {

    
    touch "$SUBMISSIONS_LOGS"

    printf "\033c"
    while true; do
        display_menu
        
        read -p "Select from option 1-6 and then press enter: " choice
        
        case $choice in
            1) submit_file;;
            2) is_file_present;;
            3) list_files;;
            4) show_submission_logs;; 
            5) 
                
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

login_attempt
main


