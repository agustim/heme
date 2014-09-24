#!/bin/sh

mkdir -p /www/heme
cp -R web/* /www/heme/
cp analisis.lua /www/cgi-bin/
chmod agu+x /www/cgi-bin/analisis.lua


