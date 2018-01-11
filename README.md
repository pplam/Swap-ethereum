# Swap@ethereum
ATN cross chain swap router at ethereum
## Installation
~~~shell
git --recursive clone https://github.com/ATNIO/Swap-ethereum.git
cd Swap-ethereum
npm install
~~~
## Deployment
Edit config.mk, set all fields properly, then
~~~shell
make
~~~
## Usage
Setup a demo with
~~~shell
make demo
~~~
then run worker by
~~~shell
npm run listen
~~~
Now launch another shell and
~~~shell
cd demo
./swap <chainName>,<toAddress>,<amount>[,gas]
~~~
