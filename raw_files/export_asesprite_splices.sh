if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

mkdir ${1}_sliced
/Applications/Aseprite.app/Contents/MacOS/aseprite -b ${1} --save-as ${1}_sliced/{slice}.png
