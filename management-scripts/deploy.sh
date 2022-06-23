#!/bin/sh

# To run
# docker run -d --network host --rm -p 8080:8080 --name microfab -v ~/mf/code:/viper ibmcom/ibp-microfab
# docker exec -it microfab /viper/deploy.sh

# To terminate
# docker kill microfab

MountedDir=/viper
PeerPort=2004
OrdererPort=2002
OrgAdminMSPDir=$HOME/viper/msp
Org=Org1MSP
channelName=channel1
ccpackage=${MountedDir}/chaincode.tgz
ccname=basic

echo 'Creating the Admin MSP directory'
mkdir -p $OrgAdminMSPDir/signcerts
mkdir -p $OrgAdminMSPDir/keystore
mkdir -p $OrgAdminMSPDir/cacerts
mkdir -p $OrgAdminMSPDir/admincerts

echo 'extracting the Admin MSP from microfab'
componentData=$(curl http://console.127.0.0.1.nip.io:8080/ak/api/v1/components)
echo $componentData | jq '.[] | select(.id == "org1admin")' | jq -r '.cert' | base64 -d > ${OrgAdminMSPDir}/signcerts/cert.pem
echo $componentData | jq '.[] | select(.id == "org1admin")' | jq -r '.private_key' | base64 -d > ${OrgAdminMSPDir}/keystore/key.pem
echo $componentData | jq '.[] | select(.id == "org1admin")' | jq -r '.ca' | base64 -d > ${OrgAdminMSPDir}/cacerts/cert.pem
echo $componentData | jq '.[] | select(.id == "org1admin")' | jq -r '.cert' | base64 -d > ${OrgAdminMSPDir}/admincerts/cert.pem

export CORE_PEER_ADDRESS=localhost:$PeerPort
export CORE_PEER_MSPCONFIGPATH=$OrgAdminMSPDir
export CORE_PEER_LOCALMSPID=$Org
# peer channel getinfo -c $channelName

# install the chaincode and get it's id
echo 'installing chaincode'
peer lifecycle chaincode install $ccpackage
packageid=$(peer lifecycle chaincode queryinstalled | awk '/^Package ID/ {print $3;}' | cut -d"," -f1)
echo package id: $packageid

# approve for the org
echo 'approving chaincode'
peer lifecycle chaincode approveformyorg -o localhost:$OrdererPort --channelID $channelName --name $ccname --version 1 --sequence 1 --waitForEvent --package-id $packageid

# commit it
echo 'commiting chaincode'
peer lifecycle chaincode commit -o localhost:$OrdererPort --channelID $channelName --name $ccname --version 1 --sequence 1