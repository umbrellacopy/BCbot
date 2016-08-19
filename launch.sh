#!/bin/bash
   echo -e "\033[38;5;208m"
   echo -e "     @BCbot Copy   "
   echo -e "         \033[0;00m"
   echo -e "\e[36m"
sudo service redis-server start
while true; do
	 lua botbase.lua
	sleep 5s
done