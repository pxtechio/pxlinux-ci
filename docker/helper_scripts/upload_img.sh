#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No File or Target File Name was supplied. Use -h for more information"
    exit 128
fi

if [ $1 == "-h" ]; then
    echo ""
    echo "[File Path] [Target File Name]"
    echo "[File Path]: valid file"
    echo "[Target File Name]: make sure you add the proper extension."
    echo "Example: "
    echo "./uploadImage image-name.img.zip PixieQPCoreImage.zip"
    echo ""
    exit 1
fi

if [ $# -lt 2 ]; then
    echo "To few arguments. Use -h for more information"
    exit 1
elif [ $# -gt 2 ]; then
    echo "To many arguments. Use -h for more information"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "File Not Found"
    exit 1
fi

FILE=$1
FILE_TARGET_NAME=$2
MONTHLY=$(date +%Y-%m)
WEEKLY=$(date +%V)

IFS='.' read -ra ARR <<< "$FILE_TARGET_NAME"

aws s3 cp $FILE s3://pxlinux/LATEST/$FILE_TARGET_NAME
aws s3 cp $FILE s3://pxlinux/monthly/${ARR[0]}$MONTHLY"."${ARR[1]}
aws s3 cp $FILE s3://pxlinux/weekly/${ARR[0]}$WEEKLY"."${ARR[1]}

