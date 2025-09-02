#!/bin/bash
# Author : exception7601
# Purpose: Update submodule 
# Tested on : macOS 14 Sonoma

git submodule update --init --recursive
git submodule update --remote --checkout
