#!/bin/bash

if [[ $# != 1 ]]
then
  echo "provide as argument the number of rows"
  exit 1
fi

time ./generate $1

[[ $1 -lt 1000 ]] && time scala OutRunCalculator huge.txt

sudo purge
time ./outrun-c huge.txt
sudo purge
time ./outrun-asm huge.txt
