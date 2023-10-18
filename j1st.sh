#!/bin/bash

if [ -t 0 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    ignored_files=()
    redundance=0
    verbose=0
    supress=0
    stop=0
    start=0
    filetostart=""
    arg=0
    argval=""
    edit=0
    argval_array=()
    usage=0
    rep=0
    requirefile=0
    logging=0
    viewlog=0
    logfile=""
    namespecifier=""
    # Function to add a filename to the ignore list
    add_to_ignore_list() {
        for arg in "$@"; do
            if ! grep -q -x "$arg" .j1st-ignore; then
            ignored_files+=("$arg")
            echo "$arg" >> .j1st-ignore
            echo -e "${BLUE}[IGNORED]${NC} - $arg"
            else
            echo -e "${YELLOW}[ALREADY IGNORED]${NC} - $arg"
            fi
        done
    }

    # Function to remove filenames from the ignore list
    remove_from_ignore_list() {
        local targets=("$@")

        # Create a temporary file to store the updated ignore list
        tmp_file=$(mktemp)
        > "$tmp_file" # Clear the temporary file

        for target in "${targets[@]}"; do
            if grep -q -x "$target" .j1st-ignore; then
            echo -e "${BLUE}[UN-IGNORED]${NC} - $target"
            else
            echo -e "${YELLOW}[ALREADY UN-IGNORED]${NC} - $target"
            fi
        done

        # Copy the contents of .j1st-ignore excluding the removed filenames to the temporary file
        grep -F -x -v -f <(printf '%s\n' "${targets[@]}") .j1st-ignore > "$tmp_file"

        # Replace .j1st-ignore with the temporary file
        mv "$tmp_file" .j1st-ignore
    }

    # Check if .j1st-ignore file exists; create if it doesn't
    if [ ! -e ".j1st-ignore" ]; then
        touch .j1st-ignore
    fi

    # Process command-line arguments
    while [ $# -gt 0 ]; do
    case "$1" in
        -i)
            shift # Remove the -i flag
            # Process and add remaining arguments to the ignore list
            redundance=1
            while [ $# -gt 0 ]; do
                if [[ "$1" == -* ]]; then
                break # Exit the loop when a flag is encountered
                fi
                add_to_ignore_list "$1"
                shift # Move to the next argument
            done
            ;;
        -u)
            shift # Remove the -u flag
            redundance=1
            while [ $# -gt 0 ]; do
                if [[ "$1" == -* ]]; then
                break # Exit the loop when a flag is encountered
                fi
                remove_from_ignore_list "$1"
                shift # Move to the next argument
            done
            ;;
        -v)
            shift # Remove the -v flag
            verbose=1;
            ;;
        -s)
            shift # Remove the -s flag
            supress=1;
            ;;
        -a)
            shift # Remove the -a flag
            arg=1;
            argval=$1
            requirefile=1
            IFS=" " read -ra argval_array <<< "$argval"
            shift
            ;;
        -e)
            shift # Remove the -e flag
            edit="+config";
            requirefile=1
            ;;
        -E)
            shift # Remove the -e flag
            edit="config!";
            requirefile=1
            ;;
        -p)
            shift # Remove the -e flag
            edit="prog";
            requirefile=1
            ;;
        -n)
            shift # Remove the -n flag
            name=`node -pe 'JSON.parse(process.argv[1]).environmentalVariables.nameSpecifier' "$(cat ~/.j1st/config.json)"`
            eval export $name=$1;
            namespecifier=$1
            requirefile=1
            shift
            ;;
        -r)
            shift # Remove the -r flag
            rep=1
            requirefile=1
            ;;
        -h)
            shift # Remove the -h flag
            usage=1
            ;;
        -l)
            shift
            logging=1
            logpath=$1
            requirefile=1
            shift
            ;;
        -L)
            shift
            viewlog=1
            logpath=$1
            requirefile=1
            shift
            ;;
        *)
            if [[ $start != 1 ]] && [[ ${1:0:1} != "-" ]]; then
                start=1
                filetostart=$1
            else
                usage=1
            fi
            shift # Move to the next argument
        ;;
    esac
    done
    if [[ $requirefile == 1 ]] && [[ $filetostart == "" ]]; then
        echo "The [file.js] parameter is required for this option!"
        echo
        usage=1
    fi
    if [[ $usage == 1 ]]; then
        echo "Usage: j1st [file.js] [options]"
        echo "Options:"
        echo "  -a [arguments]: Pass arguments into the JS file."
        echo "  -e: Edit the config while running the program."
        echo "  -E: Edit the config without running the program."
        echo "  -p: Edit the program itself."
        echo "  -n [specifier]: Specify name for the configuration file."
        echo "  -r: Enable repeat mode."
        echo "  -l [path]: Enable logging to a file. Optional path specifies log location."
        echo "  -L [path]: View the log file in the editor. Optional path specifies log to view."
        echo
        echo "Usage: j1st [options]"
        echo "Options:"
        echo "  -i [file1] [file2] [file3] [etc]: Add files to the ignore list."
        echo "  -u [file1] [file2] [file3] [etc]: Remove files from the ignore list."
        echo "  -v: Enable verbose output for the linter."
        echo "  -s: Suppress linter output."
        exit 0
    fi
    if [ -e ".j1st-ignore" ]; then
        ignored_files=()
        # Read the list of ignored files/patterns into an array
        while IFS= read -r pattern || [ -n "$pattern" ]; do
            ignored_files+=("$pattern")
        done < ".j1st-ignore"
        else
        # If .j1st-ignore doesn't exist, create an empty array
        ignored_files=()
    fi

    # Loop through all .js files in the current directory
    for file in *.js *.mjs; do
    # Check if the file exists and is not empty
    if [ -s "$file" ]; then
        # Check if the file should be ignored
        should_ignore=false
        for pattern in "${ignored_files[@]}"; do
            if [[ "$file" == $pattern ]]; then
            should_ignore=true
            break
            fi
        done

        if [ "$should_ignore" = true ]; then
            if [[ $filetostart == $file ]]; then
                echo "This program is not using J1ST!" 
                stop=1
            fi
            if [[ $verbose == 1 ]] && [[ $redundance != 1 ]] && [[ $supress != 1 ]]; then
                echo -e "${YELLOW}[-]${NC} $file"
            fi
            continue
        fi

        # Read the first line of the file
        first_line=$(head -n 1 "$file" | tr '[:upper:]' '[:lower:]')
        
        # Check if the first line contains the string "XYZ"
        if [[ $first_line =~ ^([^\/]* )?((;)?)+(import ).*(j1st) ]]; then
            if [[ $verbose == 1 ]]; then
                echo -e "${GREEN}[+]${NC} $file"
            fi
        else
            if [[ $supress != 1 ]]; then
                echo -e "${RED}[!]${NC} $file"
            fi
            stop=1
        fi
    fi
    done
    if [[ $stop == 1 ]] && [[ $filetostart != "" ]]; then
        echo "Program not started.";
        exit 1
    fi

    if [[ "$logpath" == *.log ]]; then
        logfile="$logpath"
    else
        if [[ "$logpath" != "" ]]; then
            logfile="${logpath}/"
        fi

        if [[ $namespecifier == "" ]]; then
            logfile="${logfile}${filetostart}.log"
        else
            logfile="${logfile}${filetostart}.${namespecifier}.log"
        fi
    fi
    if [[ $viewlog == 1 ]] && [[ $filetostart != "" ]]; then
        echo "${logfile}:" | $0
        echo "Viewing in editor."
        exit 1
    fi
    if [[ $logging == 1 ]]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "---------------------" | tee -a $logfile 2>/dev/null
        echo "[$timestamp]" | tee -a $logfile 2>/dev/null
        echo "---------------------" | tee -a $logfile 2>/dev/null
    fi
    while [ $stop == 0 ]; do
        if [[ $start == 1 ]]; then
            if [[ $edit == 0 ]]; then
                if [[ $logging == 1 ]]; then
                    ( node $filetostart ${argval_array[@]} ) | tee -a $logfile 2>/dev/null
                else
                    node $filetostart ${argval_array[@]}
                fi
            elif [[ $edit == "+config" ]]; then
                eval 'node --input-type=module -e "$(cat ~/.j1st/config-data-only.js)" $filetostart --config-data-only | $0'
                if [[ $logging == 1 ]]; then
                    ( node $filetostart ${argval_array[@]} ) | tee -a $logfile
                else
                    node $filetostart ${argval_array[@]}
                fi
            elif [[ $edit == "config!" ]]; then
                eval 'node --input-type=module -e "$(cat ~/.j1st/config-data-only.js)" $filetostart --config-data-only | $0'
                if [[ $logging == 1 ]]; then
                    ( node $filetostart ! ) | tee -a $logfile
                else
                    node $filetostart !
                fi
                stop=1
            elif [[ $edit == 'prog' ]]; then
                echo "${filetostart}:" | $0
                echo "Viewing in editor."
                stop=1
            fi
        fi
        if [[ $rep == 1 ]]; then
            stop=0;
            echo "Press any key to restart program.. (or enter a to abort)"
            read -d"" -s -n1
        else
            stop=1;
        fi
        if [[ $REPLY == 'a' ]]; then
            stop=1;
        fi
    done
else
    read -r pipe; 
    configfile=${pipe%?}
    if test -f $configfile; then
        editor=`node -pe 'JSON.parse(process.argv[1]).editor' "$(cat ~/.j1st/config.json)"`
        echo $configfile | xargs $editor
    fi
fi