USER MANUAL FOR GEOCOQINE-EUCLID
======================================

### INSTALLATION

Commands to run on a fresh Debian9 instance

```
sudo apt update
sudo apt upgrade
sudo reboot

sudo apt update
sudo apt install build-essential emacs git m4 curl bubblewrap

sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)

opam init
eval `opam config env`
opam switch create 4.06.0

eval `opam config env`
opam install menhir coq.8.8.1

git clone https://github.com/Deducteam/Dedukti.git <dedukti-path>
cd <dedukti-path>
make install

git clone --recursive https://github.com/Deducteam/GeoCoqInE-Euclid.git <coqine-path>
cd <coqine-path>

<edit .coqrc file with current path>

make
```
