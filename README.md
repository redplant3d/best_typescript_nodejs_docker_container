# Best Typescript Nodejs Docker Container (BTNDC) [ In my opinion ;) ]
A template for using Typescript with Nodejs within a Docker container. Can be used as dev environment and for production.

## The problem
There is no native support for typescript in nodejs. Other libraries like ts-node help to run ts fast and easy. But this comes with some drawbacks like different operating systems on the host maschine and within a container.   

## Goals?
* Docker for development and production
* Shared sources between host and container
* Robust change detection in TS-files
* Automated nodejs restarts based on TSC and nodemon
* Different node_modules installations on the host system and within the container (Coding in Windows and running in linux)
* Pure JavaScript in production mode
* Easy to setup (simple npm install or yarn add)
* Easy to extend (multiple services)

## Docker
At the moment I used two docker-compose files to define the services. In this case I choose a example nest.js api scenario. But it is intended to use multiple nodejs containers.


### Compose: Start the example app
For development mode use the docker-compose.yml:
```
docker-compose up
```
For production mode use the docker-compose.prod.yml:
```
docker-compose -f docker-compose.prod.yml up
```

### Dockerfiles
Each service in the compose contains a docker folder which consists of the Dockerfiles for dev and production and a shared entrypoint.sh bash script. The dockerfiles are based on the  [library nodejs image](https://hub.docker.com/_/node/) + yarn, nodemon, pm2 and netcat. 

The develoment dockerfile uses a volume to share the source code between the host maschine and the container. It compiles the source at runtime and uses nodemon to restart the nodejs server after the src changed.

The production dockerfile simply copies the src directory into the image, compiles it via tsc and removes the src directory afterwards. The production container runs pure js.

In both environments the entrypoint.sh is added and made executable. It is my entrypoint into the container. 

### Entrypoint
The entrypoint is started with the initial rednode command. If the environment is set to development, the bash script starts multiple processes to watch the output of the tsc process, to detect compilation errors and to restart the nodejs process via nodemon.

The tsc -w output is piped through a fifo. Each output line is checked if the current compilation was successful (Inspired by [ts-watch](https://github.com/gilamran/tsc-watch)). If the compilation runs without errors nodemon will be triggered via a SIGHUP signal (Special thanks @Remy for this feature). I do it this way, so that not every single JavaScript file created causes a restart. 
Only when all ts files have been converted to js files, a single restart takes place.

But it's still possible to exec commands.
```
docker-compose exec example-nestjs-service bash
```
#### Docker and PID 1
To stop the container each process is started with a process id and added to a trap. If the pid 1 receives a SIGINT or SIGTERM all remaining processes will be closed as well.

### yarn install / add | npm install
Because I only share / add the src directory to the container it is possible to run yarn install on the host maschine. The dependencies will be installed in the node_modules folder which is only available in the host maschine. The container runs the installation on its own and creates its seperated node_module folder. In this way it is now possible to install binary dependencies for each operating system. This is important for packages like puppeteer. Editors like VSCode are able to find the packages and typings on the host.

To add other packages simply run __yarn add packagename__ on the host maschine and restart the container afterwards. 

# Feedback welcome
;)

 









