#!/bin/bash

for drop_file in /dropbox/*.conf
do
        conf_file="/etc/cups/"`basename $drop_file`;

        if [ $conf_file -ot $drop_file ];
        then
                cp $drop_file $conf_file;
        fi
done

