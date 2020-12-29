#!/bin/sh
## a userdata script to bring an amazon linux 2 instanec up and running as a local graph node with badger subgraph

### Set ethnode_url to the url of a eth node that will be used
export ETHNODE_URL="mainnet:https://mainnet.infura.io/v3/7bac10a8120d4fce81f9429914ac72c5"

yum install -y git
yum install -y docker
/bin/systemctl start docker.service
## Install Node and yarn
curl --silent --location https://rpm.nodesource.com/setup_14.x | bash -
yum -y install nodejs
npm install yarn -g
## Install docker compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## Setup and install graph-node
mkdir /graph-node ### will run everything from here
cd /graph-node

git clone https://github.com/graphprotocol/graph-node
cd graph-node/docker
mv docker-compose.yml docker-compose.yml.orig
sed "s|mainnet:http://host.docker.internal:8545|$ETHNODE_URL|g" docker-compose.yml.orig > docker-compose.yml
docker-compose up -d
cd /
### This system should now be running as a graph node
### Now we need to install some graphs

### Badger subgraph
mkdir -p subgraphs/badger-subgraph
cd subgraphs/badger-subgraph
git clone https://github.com/Badger-Finance/badger-subgraph
cd badger-subgraph
echo "export GRAPH_PATH=\"Badger-Finance/badger-subgraph\"" > .envrc
### fighting with yarn
yarn
yarn codegen
yarn create-local badger-subgraph
yarn deploy-local badger-subgraph

