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
    "logic")
        python3 logic/logic.py $prog
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