#!/bin/bash

export APTLY_ROOT_DIR=/.aptly

# List of mirrors with URLs and components
MIRRORS=(
    "bullseye-main|http://deb.debian.org/debian bullseye main"
    "bullseye-security|http://security.debian.org/debian-security bullseye-security main"
    "bullseye-updates|http://deb.debian.org/debian bullseye-updates main"
    "percona-bullseye-main|http://repo.percona.com/apt bullseye main"
    "percona-prel-bullseye-main|http://repo.percona.com/prel/apt bullseye main"
    "docker-bullseye-stable|https://download.docker.com/linux/debian bullseye stable"
    "php-bullseye-main|https://packages.sury.org/php bullseye main"
    "azul-repo-java-stable|https://repos.azul.com/zulu/deb/ stable main"
)

# Function to create or update mirrors with amd64 architecture
create_or_update_mirror() {
    local mirror_name="$1"
    local mirror_url="$2"

    if aptly mirror list | grep -q "$mirror_name"; then
        echo "Mirror $mirror_name already exists. Updating..."
        aptly mirror edit -architectures=amd64 "$mirror_name"
    else
        echo "Creating mirror $mirror_name..."
        aptly mirror create -architectures=amd64 "$mirror_name" $mirror_url
    fi

    # Update the mirror
    echo "Updating $mirror_name..."
    aptly mirror update "$mirror_name"
}

# Update and create mirrors
echo "Managing mirrors..."
for MIRROR in "${MIRRORS[@]}"; do
    IFS='|' read -r mirror_name mirror_url <<< "$MIRROR"
    create_or_update_mirror "$mirror_name" "$mirror_url"
done

echo "Mirror updates completed."

# Create snapshots
echo "Creating snapshots..."
for MIRROR in "${MIRRORS[@]}"; do
    IFS='|' read -r mirror_name mirror_url <<< "$MIRROR"
    echo "Creating snapshot for $mirror_name..."
    aptly snapshot create "$mirror_name" from mirror "$mirror_name"
done

echo "Snapshots creation completed."

# Publish snapshots
echo "Publishing snapshots..."
if aptly publish list | grep -q "bullseye"; then
    echo "Publication for bullseye already exists, updating..."
    aptly publish update bullseye
else
    echo "Publishing bullseye distribution for the first time..."
    aptly publish snapshot \
        -distribution=bullseye \
        -component=bullseye-main,bullseye-security,bullseye-updates,percona-bullseye-main,percona-prel-bullseye-main,docker-bullseye-stable,php-bullseye-main,azul-repo-java-stable \
        bullseye-main bullseye-security bullseye-updates percona-bullseye-main percona-prel-bullseye-main docker-bullseye-stable php-bullseye-main azul-repo-java-stable
fi

echo "Publishing completed."
