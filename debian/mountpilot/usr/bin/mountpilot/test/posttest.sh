#!/bin/bash
#
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


cat<<EOF

**************************************************************************

Executing post test script

**************************************************************************

EOF

if which docker &>/dev/null ; then
    # ----------------------------------------------------------------------------------
    banner "Stopping docker container named 'test_mountpilot'..."

    ${__SUDO__}docker stop test_mountpilot &>/dev/null || echo "container 'test_mountpilot' not running'"
    ${__SUDO__}docker remove test_mountpilot &>/dev/null || echo "container 'test_mountpilot' not running'"
else
    echo "WARNING: no docker not available"
fi
