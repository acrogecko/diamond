#!/bin/bash

echo Enter DMD passphrase to stake:
read dmdpass
diamondd -datadir=/data/dmd walletpassphrase $dmdpass 99999999 true
echo Staking has enable!
