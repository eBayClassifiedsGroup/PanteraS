#!/bin/bash

DC=${DC:-"UNKNOWN"}
BOOTSTRAP=${BOOTSTRAP:-" -bootstrap-expect 1"}
MODE=${MODE:-" -server"}

eval "$(cat fig.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > fig.yml
