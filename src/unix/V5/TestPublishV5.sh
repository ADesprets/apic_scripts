#!/bin/bash
# ./apic.sh my@login.com myPassword

APIC_LOGIN=$1
APIC_PASSWORD=$2
APIC_SRV=eu.apiconnect.ibmcloud.com


IFS=$'\n'

apic login --server $APIC_SRV -u $APIC_LOGIN -p $APIC_PASSWORD

for ORGANIZATION in 'apic organizations  --server $APIC_SRV'
do
    echo ""
    echo "* $ORGANIZATION *"
    echo ""

    for CATALOG_URL in 'apic catalogs --server $APIC_SRV --organization $ORGANIZATION'
    do
        CATALOG=${CATALOG_URL##*/}
        echo "- $CATALOG"
        #echo "| $CATALOG_URL"

        for PRODUCT_URL in $(apic products --server $APIC_SRV --organization $ORGANIZATION --catalog $CATALOG)
        do
            PRODUCT=${PRODUCT_URL%% *}
            echo "|- $PRODUCT"
            #echo "|  $PRODUCT_URL"

            for FILE_TEXT in 'apic drafts:pull $PRODUCT --server $APIC_SRV --organization $ORGANIZATION'
            do
                FILE_BLOCK=${FILE_TEXT##*[}
                FILE=${FILE_BLOCK%%]*}
                echo "|  * $FILE"
            done
        done
    done

    echo ""

    for ITEM in 'apic drafts --server $APIC_SRV --organization $ORGANIZATION'
    do
        echo "* $ITEM"
    done
done

