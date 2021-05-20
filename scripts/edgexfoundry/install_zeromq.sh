#!/bin/bash

# Download zeromq
# Ref http://zeromq.org/intro:get-the-software
wget https://github.com/zeromq/libzmq/releases/download/v4.2.2/zeromq-4.2.2.tar.gz

# Unpack tarball package
tar -C /usr/local/ -xvzf zeromq-4.2.2.tar.gz

# Install dependency
sudo apt-get update && \
sudo apt-get install -y libtool pkg-config build-essential autoconf automake uuid-dev

# Create make file
cd /usr/local/zeromq-4.2.2
./configure

# Build and install(root permission only)
sudo make install

# Install zeromq driver on linux
sudo ldconfig

# Check installed
ldconfig -p | grep zmq

echo "# Expected"
echo "############################################################"
echo "# libzmq.so.5 (libc6,x86-64) => /usr/local/lib/libzmq.so.5"
echo "# libzmq.so (libc6,x86-64) => /usr/local/lib/libzmq.so"
echo "############################################################"
