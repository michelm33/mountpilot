#!/bin/bash
#
# Test preparation script.
# This launches a dummy docker container for the sake of having one showing up with sumo
# in the test
#
# Same reason for checking if an adb device is connected
#

if [ -z "${__SUDO__}" ] ; then
    __SUDO__="sudo "
fi

function banner()
{
cat<<EOF >&2

$1

EOF

}
#return 0 # FOR DEBUG REMOVE 
cat<<EOF >&2

**************************************************************************

Executing pre-test script

**************************************************************************

EOF

# Updating PATH
export PATH=/usr/bin/mountpilot:$PATH

if which docker &>/dev/null ; then
    # ----------------------------------------------------------------------------------
    banner "Stopping previous docker container named 'test_mountpilot'..."

    ${__SUDO__}docker stop test_mountpilot &>/dev/null || echo "container 'test_mountpilot' not running'"
    ${__SUDO__}docker remove test_mountpilot &>/dev/null || echo "container 'test_mountpilot' not running'"

    # ----------------------------------------------------------------------------------
    banner "Running the docker container named 'test_mountpilot'..."
    ${__SUDO__}docker run --rm -d --name "test_mountpilot" --mount type=bind,src=/home/michel/,dst=/home/michel ubuntu /bin/bash -c "sleep infinity" >&2 && echo OK >&2 || return 1
else
    echo "WARNING: no docker not available"
fi

# ----------------------------------------------------------------------------------
banner "Checking mountpilot version"

mp=$(which sumo)
[ "$mp" = "/usr/bin/mountpilot/sumo" ] && echo OK >&2 || (echo "'$mp' unexpected path" >&2 && return 1)

# ----------------------------------------------------------------------------------
banner "Testing if an adb device is connected"

# When inside a docker, there's no docker and no adb
if which docker &>/dev/null ; then
    sumo|grep 'adb://usb' >&2
    if [ $? -ne 0 ] ; then
        echo "Error: looks as no device adb://usb was found. Please connect a phone and ensure a line showing 'adb://usb' appears. You can also execute 'adb devices' to check it." >&2
        return 1
    fi
fi

# ----------------------------------------------------------------------------------
banner "Unmounting test sticks for clean start"

for i in 1 2 3 ; do
${__SUDO__}umount /dev/sdb &>/dev/null
${__SUDO__}umount /dev/sdb1 &>/dev/null
${__SUDO__}umount /dev/sdc &>/dev/null
${__SUDO__}umount /dev/sdc1 &>/dev/null
${__SUDO__}umount /dev/sdd &>/dev/null
${__SUDO__}umount /dev/sdd1 &>/dev/null
done

banner "Test preparation was successful!"

