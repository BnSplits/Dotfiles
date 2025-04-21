#!/bin/bash

echo "Hidden files/folders in home dir to delete:"
find ~ -maxdepth 1 -name ".*" ! -name "." ! -name ".." -print

read -rp "Proceed with deletion? (y/n): " answer
case ${answer:0:1} in
  y|Y)
    find ~ -maxdepth 1 -name ".*" ! -name "." ! -name ".." -exec rm -rf {} +
    echo "Deleted hidden items."
  ;;
  *)
    echo "Aborted."
    exit 1
  ;;
esac
