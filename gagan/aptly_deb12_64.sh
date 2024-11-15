#!/bin/bash

export APTLY_ROOT_DIR=/.aptly

# Function to check if a mirror exists
check_mirror() {
    if aptly mirror list | grep -q "$1"; then
        echo "Mirror $1 already exists."
    else
        echo "Creating mirror $1..."
        $2  # Run the command passed as the second argument
    fi
}

# Create mirrors only if they don't exist

check_mirror "bookworm-main" "aptly mirror create -architectures=amd64 bookworm-main http://deb.debian.org/debian bookworm main"
sleep 3;
check_mirror "bookworm-security" "aptly mirror create -architectures=amd64 -force-components bookworm-security http://security.debian.org/debian-security bookworm-security main"
sleep 3;
check_mirror "bookworm-updates" "aptly mirror create -architectures=amd64 bookworm-updates http://deb.debian.org/debian bookworm-updates main"
sleep 3;
check_mirror "percona-bookworm-main" "aptly mirror create -architectures=amd64 percona-bookworm-main http://repo.percona.com/apt bookworm main"
sleep 3;
check_mirror "percona-prel-bookworm-main" "aptly mirror create -architectures=amd64 percona-prel-bookworm-main http://repo.percona.com/prel/apt bookworm main"
sleep 3;
check_mirror "docker-bookworm-stable" "aptly mirror create -architectures=amd64 docker-bookworm-stable https://download.docker.com/linux/debian bookworm stable"
sleep 3;
check_mirror "php-bookworm-main" "aptly mirror create -architectures=amd64 php-bookworm-main https://packages.sury.org/php/ bookworm main"
sleep 3;
# Update mirrors
echo "Updating mirrors..."
sleep 10;
aptly mirror update bookworm-main
sleep 3;
aptly mirror update bookworm-security
sleep 3;
aptly mirror update bookworm-updates
sleep 3;
aptly mirror update percona-bookworm-main
sleep 3;
aptly mirror update percona-prel-bookworm-main
sleep 3;
aptly mirror update docker-bookworm-stable
sleep 3;
aptly mirror update php-bookworm-main
sleep 10;

########################################################
### Create snapshots if they don't already exist
create_snapshot() {
    if aptly snapshot list | grep -q "$1"; then
        echo "Snapshot $1 already exists."
    else
        echo "Creating snapshot $1..."
        aptly snapshot create "$1" from mirror "$1"
    fi
}

create_snapshot "bookworm-main"
sleep 3;
create_snapshot "bookworm-security"
sleep 3;
create_snapshot "bookworm-updates"
sleep 3;
create_snapshot "percona-bookworm-main"
sleep 3;
create_snapshot "percona-prel-bookworm-main"
sleep 3;
create_snapshot "docker-bookworm-stable"
sleep 3;
create_snapshot "php-bookworm-main"
sleep 3;
echo "done till snapshot"
sleep 10;

# Publish the repository if not already published
if aptly publish list | grep -q "bookworm"; then
    echo "Publication for bookworm already exists."
else
    echo "Publishing repository..."
    aptly publish snapshot -component=bookworm-main,bookworm-security,bookworm-updates,percona-bookworm-main,percona-prel-bookworm-main,docker-bookworm-stable,php-bookworm-main -distribution=bookworm bookworm-main bookworm-security bookworm-updates percona-bookworm-main percona-prel-bookworm-main docker-bookworm-stable php-bookworm-main
fi

echo "Finalizing aptly directory..."
if [ -d "/root/.aptly" ]; then
    mv /root/.aptly /.aptly
    chmod -R 755 /.aptly
fi

#
#mv  /root/.aptly /.aptly
#chmod -R 755 /.aptly


##### run with no hup : nohup ./aptly_deb12_64.sh > aptly_log.out 2>&1 &   ; tail -f /root/gagan/aptly_log.out
