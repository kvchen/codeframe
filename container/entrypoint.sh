language=$1
prog=$2

timeout 5 /bin/bash /run.sh $language $prog
exit_status=$?

rm -rf /opt/code/*
exit $exit_status