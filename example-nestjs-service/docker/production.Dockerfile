FROM node:8.9.4
LABEL "de.redplant.vendor"="redPlant GmbH - Realtime Studios"
LABEL "de.redplant.maintainer"="Thomas Reufer <thomas.reufer@redplant.de>"
LABEL "description"="Typescript with Nodejs within a Docker Container."
LABEL "version"="1.0"

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "deb http://deb.debian.org/debian jessie main contrib" > /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian jessie-updates main contrib" >> /etc/apt/sources.list \
 && echo "deb http://security.debian.org jessie/updates main contrib" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install --no-install-recommends -y \
 netcat \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/?? /usr/share/man/??_*

RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN yarn global add nodemon pm2 typescript

RUN mkdir -p /app
ADD package.json \
 yarn.lock \
 tsconfig.json \
 nodemon.json \
 /app/

WORKDIR /app
RUN yarn install --frozen-lockfile --production=true

# PRODUCTION:
# Copy the ts sources into the container
ADD src /app/src/

# PRODUCTION:
# Compile to js directly.
# This creates the /app/dist folder.
# It is save to remove the typescript /app/src folder completly
RUN tsc \
 && rm -rf src

COPY docker/entrypoint.sh /redutils/entrypoint.sh 
RUN chmod +x /redutils/entrypoint.sh 

EXPOSE 3000
ENTRYPOINT ["/redutils/entrypoint.sh"]
CMD ["rednode", "--environment=production", "--migrate=true"]