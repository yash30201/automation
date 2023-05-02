#!bin/bash

# capture the output of a command so it can be retrieved with ret
cap () { tee /tmp/capture.out; }

# return the output of the most recent command that was captured by cap
ret () { cat /tmp/capture.out; }

# Usage
# --------------------------------
# $ find . -name 'filename' | cap
# /path/to/filename
#
# $ ret
# /path/to/filename
# --------------------------------
