#!/usr/bin/env bash
set -e
# ***************************************************************************
# *
# * @author:jockerxu
# * @date:2017-11-14 22:20
# * @version 1.0
# * @description: Shell script
#*
#**************************************************************************/
STUDYRUST_IMG=${1:-"studyrust"}
MYSQL_ROOT_PASSWORD=${2:-123456}
current_workdir=$(cd `dirname $0`;pwd)

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

function clean_containers() {
    set +e
    docker ps -a | grep -q mysqlDB && docker rm -f mysqlDB
    docker ps -a | grep -q studyrust && docker rm -f studyrust
    set -e
}

function build_new_image(){
    docker run -ti --rm -v $current_workdir:/opt/studyrust  golang:1.12.17 /bin/sh -c "cd /opt/studyrust && make build"
    docker build -t $STUDYRUST_IMG .
}

function prepare_config(){
    sed -i "s/MYSQL_ROOT_PASSWD/${MYSQL_ROOT_PASSWORD}/g" ${current_workdir}/config/env.ini

    addr=$(ip -o -4 a s |grep 'scope global dynamic'|awk '{print $4}' |cut -d '/' -f1)
    sed -i "s/HOST_ADDRESS/$addr/g" ${current_workdir}/config/env.ini
}

function run_studyrust(){
    docker run --name mysqlDB -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} -d mysql
    docker run -d --rm --name studyrust -p ${addr}:8090:8088 --link mysqlDB:db.localhost $STUDYRUST_IMG
    if [[ $? == 0 ]]; then
        echo-info "studyrust-web start, waiting several seconds to install..."
        sleep 5
        echo-info "open browser: http://localhost:8090"
        echo-info "mysql-host is: db.localhost "
        echo-info "mysql-password is: ${MYSQL_ROOT_PASSWORD}"
    fi
}

function main(){
    clean_containers
    build_new_image
    prepare_config
    run_studyrust
}

main

