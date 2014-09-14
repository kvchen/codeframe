language=$1
prog=$2

if [ -z $2 ]; then
    echo "No file provided!"
    exit 1
fi

if [ ! -f $2 ]; then
    echo "File does not exist!"
    exit 1
fi

case "$language" in
    "c")
        gcc $prog && ./a.out
        ;;
    "hog")
        cp /opt/includes/hog/* /opt/env
        mv /opt/env/snippet /opt/env/snippet.py
        python3 /opt/env/autograder.py
        ;;
    "logic")
        python3 /opt/includes/logic/logic.py $prog
        ;;
    "python2")
        python2 $prog
        ;;
    "python" | "python3")
        python3 $prog
        ;;
    "ruby")
        ruby $prog
        ;;
    "scheme")
        racket -f $prog
        ;;
    *)
        echo "Unrecognized language!"
        exit 1
        ;;
esac