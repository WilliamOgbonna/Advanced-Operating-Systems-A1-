import os
import sys
import time
import shutil
import subprocess
from pathlib import Path
from datetime import datetime

#Creating Log an directory paths 
SUBMISSIONS_LOGS = "submission_log.txt"
CURRENT_DIR = Path(r"C:\Users\willi\.vscode\Coding\Github\Advanced-Operating-Systems-A1-")
ASSIGNMENTS_SUBMITTED = Path(r"C:\Users\willi\.vscode\Coding\Github\Advanced-Operating-Systems-A1-\Submitted_Assignments")
ASSIGNMENTS_SUBMITTED.mkdir(exist_ok=True) 


#Logging events with timestamps to submission logs
def log_subactions(action):
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(SUBMISSIONS_LOGS, 'a') as f:
        f.write(f"{timestamp} [ADMIN] {action}\n")

def login_attempt():
    print("---------------------------------------------------------------------")
    
    ATTEMPTS_LIMIT = 4
    ATTEMPT_DUR = []
    CURRENT_ATTEMPT = 1

    #Ensures the user still has login attempts
    while CURRENT_ATTEMPT <= ATTEMPTS_LIMIT:
        #User inputs username and password 
        username = input("Please Enter your Username, when done press Enter: ").strip()
        password = input("Please Enter your Password, when done press Enter: ").strip()
        
        print("Verifying...")
        #Checks user inputted details against defined login details 
        if username == "student1" and password == "Password2!":
            print("You're now logged in")
            log_subactions("User logged in")
            return
        else:
            #Alerts User of incorrect details and login attempts 
            print("Password Or Username incorrect, please try again")
            log_subactions(f"Failed login attempt no. {CURRENT_ATTEMPT}")
            print(f"Total Allowed Attempts: {CURRENT_ATTEMPT} of 3")
            
            #Creates timestamp variable 
            current_time = datetime.now()

            #Creates a seconds timestamp variable 
            epoch_time = int(current_time.timestamp())
            ATTEMPT_DUR.append(epoch_time)
            
            #Checks for 3 time entries in array
            if len(ATTEMPT_DUR) == 3:
                #Checks if total seconds in a minute or less 
                if ATTEMPT_DUR[2] - ATTEMPT_DUR[0] <= 60:
                    print("Suspicious activity has been detected")
                    log_subactions("User had three login attempts within a minute")
                
                ATTEMPT_DUR = []
                
            #Increment attempts 
            CURRENT_ATTEMPT += 1
    
    print("The login attempt limit has been reached, You have been locked out")
    log_subactions("User has been locked out due to login attempt limit")
    #Terminates program as a lock out 
    sys.exit(1)

def submit_file():
    if not ASSIGNMENTS_SUBMITTED.exists():
        print("There is no active directory to submit assignments")
        log_subactions("No active directory to submit assignments was found")
        return
    
    student_id = input("Please enter your StudentID (number below 10000): ").strip()
    
    #Checks user input isnt empty
    if not student_id:
        print("The studentID input cannot be empty, please try again")
        log_subactions("Submission cancelled due to empty entry from user")
        return
    #Checks user input is an integer
    elif not student_id.isdigit():
        print("The studentID input must be an integer, please try again")
        log_subactions("Submission cancelled due to non-integer entry from user")
        return
    #checks user input ID is below 10000
    elif int(student_id) > 10000:
        print("The studentID input must be under 10000, please try again")
        log_subactions("Submission cancelled due to invalid range")
        return
    else:
        print("StudentID is valid")
    #Creates filepath variables using user inputted file 
    file_name = input("Type the file name (including .pdf or .docx): ").strip()
    file_path = CURRENT_DIR / file_name
    dest_file = ASSIGNMENTS_SUBMITTED / file_name
    
    # Checks if file exists in the directory
    if not file_path.exists():
        print("File does not exist in the current directory")
        log_subactions("File not found in directory")
        return
    
    print("File has been found in the directory")
    
    #Checks if a file with the same name exists 
    if dest_file.exists():
        print("File with the same name already exists")
        log_subactions(f"Submission cancelled of {file_name} for StudentID {student_id} due to duplicate name")
        return
    
    #Checks the file is the correct type 
    if not (file_name.lower().endswith('.pdf') or file_name.lower().endswith('.docx')):
        print("File type uploaded is not supported")
        log_subactions(f"Submission cancelled of {file_name} for StudentID {student_id} due to unsupported file type")
        return
    
    #Gets file size 
    #checks if file size is above 5 
    file_size_mb = file_path.stat().st_size / (1024 * 1024)
    if file_size_mb > 5:
        print("File is over 5MB")
        log_subactions(f"Submission cancelled of {file_name} for StudentID {student_id} due to Large file")
        return
    
    #
    try:
        #reading file content 
        with open(file_path, 'rb') as f1:
            file_content1 = f1.read()
        
        for existing_file in ASSIGNMENTS_SUBMITTED.iterdir():
        #Ensure no file self checking
            if existing_file == file_path:
                continue
            with open(existing_file, 'rb') as f2:
                file_content2 = f2.read()
            #Checks to see if there is matching content 
            if file_content1 == file_content2:
                print("Another file with matching content has been found")
                log_subactions(f"Submission cancelled of {file_name} for StudentID {student_id} due to exact matching content")
                return
    except Exception as e:
        print("Error checking file content")
        return
    
    
    print(f"{file_name} is being uploaded")
    #Uploads file 
    shutil.copy2(file_path, ASSIGNMENTS_SUBMITTED)
    print(f"{file_name} has been uploaded")
    log_subactions(f"Submission of {file_name} for StudentID {student_id} has been completed")

def is_file_present():
    print("--------------------------------------------------------------------------------------")
    
    #User inputs file name 
    file_name = input("Please enter the full file name with the extension, when done press Enter: ").strip()
    
    #Checks that assignment directory exists 
    if not ASSIGNMENTS_SUBMITTED.exists():
        print("There is no active directory for assignments")
        log_subactions("There is no active directory for submitted assignments")
        return
    
    #Use user input to create filepath variable 
    file_path = CURRENT_DIR / file_name
    
    #Checks if file exists in filepath directory 
    if file_path.exists():
        print("File exists and has been found in the directory!")
        
        #checks if file has a duplicate 
        submitted_file = ASSIGNMENTS_SUBMITTED / file_name
        if submitted_file.exists():
            print("File with the same name has already exists")
            log_subactions("File with submission to duplicate name")
        else:
            print("No files currently have a matching name")
            log_subactions("No Files with duplicate names have been found")
    else:
        print("This file was not found")

def list_files():
    #Checks if assignment directory doesn't exist 
    if not ASSIGNMENTS_SUBMITTED.exists():
        print("There is no active directory for assignments")
        log_subactions("There is no active directory for submitted assignments")
        return
    else:
        print("All Submitted Files")
        #Displays All Submitted Files 
        for file in ASSIGNMENTS_SUBMITTED.iterdir():
            print(file.name)

def show_submission_logs():
    #Checks if submission logs file exists
    if os.path.exists(SUBMISSIONS_LOGS):
        print("Submission Log")
        with open(SUBMISSIONS_LOGS, 'r') as f:
            #Displays all logs in txt file
            print(f.read())
        log_subactions("Submission Logs Accessed")
    else:
        print("There are no current submission logs found. One will be made shortly")
        #Creates submission logs if not present
        Path(SUBMISSIONS_LOGS).touch() 
        log_subactions("New submission log file made after none was found.")

def display_menu():

    def clear_screen():
        os.system('cls' if os.name == 'nt' else 'clear') 
    
    print("-------------------------------------------------------")
    print("Secure Examination Submission and Access Control System")
    print("-------------------------------------------------------")
    print("1. Submit An Assignment")
    print("2. Check If File Has Been Submitted")
    print("3. List All Submitted Files")
    print("4. View All Submission Logs")
    print("5. Exit")
    print("-------------------------------------------------------")

def main():
    # Ensure submission log file exists
    Path(SUBMISSIONS_LOGS).touch()
    
    while True:
        display_menu()
        choice = input("Select from option 1-5 and then press enter: ").strip()
        
        if choice == '1':
            submit_file()
        elif choice == '2':
            is_file_present()
        elif choice == '3':
            list_files()
        elif choice == '4':
            show_submission_logs()
        elif choice == '5':
            #exit confirmation options 
            confirm = input("Are you sure you want to exit? [y/n]: ").strip().lower()
            if confirm in ['y', 'yes']:
                sys.exit(0)
        else:
            print("Invalid option!")
        
        input("\nPress Enter to go back to menu...")

if __name__ == "__main__":
    login_attempt()
    main()


