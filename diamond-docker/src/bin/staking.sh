#!/bin/bash

echo Activating DMD wallet...
diamondd -datadir=/data/dmd
echo Wait for 15mins
sleep 800
diamondd -datadir=/data/dmd getinfo
#echo Please enter passphrase to stake:
read dmdpass
diamondd -datadir=/data/dmd walletpassphrase $dmdpass 99999999 true
echo Staking has enable
