#!/bin/bash

aptly mirror create -with-sources=true -filter-with-deps -architectures=amd64 -with-udebs=true buster-main https://deb.debian.org/debian/ buster main
sleep 10

aptly mirror create -with-sources=true -with-udebs=true buster-security https://security.debian.org/debian-security buster/updates main contrib
#sleep 10

aptly mirror create -with-sources=true -with-udebs=true buster-updates https://deb.debian.org/debian/ buster-updates main contrib
sleep 10

aptly mirror create -architectures=amd64 percona-buster-main https://repo.percona.com/percona/apt buster main
sleep 10

aptly mirror create -architectures=amd64 percona-prel-buster-main https://repo.percona.com/prel/apt buster main
sleep 10

aptly mirror create -architectures=amd64 docker-buster-stable https://download.docker.com/linux/debian buster stable
sleep 10

aptly mirror create -architectures=amd64 php-buster-main https://packages.sury.org/php/ buster main
sleep 10

#######################################################
##  update will download the packages

aptly mirror update buster-main
sleep 10

aptly mirror update buster-security
sleep 10

aptly mirror update buster-updates
sleep 10

aptly mirror update percona-buster-main
sleep 10

aptly mirror update percona-prel-buster-main
sleep 10

aptly mirror update docker-buster-stable
sleep 10

aptly mirror update php-buster-main
sleep 10

#######################################################
##  create snapshots

aptly snapshot create buster-main from mirror buster-main
sleep 10

aptly snapshot create buster-security from mirror buster-security
sleep 10

aptly snapshot create buster-updates from mirror buster-updates
sleep 10

aptly snapshot create percona-buster-main from mirror percona-buster-main
sleep 10

aptly snapshot create percona-prel-buster-main from mirror percona-prel-buster-main
sleep 10

aptly snapshot create docker-buster-stable from mirror docker-buster-stable
sleep 10

aptly snapshot create php-buster-main from mirror php-buster-main
sleep 10

#######################################################
##  publish from snapshots

#aptly publish snapshot -component=buster-main,buster-security,buster-updates,percona-buster-main,percona-prel-buster-main,docker-buster-stable,php-buster-main -distribution=buster buster-main buster-security buster-updates percona-buster-main percona-prel-buster-main docker-buster-stable php-buster-main
aptly publish snapshot -component=buster-main,buster-security,buster-updates,percona-buster-main,docker-buster-stable,php-buster-main -distribution=buster buster-main buster-security buster-updates percona-buster-main docker-buster-stable php-buster-main

sleep 10

