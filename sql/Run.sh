#!/bin/sh

docker start onyxdb || docker run -d -p 3306:3306 --name onyxdb onyxdb --authentication_policy=mysql_native_password
