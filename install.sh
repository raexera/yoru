echo "We need an AUR helper. It is essential. 1) paru       2) yay"
read -r -p "What is the AUR helper of your choice? (Default is paru): " num

if [ $num -eq 2 ]
then
    HELPER="yay"
fi

if ! command -v $HELPER &> /dev/null
then
    echo "It seems that you don't have $HELPER installed, I'll install that for you before>
        git clone https://aur.archlinux.org/$HELPER.git ~/.srcs/$HELPER
        (cd ~/.srcs/$HELPER/ && makepkg -si )
fi

$HELPER -Sy
