#!/bin/bash

##		aptly mirror create -filter-with-deps -architectures=amd64 -with-udebs=true buster-main https://deb.debian.org/debian/ buster main
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 -with-udebs=true buster-security https://security.debian.org/debian-security buster/updates main contrib
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 -with-udebs=true buster-updates https://deb.debian.org/debian/ buster-updates main contrib
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 percona-buster-main https://repo.percona.com/percona/apt buster main
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 percona-prel-buster-main https://repo.percona.com/prel/apt buster main
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 docker-buster-stable https://download.docker.com/linux/debian buster stable
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 php-buster-main https://packages.sury.org/php/ buster main
##		sleep 3
##		
##		aptly mirror create -architectures=amd64 azul-repo-java-stable https://repos.azul.com/zulu/deb stable main
##		sleep 10
##		#		
##		#		exit 0;

#######################################################
##  update will download the packages

###	this takes a lot of time, it needs to download 160GB of data

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

aptly mirror update azul-repo-java-stable
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

aptly snapshot create azul-repo-java-stable from mirror azul-repo-java-stable
sleep 10

#######################################################
##  publish from snapshots

#aptly publish snapshot -component=buster-main,buster-security,buster-updates,percona-buster-main,percona-prel-buster-main,docker-buster-stable,php-buster-main -distribution=buster buster-main buster-security buster-updates percona-buster-main percona-prel-buster-main docker-buster-stable php-buster-main
aptly publish snapshot -component=buster-main,buster-security,buster-updates,percona-buster-main,percona-prel-buster-main,docker-buster-stable,php-buster-main,azul-repo-java-stable -distribution=buster buster-main buster-security buster-updates percona-buster-main percona-prel-buster-main docker-buster-stable php-buster-main azul-repo-java-stable

aptly publish list

# To delete the published snapshot
# aptly publish drop buster

# I need to delete the snapshot before create those again

#aptly snapshot drop buster-main
#aptly snapshot drop buster-security
#aptly snapshot drop buster-updates
#aptly snapshot drop percona-buster-main
#aptly snapshot drop percona-prel-buster-main
#aptly snapshot drop docker-buster-stable
#aptly snapshot drop php-buster-main
#aptly snapshot drop azul-repo-java-stable

####  deb http://your-server/ buster azul-repo-java-stable buster-main buster-security buster-updates docker-buster-stable percona-buster-main percona-prel-buster-main php-buster-main
 

##		[root@debian10-repo (10.102.70.192 10.102.60.192) ~]  aptly publish snapshot -component=buster-main,buster-security,buster-updates,percona-buster-main,docker-buster-stable,php-buster-main -distribution=buster buster-main buster-security buster-updates percona-buster-main docker-buster-stable php-buster-main azul-repo-java
##		Loading packages...
##		Generating metadata files and linking package files...
##		 2577 / 4134 [=====================================================================================>---------------------------------------------------]  62.34% 04Finalizing metadata files...
##		
##		Snapshots buster-main, buster-security, buster-updates, percona-buster-main, docker-buster-stable, php-buster-main have been successfully published.
##		Please setup your webserver to serve directory '/.aptly/public' with autoindexing.
##		Now you can add following line to apt sources:
##		  deb http://your-server/azul-repo-java/ buster buster-main buster-security buster-updates docker-buster-stable percona-buster-main php-buster-main
##		Don't forget to add your GPG key to apt with apt-key.

