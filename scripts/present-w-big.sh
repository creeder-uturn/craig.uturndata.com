#!/bin/bash
if [ -z $1 ]; then
  echo "What is it called? (pass an argument)"
  exit
fi

mkdir $1
cd $1
npx degit tmcw/big
