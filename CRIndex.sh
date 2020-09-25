#! /bin/bash

PDF2TXT=pdf2txt.py
RESULT=CRIndex.csv

#
# Command line handling
#
usage()
{
    echo "Usage: $0 [options] <PDF_PATH>"

    exit 0
}

while getopts 'h' OPT; do
    case $OPT in
        h)
            usage;;
        ?)
            usage;;
    esac
done

failed_exit()
{
    echo "$0: $1"
    exit 1
}

shift $((OPTIND-1))
PDF_PATH=$1
[ x$PDF_PATH != x ] || failed_exit "PDF_PATH not given"
[ -d $PDF_PATH ] || failed_exit "$PDF_PATH not existed"
[ -x "$(command -v $PDF2TXT)" ] || failed_exit "pdf2txt.py not found"
[ -x "$(command -v perl)" ] || failed_exit "perl not found"

for f in `find $PDF_PATH -name '*.pdf'`; do
    $PDF2TXT -p 1 $f | perl -ne 'print "$1, " if /发布日期.*?([-0-9]+)/' >> $RESULT.tmp
    $PDF2TXT -p 2 $f | perl -ne 'print "$1\n" if /1、.*平均.*?([0-9.]+%)/' >> $RESULT.tmp
done

cat $RESULT.tmp | sort -t '-' -o $RESULT

rm -f $RESULT.tmp

