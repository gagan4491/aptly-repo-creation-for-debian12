
# Custom Debian 12 (Bookworm) Repository with Aptly

This guide will help you install Aptly and create a custom Debian 12 repository on your system.

## Prerequisites

- Debian 12 (Bookworm) system
- Root or user with `sudo` privileges

## Step 1: Install Required Packages

1. **Update your package list:**
   ```bash
   sudo apt update
   ```

2. **Install dependencies:**
   ```bash
   sudo apt install gnupg2 curl wget aptly screen
   ```

## Step 2: Install and Configure Aptly

1. **Create Aptly working directory:**
   ```bash
   mkdir -p ~/aptly
   cd ~/aptly
   ```

2. **Initialize Aptly (optional, only needed for first-time setup):**
   ```bash
   aptly repo create -distribution=bookworm -component=main my-custom-repo
   ```

## Step 3: Import Necessary GPG Keys

1. **Import Debian archive keys:**
   ```bash
   gpg --no-default-keyring --keyring /usr/share/keyrings/debian-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import
   ```

2. **Import other required keys from a keyserver:**
   ```bash
   gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keyserver.ubuntu.com --recv-keys \
   0E98404D386FA1D9 6ED0E7B82643E131 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8 9334A25F8507EFA5 \
   7EA0A9C3F273FCD8 B188E2B695BD4743 B1998361219BD9C9
   ```

3. **Manually import `Release.key` for specific repositories if needed:**
   ```bash
   wget -O - https://repo.percona.com/apt/Release.key | gpg --no-default-keyring --keyring trustedkeys.gpg --import
   ```

## Step 4: Create and Run the Script

1. **Create a script file (`aptly_deb_12.sh`) with the following content:**

   ```bash
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
   check_mirror "bookworm-security" "aptly mirror create bookworm-security http://security.debian.org/debian-security bookworm-security main"
   check_mirror "bookworm-updates" "aptly mirror create bookworm-updates http://deb.debian.org/debian bookworm-updates main"
   check_mirror "percona-bookworm-main" "aptly mirror create percona-bookworm-main http://repo.percona.com/apt bookworm main"
   check_mirror "percona-prel-bookworm-main" "aptly mirror create percona-prel-bookworm-main http://repo.percona.com/prel/apt bookworm main"
   check_mirror "docker-bookworm-stable" "aptly mirror create docker-bookworm-stable https://download.docker.com/linux/debian bookworm stable"
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
   ```

2. **Make the script executable:**
   ```bash
   chmod +x aptly_deb_12.sh
   ```

3. **Run the script using `screen` or `tmux` to keep it running even if your session disconnects:**
   ```bash
   screen -S aptly-script ./aptly_deb_12.sh
   ```

   - To detach from `screen`, press `Ctrl + A`, then `D`.
   - Reattach using:
     ```bash
     screen -r aptly-script
     ```
# or 

3. **Run the script using `nohup` to keep it running even if your session disconnects:**
   ```bash
   nohup ./aptly_deb_12.sh > aptly_log.out 2>&1 &
   ```

   - To get the logs :
     ```bash
     tail -f aptly_log.out
     ```
I would use the nohup :) 
    
## Step 5: Access and Use Your Repository

1. **Serve the repository using a simple web server:**
   ```bash
   cd ~/.aptly/public
   python3 -m http.server 8080
   ```

2. **Add your custom repository to client machines:**
   ```bash
      deb [signed-by=/usr/share/keyrings/aptly-keyring.gpg] http://10.102.70.20/ bookworm bookworm-main bookworm-security bookworm-updates docker-bookworm-stable percona-bookworm-main percona-prel-bookworm-main php-bookworm-main
   ```

3. **Update the package list on client machines:**
   ```bash
   sudo apt update
   ```
   


# Note : 
` do change the .aptly.config path from /root/.aptly/  to  /.aptly  
`
and move the /root/.aptly to /.aptly 
and run chmod -R 755 /.aptly 


then add the nginx : 
sudo nano /etc/nginx/sites-available/default

```
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    # Replace with your server's IP or hostname
    server_name 10.102.70.20;

    # Point to your aptly public directory
    root /.aptly/public;

    # Enable autoindexing for the repository
    autoindex on;

    # Location block to serve the repository
    location / {
        try_files $uri $uri/ =404;
    }
}

```

run before the publisbinbt the repo :


curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb

mkdir -p /aptly-local-packages
mv percona-release_latest.generic_all.deb /aptly-local-packages/

aptly repo create -distribution=generic -component=main percona-release
aptly repo add percona-release /aptly-local-packages/


Congratulations! You have successfully set up and published a custom Debian 12 repository using Aptly.
set up the gpg key : 


gpg --list-keys
nano .aptly.conf
gpg --armor --export 6A622DA5C6CD42AD > /.aptly/public/repo-key.gpg ## 6A^.......2AD is the key which we will get bygpg --list-keys


you can use your repo as : 
apt update 
apt install gnupg -y
wget http://10.102.70.20/repo-key.gpg
sudo gpg --dearmor -o /usr/share/keyrings/aptly-keyring.gpg repo-key.gpg

deb [trusted=yes signed-by=/usr/share/keyrings/aptly-keyring.gpg]  http://10.102.70.20/ bookworm bookworm-main bookworm-security bookworm-updates docker-bookworm-stable percona-bookworm-main percona-prel-bookworm-main php-bookworm-main postgresql-14



mkdir -p /aptly-local-packages
mv percona-release_latest.generic_all.deb /aptly-local-packages/


aptly repo create -distribution=generic -component=main percona-release
aptly repo add percona-release /aptly-local-packages/
