#############################
# This script is made by: mkgeeky
# Web: https://mkgeeky.xyz
# Git: https://github.com/mkgeeky/
# Mail: contact@mkgeeky.xyz
# Discord: https://discord.gg/tv6ZQ7wzt7
# Lines above MAY NOT BE removed!
#############################
#bin/bash
#INSTALL_PATH="/opt/"
UPTIME_PATH="/root/uptime-kuma" # Change to correct path for your uptime-kuma installation
BACKUP_PATH="/root/backup" # Where you want the backup placed
GIT_PATH="$(which git)"
NPM="$(which npm)"
PM2="$(which pm2)"
JQ="$(which jq)"
TAR="$(which tar)"

function BackUp() {
    echo "Removing old backups...."
    /usr/bin/rm "$BACKUP_PATH/uptime-kuma-*" &> /dev/null
    echo "Removing old backups done...."
    echo "Starting backup...."
    cd $UPTIME_PATH
    $TAR -czf "$BACKUP_PATH/uptime-kuma-$(date '+%Y-%m-%d').tar.gz" data/
    echo "Backup successfully done...."
}

function UpdateFromGit() {
    cd $UPTIME_PATH
    sudo apt-get install -y --no-upgrade jq &> /dev/null
    $GIT_PATH fetch --all &> /dev/null
    CURRENTVERSION="$($JQ .version package.json | xargs)"
    VERSION="$($GIT_PATH describe --tags $(git rev-list --tags --max-count=1))"
    echo "Locate last version...."
    echo "Latest version found: $VERSION"
    if [[ "$CURRENTVERSION" == "$VERSION" ]];
    then {
        echo "Current version ($CURRENTVERSION) is equal to newest version"
        exit 1;
    }
    else {
        BackUp
        echo "Updating to v$VERSION...."
        $GIT_PATH checkout $VERSION --force &> /dev/null
        $NPM install --production &> /dev/null
        $NPM run download-dist &> /dev/null
        $PM2 restart uptime-kuma &> /dev/null
        echo "uptime-kuma is now updated to $VERSION"
        echo "For more information, please visit: https://github.com/louislam/uptime-kuma/wiki/"
        exit 1;
    }
    fi
}

function InstallFromGit() {
    mkdir $UPTIME_PATH &> /dev/null
    cd $UPTIME_PATH &> /dev/null
    sudo apt-get install -y --no-upgrade npm &> /dev/null
    sudo apt-get install -y --no-upgrade jq &> /dev/null
    sudo apt-get install -y --no-upgrade pm2 &> /dev/null
    echo "Installation uptime-kuma....."
    $NPM install npm -g &> /dev/null
    $GIT_PATH clone https://github.com/louislam/uptime-kuma.git &> /dev/null
    $NPM run setup &> /dev/null
    $NPM install pm2 -g && $PM2 install pm2-logrotate &> /dev/null
    $PM2 start server/server.js --name uptime-kuma &> /dev/null
    echo "Installation complete...."
    echo "Now visit http://localhost:3001"
    echo "For more information, please visit: https://github.com/louislam/uptime-kuma/wiki/"
    exit 1;
}
echo "mkgeeky's uptime-kuma install/update script"
echo ""
if [[ $1 == [Uu] ]];
then {
    UpdateFromGit
}
elif [[ $1 == [Ii] ]];
then {
    InstallFromGit
}
fi
if [ -z "$1" ];
then {
    echo "Enter U/u for update"
    echo "Enter I/i for install"
    read -p "Select optin: " selection
    if [[ $selection == [Uu] ]];
    then {
        UpdateFromGit
    }
    elif [[ $selection == [Ii] ]];
    then {
        InstallFromGit
    } else {
        echo "Wrong option...."
        exit 1;
    }
    fi
}
fi