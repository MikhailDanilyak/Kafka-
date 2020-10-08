#!/bin/bash
source Config.txt
Address=$AddressFirstPart$IP$AddressSecondPart
ssh -i $Filepath$KeyName $Address
