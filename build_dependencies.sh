#!/bin/bash
source_dir=$(pwd)

echo "WARNING: You will need GCC 7 or newer, GCC 6 does not implement C++17 yet!"

# Install gtest and gflags. It's a bit fidgety, but works:
sudo apt-get install -y wget cmake sudo libgtest-dev libgflags-dev libz-dev libelf-dev cmake g++ python3-pip
sudo apt-get install -y libboost-system-dev libboost-thread-dev libboost-date-time-dev

# Required for the training data generation python script.
pip3 install numpy absl-py

# Build the C++ libraries.
cd /usr/src/gtest
sudo cmake ./CMakeLists.txt
sudo make
sudo cp *.a /usr/lib

# Now get and the other dependencies
cd $source_dir
mkdir third_party
cd third_party

# Download Dyninst.
# wget https://github.com/dyninst/dyninst/archive/v9.3.2.tar.gz
# tar xvf ./v9.3.2.tar.gz
# Download PicoSHA, pe-parse, SPII and the C++ JSON library.
# git clone https://github.com/okdshin/PicoSHA2.git
# git clone https://github.com/trailofbits/pe-parse.git/v1.20
# git clone https://github.com/PetterS/spii.git
# mkdir json
# mkdir json/src
# cd json/src
# wget https://github.com/nlohmann/json/releases/download/v3.1.2/json.hpp
# cd ../..

# Build PE-Parse.
cd pe-parse
sed -i -e 's/-Wno-strict-overflow/-Wno-strict-overflow -Wno-ignored-qualifiers/g' ./cmake/compilation_flags.cmake
cmake ./CMakeLists.txt
make -j
cd ..

# Build SPII.
cd spii
cmake ./CMakeLists.txt
make -j
sudo make install
cd ..

# Build Dyninst
cd dyninst-9.3.2
cmake ./CMakeLists.txt
# Need to limit parallelism because 8-core DynInst builds exhaust 30 Gigs of
# RAM on my test systems.
make -j 4
sudo make install
sudo ldconfig
cd ..

# Finally build functionsimsearch tools
cd ..
make -j

