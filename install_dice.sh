#! /bin/bash

#create folders
cd $HOME
mkdir deep_learning
cd deep_learning
mkdir venv tmp
virtualenv venv --no-site-packages --python /usr/bin/python2.7

source $HOME/deep_learning/venv/bin/activate
export PREFIX=$HOME/deep_learning/venv
OLDPATH=$PATH
export PATH=$PREFIX/bin:$PATH
TMP_PATH=$HOME/deep_learning/tmp

cd tmp

#install local libraries

# install m4
cd $TMP_PATH
wget http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
tar xzf m4-1.4.17.tar.gz
echo "going to $TMP_PATH/m4-*/"
cd $TMP_PATH/m4-1.4.17
./configure --prefix=$PREFIX
make && make install || exit 1

# install autoconf
cd $TMP_PATH
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar xzf autoconf-2.69.tar.gz
cd $TMP_PATH/autoconf-2.69
./configure --prefix=$PREFIX
make && make install || exit 1

# install cmake
cd $TMP_PATH
wget https://cmake.org/files/v3.4/cmake-3.4.1-Linux-x86_64.sh
sh cmake-3.4.1-Linux-x86_64.sh --prefix=$PREFIX --exclude-subdir

# install libsodium
cd $TMP_PATH
wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.6.tar.gz
tar xzf libsodium-1.0.6.tar.gz
cd $TMP_PATH/libsodium-1.0.6/
autoconf
./configure --prefix=$PREFIX

make && make install || exit 1

export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/include:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
export DYLD_LIBRARY_PATH=$PREFIX/lib:\$DYLD_LIBRARY_PATH

# install zeromq
cd $TMP_PATH
git clone https://github.com/zeromq/libzmq.git
cd $TMP_PATH/libzmq
./autogen.sh
./configure --prefix=$PREFIX
make && make install || exit 1

# install ipython etc
pip install --upgrade pip
pip install setuptools
pip install setuptools --upgrade
pip install ipython[notebook] jupyter

# install openblas
cd $TMP_PATH
git clone https://github.com/xianyi/OpenBLAS.git
cd $TMP_PATH/OpenBLAS
make NO_AFFINITY=1 USE_OPENMP=1 && make install

# install torch
cd $TMP_PATH

git clone https://github.com/torch/distro.git $TMP_PATH/torch --recursive
cd $TMP_PATH/torch

export CMAKE_LIBRARY_PATH=$PREFIX/lib
export ZMQ_DIR=$PREFIX/include
export ZMQ_INCDIR=$PREFIX/include

sed -i '/export PATH=$OLDPATH # Restore anaconda distribution if we took it out./c\$PREFIX/bin/luarocks install lzmq ZMQ_DIR=$PREFIX/include ZMQ_INCDIR=$PREFIX/include' install.sh

sh install.sh -b
