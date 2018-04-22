# Best Typescript Nodejs Docker Container (BTNDC) [ In my opinion ;) ]
A template for using Typescript with Nodejs within a Docker container. Can be used as dev environment and for production.

## The problem
There is no native support for typescript in nodejs. Other libraries like ts-node help to run ts fast and easy. But this comes with some drawbacks like diffenernt operating systems on the host maschine and within a container.  

### What do i want?
* Easy to setup
* Easy to extend
* Shared sources between host and container
* Robust change detection in TS-files
* Automated nodejs restarts based on TSC and nodemon
* Different node_modules installations on the host system and within the container (Coding in Windows and running in linux)
* Pure JavaScript in production mode

## The idea
A docker-compose to define our different services. In this case i choose a example nest.js api scenario. It is intended to use multiple nodejs containers.






