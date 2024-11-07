#!/bin/bash

aptly mirror update bullseye-main
aptly mirror update bullseye-security
aptly mirror update bullseye-updates

aptly mirror update percona-bullseye-main

aptly mirror update percona-prel-bullseye-main

aptly mirror update docker-bullseye-stable

aptly mirror update php-bullseye-main

aptly mirror update azul-repo-java-stable

########################################################
###  create snapshots
#
aptly snapshot create bullseye-main from mirror bullseye-main
#sleep 10
#
aptly snapshot create bullseye-security from mirror bullseye-security
#sleep 10
#
aptly snapshot create bullseye-updates from mirror bullseye-updates
#sleep 10
#
aptly snapshot create percona-bullseye-main from mirror percona-bullseye-main
#sleep 10
#
aptly snapshot create percona-prel-bullseye-main from mirror percona-prel-bullseye-main
#sleep 10
#
aptly snapshot create docker-bullseye-stable from mirror docker-bullseye-stable
#sleep 10
#
aptly snapshot create php-bullseye-main from mirror php-bullseye-main
#sleep 10
#
aptly snapshot create azul-repo-java-stable from mirror azul-repo-java-stable
#sleep 10
#
#
echo "done till snapshot"
#
#



aptly publish snapshot -component=bullseye-main,bullseye-security,bullseye-updates,percona-bullseye-main,percona-prel-bullseye-main,docker-bullseye-stable,php-bullseye-main,azul-repo-java-stable -distribution=bullseye bullseye-main bullseye-security bullseye-updates percona-bullseye-main percona-prel-bullseye-main docker-bullseye-stable php-bullseye-main azul-repo-java-stable





##### to upgrade the repo we need to delete the snapshot  then  run the whole process again . 

####aptly publish drop bullseye
####aptly snapshot drop bullseye-main
####aptly snapshot drop bullseye-security
####aptly snapshot drop bullseye-updates
####aptly snapshot drop percona-bullseye-main
####aptly snapshot drop percona-prel-bullseye-main
####aptly snapshot drop docker-bullseye-stable
####aptly snapshot drop php-bullseye-main
####aptly snapshot drop azul-repo-java-stable
####