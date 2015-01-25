#!/bin/bash

mkdir -p .pdftmp
wget -q -O .pdftmp/tmpfile.pdf $1

OUT=$?
if [ $OUT -eq 0 ];then
  pdftotext -layout .pdftmp/tmpfile.pdf -
else
  echo "wget error"
fi

rm -rf .pdftmp/*
