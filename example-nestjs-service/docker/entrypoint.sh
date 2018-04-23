#!/bin/bash
set -e

if [ "$1" = 'rednode' ]; then

    # Maybe you want to wait for other containers to start?
    # Netcat checks every 5 secounds for a database or redis until they answer!
    # 
    # while ! nc -q 1 database 5432 </dev/null; do sleep 5; done
    # while ! nc -q 1 redis 6379 </dev/null; do sleep 5; done

    for i in "$@"
    do
    case $i in
        -e=*|--environment=*)
        ENVIRONMENT="${i#*=}"
        shift # past argument=value
        ;;
        -m=*|--migrate=*)
        MIGRATE="${i#*=}"
        shift # past argument=value
        ;;
        *)
            # unknown option
        ;;
    esac
    done
    echo "ENVIRONMENT = ${ENVIRONMENT}"
    echo "MIGRATE     = ${MIGRATE}"

    if [ "${ENVIRONMENT}" == "production" ]; then
        echo "Run node instance in production environment"
        export NODE_ENV=production

        # Perhaps you would like to perform a few migration tasks?
        [ "${MIGRATE}" = 'true' ] && {

            echo "Run migration"

            # Run your migration here
            # Run your migration here
            # Run your migration here

            # e.g. like -> typeorm migrations:run

            echo "Migration completed"
        }

        # Start the applications with all CPUs
        exec pm2-docker --raw ./dist/server.js -i 0
    else
        echo "Run node instance in development environment"
        export NODE_ENV=development

        # Path for the tsc pipe
        pipeTsc=/tmp/pipeTsc

        # Create a new tsc pipe if it dosen't exists
        if [[ ! -p $pipeTsc ]]; then
            mkfifo $pipeTsc
        fi

        function setupTscPipe {

            # Nodemon pid comes through the function parameter 1 
            local nodemonPid=$1

            # Regex tsc status detection.
            # Inspired by https://github.com/gilamran/tsc-watch
            local checkStart="Starting incremental compilation"
            local checkComplete="Compilation complete\. Watching for file changes\."
            local checkError="(\([0-9]+,[0-9]+\): error TS[0-9]+:)|(^error TS[0-9]+:)"

            # FLAGS
            local hasError=false
            local firstSuccess=true

            # Read from the tsc output stream
            (while read line; do

                dt=$(date '+%H:%M:%S');

                [[ ! -z "$line" ]] && {
                    echo "[TSC] $line";
                }

                # Detect the start of the compilation
                [[ "$line" =~ $checkStart ]] && hasError=false
                # Detect errors
                [[ "$line" =~ $checkError ]] && hasError=true
                # Detect the end of the compilation
                [[ "$line" =~ $checkComplete ]] && {

                    # If the last compilation runs without an error
                    [[ "$hasError" = false ]] && {

                        # Is it the first successful compilation?
                        [[ "$firstSuccess" = true ]] && {
                            firstSuccess=false

                            # Perhaps you would like to perform a few migration tasks?
                            [ "${MIGRATE}" = 'true' ] && {
                                echo "[TSC] $dt - Run migration"

                                # Run your migration here
                                # Run your migration here
                                # Run your migration here

                                # e.g. like -> typeorm migrations:run

                                echo "[TSC] $dt - Migration completed"
                            }
                        }

                        # If all ts files are successfully compiled nodemon is triggered.
                        # In this case nodemon dosn't watch js files because we want a clean restart
                        # after all ts files are compilated to js files. Nodemon watches only other extensions
                        # like json or other static files.
                        echo "[TSC] $dt - Trigger nodemon by SIGHUP to PID: $nodemonPid"
                        # Thanks @Remy for implementing the HUP signal method. https://github.com/remy/nodemon
                        kill -HUP $nodemonPid
                    } || {
                        # Some errors. No nodemon restart needed.
                        echo "[TSC] $dt - Errors detected - Trigger nodemon postponed"
                    }
                }
            done) < $pipeTsc
        }

        # Start nodemon
        nodemon --legacy-watch --on-change-only & pid=$!
        # Add Nodemon to the kill-list
        PID_LIST+=" $pid";
        # ! give the nodemon pid to the tsc watcher
        setupTscPipe $pid & pid=$!
        # Add the tsc pipe to the kill-list
        PID_LIST+=" $pid";
        # Start TSC in watch mode an pipe the output to the tsc pipe
        tsc -w >$pipeTsc & pid=$!
        # Add TSC to the kill-list
        PID_LIST+=" $pid";

        # Setup the trap for all processes.
        # Its a docker thing ;)
        trap "kill $PID_LIST" SIGINT SIGTERM

        # Wait for the container shutdown
        echo "Parallel processes have started $PID_LIST"
        wait $PID_LIST
    fi
fi

exec "$@"
