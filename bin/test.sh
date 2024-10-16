#!/bin/bash

test_fnc() {
	 echo "test this"
}
PS3="do do da"
options=("this")
select opt in "${options[@]}"; do
    case $opt in
	"this")
	    echo "triggered"
	    test_fnc
	    break
	    ;;
	*) echo "invalid"
    esac

done

	
