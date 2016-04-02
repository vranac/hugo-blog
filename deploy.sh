#!/bin/bash

rm -rf public/*
hugo
rsync -arvz public/ vranac@code4hire.com:~/webapps/c4h_hugo