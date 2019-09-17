@echo off
REM Usage: TestPublish.bat org1owner1@fr.ibm.com Passw0rd! manager.159.8.70.34.xip.io provider/default-idp-2

@rem Licensed Materials - Property of IBM
@rem
@rem Copyright IBM Corp. 2017, 2017 All Rights Reserved.
@rem
@rem US Government Users Restricted Rights - Use, duplication or
@rem disclosure restricted by GSA ADP Schedule Contract with
@rem IBM Corp.
@rem Author: Arnauld Desprets - arnauld_desprets@fr.ibm.com
@rem Version: 1.0 - September 2019

@rem Important: supports only one organisation (we will put everything as if it was one organisation)
@rem Tested on Windows 10

set APIC_EXE_Full_PATH=C:\IBM\APIM\2018\toolkit\apic.exe
set APIC_LOGIN=%1
set APIC_PASSWORD=%2
set APIC_SRV=%3
set APIC_REALM=%4

set SCRIPT_DEBUG=0

echo %DATE% - %TIME%
if [%1] == [] goto checkargs

:select_actions
choice /C abc /M "A) List products, B) Backup draft, C) Backup all catalogs"
if errorlevel 3 goto apic_backup_catalogs
if errorlevel 2 goto apic_backup_drafts
if errorlevel 1 goto apic_list

:apic_list
echo List of products and APIs in all catalogs
echo Login to %APIC_SRV%
cmd /c %APIC_EXE_Full_PATH% login -s %APIC_SRV% -u %APIC_LOGIN% -p %APIC_PASSWORD% -r %APIC_REALM%

echo Getting the names of organizations
for /F %%i in ('%APIC_EXE_Full_PATH% orgs:list --my -s %APIC_SRV%') do (
    echo Getting catalogs for %%i organization
	for /F %%j in ('%APIC_EXE_Full_PATH% catalogs:list -o %%i -s %APIC_SRV%') do (
		if "%SCRIPT_DEBUG%"=="1" echo catalog %%j
		for /f "tokens=6 delims=/" %%a in ("%%j") do (
			echo Getting list of products from %%a catalog
			for /F %%k in ('%APIC_EXE_Full_PATH% products:list-all -c %%a -o %%i -s %APIC_SRV%') do (
				echo Product: %%k
			)
			for /F %%k in ('%APIC_EXE_Full_PATH% apis:list-all -c %%a -o %%i -s %APIC_SRV%') do (
				echo API: %%k
			)
		)
	)
)
goto end

:apic_backup_drafts
echo Performs a backup of drafts apis/products
echo Login to %APIC_SRV%
cmd /c %APIC_EXE_Full_PATH% login -s %APIC_SRV% -u %APIC_LOGIN% -p %APIC_PASSWORD% -r %APIC_REALM%
echo Getting the names of organizations
for /F %%i in ('%APIC_EXE_Full_PATH% orgs:list --my -s %APIC_SRV%') do (
    echo Extracts draft products and APIs for %%i organization
  for /F "delims=" %%j in ('%APIC_EXE_Full_PATH% draft-products:clone -o %%i -s %APIC_SRV%') do (
		echo %%j
	)
)
goto end

:apic_backup_catalogs
echo Performs a backup of all catalogs
echo Login to %APIC_SRV%
cmd /c %APIC_EXE_Full_PATH% login -s %APIC_SRV% -u %APIC_LOGIN% -p %APIC_PASSWORD% -r %APIC_REALM%

echo Getting the names of organizations
for /F %%i in ('%APIC_EXE_Full_PATH% orgs:list --my -s %APIC_SRV%') do (
    echo Getting catalogs for %%i organization
	for /F %%j in ('%APIC_EXE_Full_PATH% catalogs:list -o %%i -s %APIC_SRV%') do (
		@rem if "%SCRIPT_DEBUG%"=="1" echo catalog %%j
		for /f "tokens=6 delims=/" %%a in ("%%j") do (
			if not exist "%%a" mkdir %%a
			pushd %%a
			echo Extracting products from %%a catalog
			cmd /c %APIC_EXE_Full_PATH% products:clone -c %%a -o %%i -s %APIC_SRV%
			popd
		)
	)
)
goto end

:checkargs
REM Set default arguments
echo Info: set the arguments to the default values because no parameters have been given
set APIC_LOGIN=org2owner1
set APIC_PASSWORD=Mar1ea11
set APIC_SRV=manager.159.8.70.34.xip.io
set APIC_REALM=provider/default-idp-2
goto select_actions

:end