README
------

HElp ME to install a node

Un sistema per ajudar a l'instal·lador a posar la antena.

INSTALL

1. Copy all file in /tmp and execute install.sh

2. (Optional) Change /etc/rc.button/reset to add reset from a second execte /usr/bin/analisis.lua (something like this):

---8<------------------------------------------------------------
	#!/bin/sh

	[ "${ACTION}" = "released" ] || exit 0

	. /lib/functions.sh

	logger "$BUTTON pressed for $SEEN seconds"

	if [ "$SEEN" -lt 1 ]
	then
	        /usr/bin/analisis.lua
	elif [ "$SEEN" -gt 5 ]
	then
	        echo "REBOOT" > /dev/console
	        sync
	        reboot
	elif [ "$SEEN" -gt 15 ]
	then
	        echo "FACTORY RESET" > /dev/console
	        jffs2reset -y && reboot &
	fi
---8<------------------------------------------------------------

USE

1. Prepara la antena apuntant al nord. 
2. Reset
3. Mentre els leds verds fan xispetes anar girant la antena a raó de 22.5 (La meitat de 45 Graus). Quan els leds ho indiquin.
4. Fer-ho 16 vegades i veure els resultats a http://<node>/heme/


