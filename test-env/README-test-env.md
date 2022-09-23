test-env is where microfab runs outside of docker
need to create a bin and config dir with contents of binaries packages
need to create a builders directory with golang/node/java/external subdirs with the appropriate external builders in place
data for each node is created in the working dir under the node's dir in the data directory which contains both config to read and where data will be written

Currently couchdb is defaulted to not used as you need to have an instance of couchdb running

when running microfabd, need to set FABRIC_CFG_PATH to the config directory and set PATH to include bin directory