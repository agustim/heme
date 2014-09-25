#!/bin/sh

mkdir -p /www/heme
cp -R web/* /www/heme/
cp analisis.lua /usr/bin/
chmod agu+x /usr/bin/analisis.lua
cp dwanalysis /www/cgi-bin
chmod agu+x /www/cgi-bin/dwanalysis


