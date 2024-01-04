#!/bin/bash

for i in $(systemctl status postgresql* | grep config_file | cut -d'=' -f2); do echo "$i uses ->" $(cat $i | grep "port =" | cut -d'#' -f1 ) ; done;
