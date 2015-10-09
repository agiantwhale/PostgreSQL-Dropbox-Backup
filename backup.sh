#!/bin/bash
#
# PostgreSQL Dropbox Backup
#
# Copyright (C) 2013-2014 Il Jae Lee <jae@lemoneda.com>
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Il Jae
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Declaring some directories
uploader_folder="/tmp/Dropbox-Uploader"
uploader_file="$uploader_folder/dropbox_uploader.sh"
dump_folder="/tmp/dbdump"

# Check if our uploader exists. If not, clone the dropbox uploader.
if [[ ! -a $uploader_folder ]]; then
    echo "=============================================================="
    echo "PostgreSQL-Backup: Unable to locate library. Cloning..."
    echo -e "============================================================== \n"
    eval "git clone https://github.com/andreafabrizi/Dropbox-Uploader/ $uploader_folder/"
    eval "chmod +x $uploader_file"
fi

# Check if configuration is set.
if [[ ! -a ~/.dropbox_uploader ]]; then
    echo "=============================================================="
    echo "PostgreSQL-Backup: Dropbox configuration not set."
    echo -e "============================================================== \n"
    source $uploader_file
fi

# Parse the DATABASE_URL environment variable.
proto="$(echo $DATABASE_URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
url="$(echo ${DATABASE_URL/$proto/})"
user="$(echo $url | grep : | cut -d: -f1)"
password="$(echo ${url/$user:/} | grep @ | cut -d@ -f1)"
host="$(echo ${url/$user:$password@/} | grep : | cut -d: -f1)"
port="$(echo ${url/$user:$password@$host:/} | grep / | cut -d/ -f1)"
database="$(echo $url | grep / | cut -d/ -f2-)"

# Make the dump directory if it doesn't exists already
mkdir -p $dump_folder

# Filepath goes here (Dump may take a long time)
filepath="$dump_folder/$(date +%s).dump"

# Now, dump all of that on to a temporary file.
eval "PGPASSWORD=$password pg_dump -U $user $database > $filepath"

# Determine the destination
DEST="/"
if [ -n $DESTINATION ];
then
   let DEST=$DESTINATION;
fi

# Upload the dump.
source $uploader_file upload $filepath $DEST

# Delete the dump.
rm $filepath
