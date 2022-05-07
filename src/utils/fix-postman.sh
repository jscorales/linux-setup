#!/bin/bash

wget -O postman.tar.gz https://dl.pstmn.io/download/latest/linux64
tar -xzf ./postman.tar.gz
sudo rm -r /usr/share/postman
sudo mv Postman /usr/share/postman
