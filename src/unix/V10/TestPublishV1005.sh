#!/bin/bash
# ./apic.sh my@login.com myPassword
# Usage: TestPublishV1005.sh org1owner1@fr.ibm.com Passw0rd! manager.159.8.70.34.xip.io provider/default-idp-2

# Licensed Materials - Property of IBM
#
# Copyright IBM Corp. 2017, 2023 All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
# Author: Arnauld Desprets - arnauld_desprets@fr.ibm.com
# Version: 1.0 - September 2019
# Version: 2.0 - June 2019
# Add draft products and API in the list operation
# Version: 3.0 - June 2023

# Important: supports only one organisation (we will put everything as if it was one organisation)
# Tested on Ubuntu 22.04.3 LTS

APIC_LOGIN=<org_user_id>
APIC_PASSWORD=<org_user_pwd>
APIC_REALM=provider/default-idp-2
APIC_SRV=<APIC server>
APIC_EXE_Full_PATH=<absolute path for apic>
ORG_FOR_DRAFT=<org to create products and apis>

echo $APIC_EXE_Full_PATH

IFS=$'\n'

echo "Login in to $APIC_SRV"
# --my is important, we are login in to the Manager and not Cloud Management Console
if ! $APIC_EXE_Full_PATH login -s $APIC_SRV -u $APIC_LOGIN -p $APIC_PASSWORD -r $APIC_REALM > /dev/null 2>&1; then
    ech "Could not log to $APIC_SRV check server and credentials."
    exit 1
fi

curdir=$(pwd)
echo "$curdir"

echo "1) List products";
echo "2) Backup drafts";
echo "3) Backup all catalogs";
echo "4) Push drafts from a directory";
echo "Enter choice";
read choice

case $choice in
    1) # List products
    echo "List of products and APIs in draft and in all catalogs"
    echo "Getting the names of organizations"
    for ORGANIZATION in `$APIC_EXE_Full_PATH orgs:list --my -s $APIC_SRV --format json --fields=name | jq -r .results[].name`
        do
            # Get all draft Products
            echo "Getting products and API in draft for $ORGANIZATION organization"
            for PRODUCT in `$APIC_EXE_Full_PATH draft-products:list-all -s $APIC_SRV -o $ORGANIZATION | awk '{print $1}' `
            do
                echo "Product : $PRODUCT"
            done
            # Get all draft APIs
            for API in `$APIC_EXE_Full_PATH draft-apis:list-all -s $APIC_SRV -o $ORGANIZATION | awk '{print $1}'`
            do
                echo "API : $API"
            done
            # Get all Products and APIs deploy for all catalogs
            echo "Getting catalogs for $ORGANIZATION organization"
            for CATALOG in `$APIC_EXE_Full_PATH catalogs:list -s $APIC_SRV -o $ORGANIZATION --format json --fields=name | jq -r .results[].name`
            do
                echo "Getting list of products and API deployed in $CATALOG catalog"
                for PRODUCT in `$APIC_EXE_Full_PATH products:list-all -s $APIC_SRV -o $ORGANIZATION -c $CATALOG --scope catalog | awk '{print $1}' `
                do
                    echo "Product : $PRODUCT"
                done
                # Get all draft APIs
                for API in `$APIC_EXE_Full_PATH apis:list-all -s $APIC_SRV -o $ORGANIZATION -c $CATALOG --scope catalog | awk '{print $1}'`
                do
                    echo "API : $API"
                done
            done
        done
    ;;
    2) # Backup drafts
        echo "Performs a backup of drafts apis/products"
        echo "Getting the names of organizations"
        for ORGANIZATION in `$APIC_EXE_Full_PATH orgs:list --my -s $APIC_SRV --format json --fields=name | jq -r .results[].name`
        do
            echo "Clone draft Products and APIs for $ORGANIZATION organization"
            for PRODUCT in `$APIC_EXE_Full_PATH draft-products:clone -s $APIC_SRV -o $ORGANIZATION | awk '{print $1}' `
            do
                echo "Product : $PRODUCT cloned"
            done
            for API in `$APIC_EXE_Full_PATH draft-apis:clone -s $APIC_SRV -o $ORGANIZATION | awk '{print $1}' `
            do
                echo "API : $API cloned"
            done
        done
    ;;
    3) # Backup all catalogs
        echo "Performs a backup of all catalogs"
        echo "Getting the names of organizations"
            for ORGANIZATION in `$APIC_EXE_Full_PATH orgs:list --my -s $APIC_SRV --format json --fields=name | jq -r .results[].name`
            do
                echo "Getting catalogs for $ORGANIZATION organization"
                for CATALOG in `$APIC_EXE_Full_PATH catalogs:list -s $APIC_SRV -o $ORGANIZATION --format json --fields=name | jq -r .results[].name`
                do
                    echo "Clone Products and APIs for $ORGANIZATION organization, catalog $CATALOG"
                    if [ ! -d "$curdir/$CATALOG" ];then
                        mkdir $curdir/$CATALOG
                    fi
                    cd $curdir/$CATALOG
                    for PRODUCT in `$APIC_EXE_Full_PATH products:clone -s $APIC_SRV -o $ORGANIZATION -c $CATALOG --scope catalog | awk '{print $1}' `
                    do
                        echo "Product : $PRODUCT cloned"
                    done
                    for API in `$APIC_EXE_Full_PATH apis:clone -s $APIC_SRV -o $ORGANIZATION -c $CATALOG --scope catalog | awk '{print $1}' `
                    do
                        echo "API : $API cloned"
                    done
                    cd ..
                done
            done
    ;;
    4) # Push drafts from a directory
        echo "Push products in draft from a directory"
        for PRODUCT_YAML in `find .  -type f -name "*product*.yaml"`
        do
            echo "Push $PRODUCT_YAML in draft in $ORG_FOR_DRAFT organisation"
            $APIC_EXE_Full_PATH draft-products:create -s $APIC_SRV -o $ORGANIZATION $PRODUCT_YAML
        done
    ;;
    *) # Wrong choice
        echo "Choice not permitted"
    ;;
esac
