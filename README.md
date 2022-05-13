# docker-npm-maven-jf-yarn-git
alpine Dockerfile with docker ,npm ,11-jdk-alpine, maven ,git, jfrog cli ,yarn, localized to LANG=en_US.UTF-8, TZ=America/Los_Angeles

1. Got the inspiration from https://github.com/cschockaert/docker-npm-maven/blob/master/Dockerfile 

2. Instead of starting with “FROM node:10-alpine” in Dockerfile   used “FROM eclipse-temurin:11-jdk-alpine” as in  [3.8.5-eclipse-temurin-11-alpine](https://github.com/carlossg/docker-maven/blob/925e49a1d0986070208e3c06a11c41f8f2cada82/eclipse-temurin-11-alpine/Dockerfile)  https://hub.docker.com/_/maven image
3. For docker use [20.10.16-alpine3.15](https://github.com/docker-library/docker/blob/ca257b920303ae46cff2a8399471318ad48d67b4/20.10/Dockerfile) tag's Dockerfile from https://hub.docker.com/_/docker    but without the ENTRYPOINT ["docker-entrypoint.sh"]
4. For  git and localize see  Dockerfile in step1
5. Add the [jfrog CLI](https://jfrog.com/getcli/) 
6. For npm and yarn use [18-alpine3.14](https://github.com/nodejs/docker-node/blob/38ae136a31e276da1dc6ff6a129a4e429304582d/18/alpine3.14/Dockerfile) from https://hub.docker.com/_/node 
7. For maven use [3.8.5-eclipse-temurin-11-alpine](https://github.com/carlossg/docker-maven/blob/925e49a1d0986070208e3c06a11c41f8f2cada82/eclipse-temurin-11-alpine/Dockerfile) in https://hub.docker.com/_/maven along with the [mvn-entrypoint.sh](https://github.com/carlossg/docker-maven/blob/925e49a1d0986070208e3c06a11c41f8f2cada82/eclipse-temurin-11-alpine/mvn-entrypoint.sh)  , [settings-docker.xml](https://github.com/carlossg/docker-maven/blob/925e49a1d0986070208e3c06a11c41f8f2cada82/eclipse-temurin-11-alpine/settings-docker.xml)

**Build and push to Artifactory:**
```
docker rmi -f soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine
docker build --tag soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine .
docker push soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine
```
Note: This image is 838 MB.

**Usage:**
```
docker run -it --rm --name my-maven-project -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven  soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine mvn verify

docker run --rm --name my-project -it -v /var/run/docker.sock:/var/run/docker.sock soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine /bin/bash

docker run -it --rm --name my-project  -v /var/run/docker.sock:/var/run/docker.sock soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine docker ps

docker run -it --rm --name my-project  soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine npm -version

docker run -it --rm --name my-project  soleng.jfrog.io/swampup2022-docker-local/docker20.10.16-npm18.1-maven3.8.5-jf2.16.4:11-jdk-alpine jf --version
```
**Note:** Actually npm , maven , gradle, openjdk ( based on Temurin), sdkman, go   is   in the Full [jfrog CLI](https://jfrog.com/getcli/) v2.16.4 image  ( not in the slim JFrog cli image) that is Ubuntu based ( hence image is 3.96 GB). The slim JFrog cli image is 53.6MB .
