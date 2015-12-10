#! /bin/bash

wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb

sudo apt-get update
sudo api-get -y install elixir postgresql postgresql-contrib

mix local.hex

mix archive.install https://github.com/phoenixframework/phoenix/releases/download/v1.0.4/phoenix_new-1.0.4.ez

curl https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | sh
nvm install v4.2.1
nvm use v4.2.1


