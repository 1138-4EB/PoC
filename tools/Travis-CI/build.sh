apt-get update -qq
apt-get install -y libgnat-4.9 git
git clone --recursive -b master --depth=1 https://github.com/1138-4EB/PoC.git ./
pip3 install --upgrade pip
pip3 install -r tools/Travis-CI/requirements.txt
./poc.sh configure --relocated
./tools/Travis-CI/ghdl.setup.sh
./tools/Travis-CI/poc.setup.sh
./tools/Travis-CI/poc.run.sh "PoC.*"