cd `dirname $0`

skip_host=0

while getopts "hs" opt; do
    case "$opt" in
    h|\?)
        echo "Help you!"
        exit 0
        ;;
    s)  skip_host=1
        ;;
    esac
done

if [ $skip_host -eq 0 ]
    then
        ./01-host-install.sh
fi
exit 0
./02-download.sh
./03-box-init.sh
./04-box-softboil.sh
./05-box-up.sh

#need to wait for box to be ready for login here

./06-box-setup.sh
./09-box-down.sh
