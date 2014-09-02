language=$1
prog=$2

/bin/bash /run.sh $language $prog
exit_status=$?

rm -rf /opt/code/*
exit $exit_status