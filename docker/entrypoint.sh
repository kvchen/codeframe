language=$1
prog=$2

cp -r /opt/runner/code/* /opt/runner/env

/bin/bash /run.sh $language $prog