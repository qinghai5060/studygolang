#!/usr/bin/env bash

# ***************************************************************************
# *
# * @author:jockerxu
# * @date:2017-11-14 22:20
# * @version 1.0
# * @description: Shell script
#*
#**************************************************************************/

MYSQL_ROOT_PASSWORD=${2:-123456}
current_workdir=$(cd `dirname $0`;pwd)
sed -i "s/MYSQL_ROOT_PASSWD/${MYSQL_ROOT_PASSWORD}/g" ${current_workdir}/config/env.sample.ini

addr=$(ip -o -4 a s |grep 'scope global dynamic'|awk '{print $4}' |cut -d '/' -f1)
sed -i "s/HOST_ADDRESS/$addr/g" ${current_workdir}/config/env.sample.ini

#---------tool function---------------
echo_COLOR_GREEN=$(  echo -e "\e[32;49m")
echo_COLOR_RESET=$(  echo -e "\e[0m")
function echo-info()
{
    echo -e "${echo_COLOR_GREEN}[$(date "+%F %T")]\t$*${echo_COLOR_RESET}";
}
#---------end tool function-----------
if [[ $USER != "root" ]]; then
    echo "you must be root!!!!!"
    exit 1
fi

if [[ $1 == "" ]]; then
    echo "Usage start-docker.sh [local | remote]"
    exit 1
fi


function build_go() {
    docker run -ti --rm -v $current_workdir:/opt/studyrust  golang:1.12.17 /bin/sh -c "cd /opt/studyrust && make build"
}

STUDYGOLANG_IMG=

if [[ $1 == "local" ]]; then
    STUDYGOLANG_IMG=studyrust
    docker images ${STUDYGOLANG_IMG} | grep -q ${STUDYGOLANG_IMG} || {
        docker build -f Dockerfile.web -t $STUDYGOLANG_IMG .
    }
elif [[ $1 == "remote" ]]; then
    STUDYGOLANG_IMG="studyrust"
else
    exit 1
fi

docker ps -a | grep -q mysqlDB || {
    docker run --name mysqlDB -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} -d mysql
}
docker ps -a | grep -q studygolang-web && {
    docker rm -f studygolang-web
}
docker run -d --rm --name studygolang-web -v `pwd`:/studygolang -p 8090:8088 --link mysqlDB:db.localhost $STUDYGOLANG_IMG ./docker-entrypoint.sh

if [[ $? == 0 ]]; then
    echo-info "studyrust-web start, waiting several seconds to install..."
    sleep 5
    echo-info "open browser: http://localhost:8090"
    echo-info "mysql-host is: db.localhost "
    echo-info "mysql-password is: ${MYSQL_ROOT_PASSWORD}"
fi
