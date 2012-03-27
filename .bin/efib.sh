#! /bin/sh
#
# efib (efi backup) saves gpt output for manual reconstruction and binary
# backup of guid mbr/header/table and EFI partition

# abort
function abort () {
    echo $1
    exit
}

# check input
([ -n $1 ] && [ -n "$2" ]) || abort "USAGE: `basename $0` \$DEVICE_PATH \$BACKUP_NAME"
[ -b $1 ] || abort "WARNING: $1 is not a valid block device!"
[ -r $2.gpt.txt ] && abort "WARNING: $2.gpt.txt already exists!"
[ -r $2.40.bin ] && abort "WARNING: $2.40.bin already exists!"
[ -r $2.efi.bin ] && abort "WARNING: $2.efi.bin already exists!"

# create gpt output text copy, first with UID, then with partition names
sudo gpt -r show $1 2>/dev/null > $2.gpt.txt
sudo echo >> $2.gpt.txt
sudo gpt -r show -l $1 2>/dev/null >> $2.gpt.txt

# create gpt
sudo dd bs=512 count=40 if=$1 of=$2.40.bin 2>/dev/null
sudo dd bs=512 skip=40 count=409600 if=$1 of=$2.efi.bin 2>/dev/null


