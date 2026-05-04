#!/bin/bash

# Inputs: <orginal xxx.com file> <conformers xxx.xyz file>

origFile=$1
confFile=$2

header=$(awk '1;/[0-9] 1/{exit}' $origFile)
echo "__________\n"
echo "$header\n"
echo "__________\n"

bondList=$(awk '/^ 1 /,0' $origFile)
echo "__________\n"
echo "$bondList"
echo "__________\n"

awk 'BEGIN{RS="  55";ORS="";i=0;} {flname="conf"i".com"; print > flname; i++}' $confFile
rm conf0.com

echo $header
for file in conf*.com
do
  echo $file
  echo "$header" > tmp.tmp
  # echo $header
  tail -n +3 $file >> tmp.tmp
  echo >> tmp.tmp
  # cat tmp.tmp
  mv tmp.tmp $file
  # sed -i.bak -e "1,2d;3s;^;$header" $file
  echo "$bondList" >> $file
done
