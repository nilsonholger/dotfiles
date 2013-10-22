#! /usr/bin/env zsh
#
# efib (efi backup) saves gpt output for manual reconstruction and binary
# backup of guid mbr/header/table and EFI partition
#
# Copyright (C) 2012 nilsonholger@hyve.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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


