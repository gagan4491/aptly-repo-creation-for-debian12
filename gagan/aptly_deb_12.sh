#!/bin/bash

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

check_mirror "bookworm-main" "aptly mirror create bookworm-main http://deb.debian.org/debian bookworm main"
check_mirror "bookworm-security" "aptly mirror create -force-components bookworm-security http://security.debian.org/debian-security bookworm-security main"
check_mirror "bookworm-updates" "aptly mirror create bookworm-updates http://deb.debian.org/debian bookworm-updates main"
check_mirror "percona-bookworm-main" "aptly mirror create percona-bookworm-main http://repo.percona.com/apt bookworm main"
check_mirror "percona-prel-bookworm-main" "aptly mirror create percona-prel-bookworm-main http://repo.percona.com/prel/apt bookworm main"
check_mirror "docker-bookworm-stable" "aptly mirror create -architectures=amd64,arm64,armhf docker-bookworm-stable https://download.docker.com/linux/debian bookworm stable"
check_mirror "php-bookworm-main" "aptly mirror create php-bookworm-main https://packages.sury.org/php/ bookworm main"
check_mirror "azul-repo-java-stable" "aptly mirror create azul-repo-java-stable https://repos.azul.com/zulu/deb/ stable main"

# Update mirrors
echo "Updating mirrors..."
aptly mirror update bookworm-main
aptly mirror update bookworm-security
aptly mirror update bookworm-updates
aptly mirror update percona-bookworm-main
aptly mirror update percona-prel-bookworm-main
aptly mirror update docker-bookworm-stable
aptly mirror update php-bookworm-main
aptly mirror update azul-repo-java-stable

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
create_snapshot "bookworm-security"
create_snapshot "bookworm-updates"
create_snapshot "percona-bookworm-main"
create_snapshot "percona-prel-bookworm-main"
create_snapshot "docker-bookworm-stable"
create_snapshot "php-bookworm-main"
create_snapshot "azul-repo-java-stable"

echo "done till snapshot"

# Publish the repository if not already published
if aptly publish list | grep -q "bookworm"; then
    echo "Publication for bookworm already exists."
else
    echo "Publishing repository..."
    aptly publish snapshot -component=bookworm-main,bookworm-security,bookworm-updates,percona-bookworm-main,percona-prel-bookworm-main,docker-bookworm-stable,php-bookworm-main,azul-repo-java-stable -distribution=bookworm bookworm-main bookworm-security bookworm-updates percona-bookworm-main percona-prel-bookworm-main docker-bookworm-stable php-bookworm-main azul-repo-java-stable
fi



##### run with no hup : nohup ./aptly_deb_12.sh > aptly_log.out 2>&1 &   ; tail -f /root/gagan/aptly_log.out