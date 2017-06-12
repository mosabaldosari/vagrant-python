#!/bin/bash

# Script to set up a Python + MySQL development environment on Vagrant

# Installation settings

PROJECT_NAME=$1

DB_NAME=$2
DB_PASSWD=root
DB_USER=$3
ROOT_DIR=$4
VIRTUALENV_NAME=$PROJECT_NAME
PROJECT_DIR=/home/vagrant/$PROJECT_NAME
PROJECT_ROOT=/home/vagrant/$ROOT_DIR
VIRTUALENV_DIR=/home/vagrant/.virtualenvs/$PROJECT_NAME

# Install essential packages from Apt
apt-get update -y
# Python dev packages
apt-get install -y build-essential python python-dev
# python-setuptools being installed manually
wget https://bootstrap.pypa.io/ez_setup.py -O - | python
# Dependencies for image processing with Pillow (drop-in replacement for PIL)
# supporting: jpeg, tiff, png, freetype, littlecms
# (pip install pillow to get pillow itself, it is not in requirements.txt)
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev debconf-utils
# Git (we'd rather avoid people keeping credentials for git commits in the repo, but sometimes we need it for pip requirements that aren't in PyPI)
apt-get install -y git

# MySQL setup for development purposes ONLY

if ! command -v mysql; then
    echo -e "\n--- Installing  MySQL specific packages and settings ---\n"
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_PASSWD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_PASSWD"
    apt-get -y install mysql-server

    echo -e "\n--- Setting up our MySQL user and db ---\n"

    mysql -uroot -p$DB_PASSWD -e "CREATE DATABASE $DB_NAME"
    mysql -uroot -p$DB_PASSWD -e "GRANT USAGE ON *.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWD'"
    mysql -uroot -p$DB_PASSWD -e "GRANT ALL PRIVILEGES on *.* to '$DB_USER'@'localhost' identified by '$DB_PASSWD'"
fi

# virtualenv global setup
if ! command -v pip; then
    easy_install -U pip
fi
if [[ ! -f /usr/local/bin/virtualenv ]]; then
    pip install virtualenv virtualenvwrapper stevedore virtualenv-clone
fi

# bash environment global setup
cp -p $PROJECT_ROOT/install/bashrc /home/vagrant/.bashrc

# virtualenv setup for project
su - vagrant -c "/usr/local/bin/virtualenv $VIRTUALENV_DIR --python=/usr/bin/python && \
    echo $PROJECT_DIR > $VIRTUALENV_DIR/.project"

echo "workon $VIRTUALENV_NAME" >> /home/vagrant/.bashrc