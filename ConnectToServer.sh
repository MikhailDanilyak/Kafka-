#!/bin/bash
source Config.txt
ADDRESS=$ADDRESS_FIRST_PART$IP$ADDRESS_SECOND_PART
ssh -i $KEY_FILEPATH $ADDRESS
