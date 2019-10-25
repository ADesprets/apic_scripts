@echo off
REM Usage: TestPublish.bat org1owner1@fr.ibm.com Passw0rd!

@rem Licensed Materials - Property of IBM
@rem
@rem Copyright IBM Corp. 2017, 2019 All Rights Reserved.
@rem
@rem US Government Users Restricted Rights - Use, duplication or
@rem disclosure restricted by GSA ADP Schedule Contract with
@rem IBM Corp.
@rem Author: Arnauld Desprets - arnauld_desprets@fr.ibm.com
@rem Version: 1.0 - June 2017
@rem Version: 2.0 - June 2019
@rem Add draft products and API in the list operation

@rem Important: supports only one organisation (well put everything as if it was one organisation)
@rem Test on Windows 7


set APIC_LOGIN=%1
set APIC_PASSWORD=%2
set APIC_SRV=%3

set SCRIPT_DEBUG=0

echo %DATE% - %TIME%
if [%1] == [] goto checkargs

:select_actions
choice /C abc /M "A) List products, B) Backup draft, C) Backup all catalogs"
if errorlevel 3 goto apic_backup_catalogs
if errorlevel 2 goto apic_backup_drafts
if errorlevel 1 goto apic_list

:apic_list
echo List of products and APIs in all catalogs and in draft
echo Login to %APIC_SRV%
cmd /c apic login -s %APIC_SRV% -u %APIC_LOGIN% -p %APIC_PASSWORD%

echo Getting the names of organizations
for /F %%i in ('apic organizations -s %APIC_SRV%') do (
    echo Getting products and API in draft for %%i organization
    for /F %%k in ('apic drafts -o %%i -s %APIC_SRV% --type product') do (
      echo Product: %%k
    )
    for /F %%k in ('apic drafts -o %%i -s %APIC_SRV% --type api') do (
      echo API: %%k
    )
    echo Getting catalogs for %%i organization
	for /F %%j in ('apic catalogs -o %%i -s %APIC_SRV%') do (
		if "%SCRIPT_DEBUG%"=="1" echo catalog %%j
		for /f "tokens=6 delims=/" %%a in ("%%j") do (
			echo Getting list of products from %%a catalog
			for /F %%k in ('apic products -c %%a -o %%i -s %APIC_SRV%') do (
				echo Product: %%k
			)
			for /F %%k in ('apic apis -c %%a -o %%i -s %APIC_SRV%') do (
				echo API: %%k
			)
		)
	)
)
goto end

:apic_backup_drafts
echo Performs a backup of drafts apis/products
echo Getting the names of organizations
for /F %%i in ('apic organizations -s %APIC_SRV%') do (
    echo Extracts draft products and APIs for %%i organization
	for /F "delims=" %%j in ('apic drafts:clone -o %%i -s %APIC_SRV%') do (
		echo %%j
	)
)
goto end

:apic_backup_catalogs
echo Performs a backup of all catalogs

echo Login to %APIC_SRV%
cmd /c apic login -s %APIC_SRV% -u %APIC_LOGIN% -p %APIC_PASSWORD%

echo Getting the names of organizations
for /F %%i in ('apic organizations -s %APIC_SRV%') do (
    echo Getting catalogs for %%i organization
	for /F %%j in ('apic catalogs -o %%i -s %APIC_SRV%') do (
		@rem if "%SCRIPT_DEBUG%"=="1" echo catalog %%j
		for /f "tokens=6 delims=/" %%a in ("%%j") do (
			if not exist "%%a" mkdir %%a
			pushd %%a
			echo Extracting products from %%a catalog
			cmd /c apic products:clone -c %%a -o %%i -s %APIC_SRV%
			popd
		)
	)
)
goto end

:checkargs
REM Set default arguments
echo Info: set the arguments to the default values because no parameters have been given
set APIC_LOGIN=org1owner1@fr.ibm.com
set APIC_PASSWORD=Passw0rd!
set APIC_SRV=management.fr.ibm
goto select_actions

:end
