# Fix the terminal size on serial consoles
if tty | grep -q ^/dev/ttyS[0-9] ; then
	eval $(resize)
fi
