# README

# Introduction
Hi there. This is the zombie SNS rest API.
There are a few prerequisites necessary to be able to use this API.
I am using Ubuntu on WSL 2 as such these instructions are for Ubuntu on WSL 2

## Installing Ruby
It is probably a good idea to use something like rbenv to keep track of the versions of ruby that is being used to run the projects as such running the following commands will install ruby with rbenv

```
sudo apt-get update
```
```
sudo apt-get upgrade
```
```
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev
```
```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```
```
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
```
```
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
```
```
exec $SHELL
```
```
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```
```
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
```
```
exec $SHELL
```
```
rbenv install 3.1.2
```
```
rbenv global 3.1.2
```
```
gem install bundler
```
## Installing Rails
The framework that will be used for the server is Rails, as such the following commands are necessary to install rails on your local machine

```
gem install rails -v 7.0.4
```
```
rbenv rehash
```
## Setting up PostgreSQL database
The database being used for this API is postgrSQL, as such the following steps are necessary to be able to set the database up correctly.

```
sudo apt install postgresql postgresql-contrib
```
Then create a password for the default user 'postgres'
```
sudo passwd postgres
```
Check the status of the postgres database server
```
sudo service postgresql status
```
If the server is not running start it
```
sudo service postgresql start
```
Go into the postgres terminal
```
sudo -u postgres psql
```
Create the api user role
```
CREATE ROLE zombiesnsmaster WITH LOGIN SUPERUSER PASSWORD 'supersecret';
```
This step is necessary for machines running WSL2
```
sudo apt install libpq-dev
```
## Setting up the API
Run the following command to install gems in the repo
```
bundle install --path vendor/bundle
```
Run the following command to create the database
```
rake db:create
```
Run the following command to migrate the database
```
rake db:migrate
```
Now the server should be ready to run. Accordingly run the following command
```
rails s
```
## Swagger API documentation
In order to see the swagger api documentaion of this API, check the port that the server is running on and add '/api-docs' to the end like so
```
http://127.0.0.1:3000/api-docs
```
## Postman collection
A collection of payloads for the corresponding endpoints are provided in the repo as a postman v2.1 collection, and it may be convenient to use these payloads to send JSON payloads to the API. The name of the collection is 
```
zombieSnsEndpoints.postman_collection.json
```