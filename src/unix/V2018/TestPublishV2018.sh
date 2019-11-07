#!/bin/bash
# ./apic.sh my@login.com myPassword

APIC_LOGIN=org1owner
APIC_PASSWORD=Passw0rd!
APIC_REALM=provider/default-idp-2
APIC_SRV=manager.159.8.70.34.xip.io
APIC_EXE_Full_PATH=/home/desprets/test_scripts/apic2018.sh

IFS=$'\n'

echo "1) List products";
echo "2) Backup drafts";
echo "3) Backup all catalogs";
echo "Enter choice";
read choice

case $choice in
1) echo "List products chosen" ;;
2) echo "Backup drafts chosen" ;;
3) echo "Backup all catalogs chosen" ;;
esac

$APIC_EXE_Full_PATH login -s $APIC_SRV -u $APIC_LOGIN -p $APIC_PASSWORD -r $APIC_REALM

for ORGANIZATION in `$APIC_EXE_Full_PATH orgs:list --my -s $APIC_SRV`
do
    echo ""
    echo "* $ORGANIZATION *"
    echo ""

    for CATALOG_URL in `$APIC_EXE_Full_PATH catalogs:list -s $APIC_SRV -o $ORGANIZATION`
    do
        CATALOG=${CATALOG_URL##*/}
        echo "- $CATALOG"
        #echo "| $CATALOG_URL"

        for PRODUCT_URL in $($APIC_EXE_Full_PATH products -s $APIC_SRV -o $ORGANIZATION --catalog $CATALOG --scope catalog)
        do
            PRODUCT=${PRODUCT_URL%% *}
            echo "|- $PRODUCT"
            #echo "|  $PRODUCT_URL"

            for FILE_TEXT in '$APIC_EXE_Full_PATH drafts:pull $PRODUCT -s $APIC_SRV -o $ORGANIZATION'
            do
                FILE_BLOCK=${FILE_TEXT##*[}
                FILE=${FILE_BLOCK%%]*}
                echo "|  * $FILE"
            done
        done
    done

    echo ""

    for ITEM in 'apic drafts -s $APIC_SRV -o $ORGANIZATION'
    do
        echo "* $ITEM"
    done
done
