#!/bin/bash

if [[ -e "/sys/kernel/mm/ksm/run" ]]; then
	echo 1 >/sys/kernel/mm/ksm/run
	echo 1000 >/sys/kernel/mm/ksm/sleep_millisecs
fi
