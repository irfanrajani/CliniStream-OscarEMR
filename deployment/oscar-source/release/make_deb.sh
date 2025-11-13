#!/bin/bash

# release/make_beta.sh
# makes a debian installer release from source

#===================================================================
# Copyright Peter Hutten-Czapski 2012-2022 released under the GPL v2
#===================================================================


# for OSCAR 14 **transitional**
# v 1 - pre-release
# v 2 - added in oscar_documents incoming docs directories needed
#     - added in code to set the billingcenter 
# removed Replaces: oscar-mcmaster from control
# replaced oscar-mcmaster with oscar-emr in templates etc
# v 3 - added x86_64 detection for wkhtmltopdf
# v 4 - updates for may 2014 alpha
# v 5 - directed to trunk for testing
# v 6 - huge number of bug fixes
# v 7 - added in a few schema changes
# v 8 - changed db switch to useOldAliasMetadataBehavior=true & jdbcCompliantTruncation=false
# v 9 - switched from trunk to true oct2014AlphaMaster
# v 10 - removed the external perscriber settings
# v 11 - updated drugref data to Nov 22, 2014
# v 12 - fixed config to echo url for hcv service, and adjusted min stack to 256k
# v 13 - changed wget to ./wget older version and substituted in TEST PATIENT into the demo and undemo.sql
# v 14 - ported lintian fixes from v63 of the 12_1 release installation script and added wkhtmltopdf dependency
# v 15 - switched to tomcat7, updated drugref to Feb 10 2015, cleaned changelog and disabled updating
# v 16 - added Rourke eForm installation under liscence
# last deb oscar_emr14-10alpha15.deb

# for OSCAR 15
# v 0 - fixed the Rourke unzip and copy and sent its console output to the install log
# v 1 - fixed patch.sql to reference oscar_15 fixed oscar.properties to match latest and draw from OSCAR 15 branch 
# v 2 - added DEMOGRAPHIC_PATIENT_CLINIC_STATUS=true (REALLY who wants it turned off as default?)
# v 3 - fixed oscar_12_1_1_to_oscar_15.sql, or at least removed the duplicates!
# v 4 - updated schema definitions to update-2015-04-24.sql applied
# v 5 - Now drawing on the OSCAR's RELEASE_15_BETA and update-2015-04-29.sql applied and Jenkins port changed temporarily
# v 6 - Jenkins port reverted to 11042, drugref schema tweaked/updated to May 2015, added ALT_PATIENT_DETAILS_UI property
# v 7 - updated drugref2 to last stable build on Jenkins which now can handle HC zip change May 5 2015
# v 8 - fixed nsert typo in the sql's
# v 9 - fixed oscar_14 to oscar_15 references in the conversion script
#     - modified SQL to reflect update-2015-05-15.sql 
#     - added more debug to purge script
#     - Set SINGLE_PAGE_CHART=true to Show link to single page chart in classic appointment screen
# v 10 - added sort_down_mfg_tagged_generics generic drug flag to drugref properties and, June 24 new API for drugs by DIN in drugref
# v 11 - added cipher settings for server.xml
# v 12 - altered drugref properties file to drugref2.properties and made them use the packaged sql as update with added indices
#      - database updates appended in OscarON15 OscarBC15 and oscar_12_1_1_to_oscar_15 sqls to update-2015-07-08.sql
# v 13 - added unzip as dependency
# v 14 - updated drugref war and drugref and oscar schemas to Oct 7, 2015
# v 15 - substituted new backup.sh, reviewed prerm, config, now will upgrade previous 15 debs without rewriting properties
# v 16 - updated demo and undemo sql's
# v 17 - updated sql's to update-2015-12-08 and update-2015-11-24
# v 18 - updated sql's to update-2016-01-25 and tweaked the quicklist for appts for GP (recalled)
# v 19 - bugfixes to the 12.1 to 15 conversion script and corrected WKHTMLTOPDF command property and removed its dependency as deb
# v 20 - more sql tweaking and addition of legacyMyISAM.sql for upgrade purposes
# v 21 - Fixed demo.sql to properly enroll both demo patients
# v 22 - Changed output to rename as ~, fixed HL7 labs to view, vacancy table fix
# v 23 - Switched this script to standard curl from our hacked wget for accessing files from the web
# v 24 - Updated reOscar to reOscar2.sh, added ichppccode table, missig HRMDocuments column and many indices to patch.sql
# v 25 - More indices added to patch.sql and web.xml added to OscarDocuments and moved OscarDocuments to prevent webshell exploit
# v 26 - Updated Rich Text Letter and moved OscarDocuments to prevent webshell exploit
# v 27 - Bypassed confirmation screen for upgrades so that they can run unattended
# v 28 - Fixes in patch.sql
# v 29 - Changed OscarDocuments to the <context> and added BORN eforms to Ontario Installs, new source for GEOIP data
# v 30 - Updated backup2.sh to use new document directory
#      - oscar.properties to use master Mar 17, 2016 
#      - added sed entries to config to normalise paths in the properties file
#      - removed a lot of redundant echo to properties file in config
#      - area code lookup to handle space in city name
#      - tickler_update forcing to status to ABD in conversion script
#      - Rourke 2014 updated to latest as of April 15, 2016
# v 31 - added reOscar to config and changed way to test/set backup scripts
#      - Rourke 2014 updated to latest as of April 17, 2016
# v 32 - Switched config to set BASE_DOCUMENT_DIR
#      - added weekly tomcat restart cronjob to config
# v 33 - added gateway.cron to oscar-emr and in config
# v 34 - updated drugref to current on 2016-04-22
#      - added default data to faxconfig so it would work out of the box
#      - fixed /etc/default/tomcat7 to use Oracle java
# v 35 - sanity check to ensure setting tomcat to look for an actual Oracle Java
# v 36 - updated OscarDocuments editControl.js to provide backwards compatibility for old RTL  May 16, 2016
#      - added Ontario Lab eform
# v 37 - fixed OscarBC15.sql to at least load!
# v 38 - added mariadb-server as alternate dependency to mysql in control
# v 39 - fixed bug 4385 lastdate spelling line 221 postinst
# v 40 - deleting tailing zero doses and adding leading 0 to decimal doses
#      - added tallMAN scripts for optional use
#      - updated drugref to current on 2016-07-26
# v 41 - adjusted permissions on scripts and oscar.properties
# v 42 - DEB update now updates drugref and the older Rourke installed prior to v 30
# v 43 - fixed missing consent tables for build 437 oscar_emr15-42~437.deb and oscar_mcmaster.properties to match
# v 44 - temporary patch to tickler to get rid of NULL's in catgeory_id REVERTED
# v 45 - added run_rxquery.sh for Medispan reporting without configuring or adding to crontab
# v 46 - switched from repo drugref.sql to one in local directory
# v 47 - outdated property indivica_rx_enhance removed
#      - rx_enhance set to false
#      - fixed patch.sql for ichpicc
# v 48 - moved up table definition `indicatorTemplate` in patch to fix fresh install bug
#      - probing eth1 instead of eth0 for local ip
# v 49 - disabled plugin requirement for root user
#      - removed a tailing / in the properties file for tomcat
#      - updated drugref data to Jan 18, 2017
#      - updated area code lookup to use https
# v 50 - Fixed backupscript to daily delete stale Full backups if $COMPLETE_BACKUP
#      - and to trigger Full backups every $DAYS_TO_KEEP if not
# v 51 - updated patch with missing update-2015-12-07.sql and 2017-01-25.sql
# v 52 - updated patch with UNIQUE constrained temp indices 
#      - added latebreaking properties, at least for consult module
#      - drugref2 to build 12
# v 53 - added missing properties
# v 54 - updated drugref to Feb 17, 2017 and removed addition of index in postinst
# v 55 - fixed order in patch.sql to add LookupList.listTitle prior to filling it
# v 56 - fixed spelling mistake in patch.sql for hort_term
# v 57 - migrated to jenkins/bitbucket pointing to the stable release branch
# v 58 - added tomcat8 support
# v 59 - updated drugref to June 1, 2017
# v 60 - server.xml fixes and hardening
# v 61 - fixed bug in writing server.xml and added purge configuration lines
# v 62 - added context.xml tweak and added purge configuration lines
# v 63 - changed server.xml to add back in connector at 8080 redirect 8443 for drugref
# v 64 - added OPR-2017 and fixed purge to 
#      - fixed test to remove symlink to -L from -f
#      - split patch into patch1.sql
# v 65 - rebuild the build directory and simplified
# v 66 - Updated OPR to v1.5, simplified logging, fixed purge bug to clear usr/share/oscar-emr
# v 67 - Now runs tallMANdrugref.sql on drugref 
#      - Updated drugref to Aug 31, 2017
#      - and added 50 additional labs for demo
# v 68 - tallMANdrugref.sql now removes generic entries for search 
#      - Updated drugref to Sep 13, 2017
# v 69 - Updated OPR-2017 to v1.55 Sept 25 
#      - Added option to warn admin by email if backup getting full 
# v 70 - Got rid of some unscaped characters
# v 71 - Fixed OPR-2017 update when not needed
# v 72 - Prevent reset of pre-seeded answers until end 
# v 73 - Updated drugref2 to Jenkins build #6
# v 74 - Rourke 2017
# v 75 - Nothing really different than 74
# v 76 - Acccounts for updates that need both patches pre 64 ie oscar_emr15-63~667.deb
#      - Move db_clear to inside remove case in prerm
#      - reverted clearing sensitive data
# v 77 - Updated and resumed polling Jenkins for the latest drugref build (#8)
#      - updated drugref.sql to Dec 12, 2017
# v 78 - Updated oscar.properties and update-2017-12-13 for audit log feature
# v 79 - Fixed bug in line 231 of patch.sql
# v 80 - Extracted xsd files from war to OscarDocuments
# v 81 - Typo in undemo and error in March 7th config file
# v 82 - Added National Rourke
# v 83 - Removed deprecated ifconfig in config and changed mv to cp for tomcat8 wars
# v 84 - Fixed empty property file key value settings that would not be caught and would be added with each update
# v 85 - Fixed consultation_display_practitioner_no to add once
# v 86 - Added in the ability to force at the command line to download the current war even if not stable
# v 87 - labelling corrections
# v 88 - tomcat 8 setup bugs, fix postrm to remove /usr/share/oscar-emr/
# v 89 - lets encrypt
# v 90 - lets encrypt renewal script
# v 91 - altered server.xml settings and Java memory settings for tomcat min 960 max to 6000
# v 92 - altered patch to add some Ontario tables to BC for ease of upkeep
# v 93 - Added stopping Tomcat and deleting the old oscar directory to ensure full expansion of the new war
# v 94 - refactored Java detection and selection in postinst
#      - Drugref build 16 DPD Capitalisation and SQL fixes Jan 22-23, 2019
# v 95 - corrected deprecated setting for tomcat8 server.xml
# v 96 - re-enabled port 8080 for drugref2
# v 97 - disabled the new interface as default
#      - fixed file test operators in postrm
# v 98 - initial tomcat9 support (never released)
# final OSCAR 15 production deb oscar_emr15-97final858.deb Feb 22 2019

# for OSCAR 18 **transitional** March 11 2019
# v 0  - inital DEB in the OSCAR 18 series oscar_emr18beta-1~859.deb
# v 1  - changed database to oscar_15
# v 2  - changed program version to oscar_18
# v 3  - changed program version to oscar_18 alpha
# v 4  - fixed bug in patch.sql and duplicate rm in purge
# v 5  - fixed bug for new installs with inadequate property settings
# v 6  - updated drugref and sql to April 18, 2019
# v 7  - redid java detection and handling for 11
# last alpha oscar_emr18alpha-7~928.deb April 27, 2019

# for OSCAR 19 May 1, 2019 inital DEB in the OSCAR 19 series oscar_emr19beta-0~929.deb
# v 0  - java alternatives fix for Java 11
# v 1  - added debconf db_purge for postrm purge script
# v 2  - added June 1 FIT and Ontario Lab forms for testing
# v 3  - added wkhtmltopdf detection for configuration and installed the OSCAR 19 verision of RTL
# v 4  - added logic to prevent drugref update if its not necessary
# v 5  - updated backup script to detect tomcat version 
#      - updated drugref.sql to May 22, 2019
# REVERTED v 6  - updated drugref and sql to May 22, 2019
# v 6  - redid build files to behave a bit more sanely when the install is broken and updated copyright
# v 7  - Minor changes in the backup script.  A July drugref, and forcing NEW CONTACT UI in patch1.sql
# v 8  - Fixed typo in patch.sql
# v 9  - Fixed ISO 3166-2:CA in patch1.sql for setting the province to CA-QC and not QU
# v 9  - updated Drugref 
# v 11 - some internal changes to symlinks on tomcat8 systems
# v 12 - disabled tomcat shutdown during backup script
# v 13 - updated LU codes to 2019-09-25 and placed them into eforms images 
#      - increased shutdown wait in reOscar.sh to 240
# v 14 - v19.03 reOscar.sh better Tomcat detection, limit concurancy, and added Tomcat monitoring/starting
#      - updated drugref.sql to 2019-10-16
# v 15 - v19.04 reOscar.sh fixed automated restarts
# v 16 - v19.05 reOscar.sh prevent more than one instance running
# v 17 - fixed up a ln and tomcat ownership issues for oscar.properties in config
# v 18 - first go for BC schema support
# v 19 - Restrict to TLS 1.2 for Tomcat8
# v 20 - Restrict to TLS 1.2 for Tomcat7 per Kevin Lai and a tighened suite of ciphers
# v 21 - Remove the ability for the user to reboot from the GUI and the automated friday restart
# v 22 - add in the ability to load a custom war
# v 23 - bouncycastle at 1.67 RTL at 2.0 Rourke at 2020
# v 24 - eform Generator at 6.6 and COVIC-19 preventions, reverted Bouncycastle to 1.51
# v 25 - fixed java home in postinst for new installs
# v 26 - fixed AppointmentDxLink for ageRange
# v 27 - update-2020-07-07.sql
# v 28 - fixed restore.sh altered cd ${DOCS}/${PROGRAM} to cd ${DOCS}
# v 29 - added customSearchUrl and customSearchName properties and fixing typeo for ocean in config
# v 30 - added --enable-local-file-access to wkhtmltopdf commands for versions above 2.6.1
# v 31 - updated demo.sql to v6.3 to deal with Msg 
# v 32 - updated specific war number to upload from bitbucket, CVC initial support
# v 33 - updated to upload drugref from bitbucket 
# v 34 - upload drugref from bitbucket, and modification for tomcat 9 experimental install
# v 35 - reverted drugref after issues
# v 36 - config bugs for oscar.properties
# v 40 - resume sourcing drugref from bitbucket, initial 19.5
# v 41 - initial Tomcat 9 tested release
# v 42 - fixes for certbot pem copy bug
# v 43 - switch chgrp to chown which is more appropriate and purge of purge bugs
# v 44 - OscarBC19.sql changes for MariaDB 10.3 to match earlier ones for ON
# v 45 - made link for properties files into WEB-INF/classes
# v 46 - initial support for Java 11
# v 47 - initial support for migrating existing data to MariaDD 10.3
# v 48 - added missing patch statement
# v 49 - added override.conf for tomcat9 to allow read/write to /usr/share/oscar-emr/
# v 50 - changed skip_postal_code_validation default to true
# v 51 - disabled code to activate password access to MariaDb as if varies by version
# v 52 - remove directory check
# v 53 - minor tomcat 9 config changes
# v 54 - set fax_file_location=/usr/share/oscar-emr/OscarDocument/fax/ in config
# v 55 - bug fix overrides tomcat 9 sandbox
# v 56 - added indicatorTemplatePANEL.sql and 2FA.sh scripts and deactivated K2A
# v 57 - reverted deactivating K2A to only do so on new installs
# v 58 - changed varchar to TEXT in formONAR2017 in patch19/patch.sql 
# v 59 - added in DoBC sourced dashboards
# v 60 - DoBC sourced dashboards fixes
# v 61 - More DoBC sourced dashboards fixes and additional indicators
# v 62 - More patching patch.sql including RTL fix for attaching files
# v 63 - Renamed patch1.sql to oscar_15_to_oscar_19.sql fixed config of oscar.properties and crontab for letsencrypt
# v 64 - Changes for Ubuntu 22.04 March 29, 2022 and more dashboard fixes
# v 65 - db_driver = com.mysql.cj.jdbc.Driver as needed for the mysql Driver version 8.0
#      - quarterly update of Drugref April 7, 2022
#      - update to OHIP schedule to April 1, 2022 (for new installs only, but could be extracted)
#      - update CVC to final version April 7, 2022
# v 66 - added ReadWritePaths=/tmp/ to all overrides for Tomcat 9 and changed the WKHTMLTOPDF_ARGS
# v 67 - switch to NIO2 connector for Tomcat9 and make a simpler default file
# v 68 - added Adding relaxedQueryChars to ${C_BASE}conf/server.xml for OCEAN support
# v 69 - using Drugref 2.26 last build that supports type 10 allergy checking per AHFS category
# v 70 - resume using latest Drugref 2.36 that resumes support for type 10 allergy checking per AHFS category
# v 71 - restore ability to set BC billing region
# v 72 - fixed chown for pems for new Certbot installs
# v 73 - fixed sed flags in postinst for new installs
# v 74 - drugref.sql of Nov 9, 2022
# v 75 - referencing on line patch19.sql
# v 76 - apparmor patch for wkhtmltopdf 
# v 78 - server.xml relaxedQueryChars="[,]"
#      - added formBCAR2007 to the MyISAM conversions in patch.sql
# v 79 - updated properties file
# v 80 - updated config to supply all the directories explicitly set
# v 81 - drugref.sql updated to Feb 22, 2023
# v 82 - updated to drugref2.43.war 
# v 83 - experimental and incomplete Tomcat 10 support
# v 84 - drugref.sql updated to Nov 12, 2023
#      - Ontario Lab 2019 assorted support files added
#      - reverted patch.sql back to local
# v 85 - updated to drugref2.46.war (also in 19-84~3743)
#      - drugref.sql updated to Jan 15, 2024
# v 86 - added cron to pre-depends
# v 87 - bug fix
# v 88 - fixes for Ubuntu 24.04 for Tomcat9 ReadWritePaths
# v 89 - fixes for Ubuntu 24.04 for wkhtmltopdf apparmor
# v 90 - moved war expansion to the end
# v 91 - LU codes costing and drugs updated to March 2024
# v 92 - matching column widths for some archice tables patch19.sql
# v 93 - updated measurements table patch19.sql
# v 94 - fixed some paths in oscar.properties
# v 95 - added updateDrugref.cron utility script
# v 96 - fixed config reference to gateway.sh
# v 97 - ExcellerisDownload.sh

# --- sanity check
if [ "$(id -u)" != "0" ];
then
	echo "This script must be run as root" 1>&2
	exit 1
fi

echo "#########" `date` "#########" 

DEB_SUBVERSION=97
PROGRAM=oscar
PACKAGE=oscar-emr

# The database should be in the oscar_ series, MySQL conventions don't allow . in db_names
db_name=oscar_15

## database switches are needed to provide expected behavior for OSCAR 15
## enforce UTF-8 encoding so that foreign characters are stored 一種語言永遠不夠 
## handle 0000-00-00 date errors by rounding to 0001-01-01
## allow hibernate to alter column names
## tolerate fields without default values that are not named in the query
db_switch=\'?characterEncoding=UTF-8\\\&zeroDateTimeBehavior=round\\\&useOldAliasMetadataBehavior=true\\\&jdbcCompliantTruncation=false\'

# Debian versioning conventions don't allow _ so use .
VERSION=19
PREVIOUS=15

# ... and of course Jenkins is using another convention
WGET_VERSION=oscar-stable

# and the target of mvn 3 has to be different than for mvn 2 so
# for TRUNK and 15 BETA oscar-14.0.0-SNAPSHOT.war
TARGET=oscar-14.0.0-SNAPSHOT.war

echo "grep the build from Bitbucket" 


## check command line for a switch eg sudo ./make_deb c
## f for force the last build regardless of stability
## number for specific build eg 999
## c for custom build using a local war
## default is no switch for last stable build
if [ -z "$1" ];
    then
        echo "No argument supplied.. proceed with last stable build"
        curl -L -o latestStable https://bitbucket.org/oscaremr/oscar/downloads/latestBuild
        curl -L -o latestDrugref https://bitbucket.org/oscaremr/drugref2/downloads/latestBuild
    else
        if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
          echo "numeric argument supplied.. proceed with build ${1}"
            ## https://bitbucket.org/oscaremr/oscar/downloads/oscar-19.2017.war
            custom=${1}
        else
          if [ "$1" == "f" ]; then
            echo "force.. proceed with last build regardless of stability"
            curl -o build http://jenkins.oscar-emr.com:8080/job/$WGET_VERSION/lastBuild/
            else
                echo "custom.. proceed with custom build local to this directory"
                SKIP_NEW_WAR=true
                custom=true
            fi
        fi
fi
## get the patch19.sql from source
## curl this way to overwrite the existing patch19.sql
## NOTE THIS URL will need to be updated at you edit changes in the patch19.sql file on line
##curl https://bitbucket.org/oscaremr/oscar/raw/6b784a12de3039c42cc74828dca8629805e7600d/release/patch19.sql > patch19.sql
##curl https://bitbucket.org/oscaremr/oscar/raw/cfe49416cd3a2625b497fa1a73bdcd8bbc23a23b/release/patch19.sql > patch19.sql

##curl -o lastStableBuild http://jenkins.oscar-emr.com:8080/job/$WGET_VERSION/lastBuild/

    D_BUILD=$(grep 'BUILD_NUMBER'  latestDrugref  | tail -n 1 | cut -d "=" -f2 ) 
    D_buildDateTime=$(grep 'BUILD_DATE'  latestDrugref  | tail -n 1 | cut -d "=" -f2 )   
    D_WAR_URL=$(grep 'WAR_URL'  latestDrugref  | tail -n 1 | cut -d "=" -f2 ) 
    D_COMMIT=$(grep 'COMMIT_MESSAGE'  latestDrugref  | tail -n 1 | cut -d "=" -f2 ) 
    
##TEMPORARILY USE fixed build of drugref2.26
    #D_BUILD=26 
    #D_buildDateTime=2022-01-28  
    #D_WAR_URL=https://bitbucket.org/oscaremr/drugref2/downloads/drugref2.26.war 
    #D_COMMIT="last build that supports type 10 allergy checking per AHFS category" 

if [ ! $custom ]; then
    echo getting build information from Bitbucket
    ## <title>may2014alphaMaster #13 [Jenkins]</title>
    # oct2014AlphaMaster #1 [Jenkins]

    BUILD=$(grep 'BUILD_NUMBER'  latestStable  | tail -n 1 | cut -d "=" -f2 ) 
    buildDateTime=$(grep 'BUILD_DATE'  latestStable  | tail -n 1 | cut -d "=" -f2 )   
    WAR_URL=$(grep 'WAR_URL'  latestStable  | tail -n 1 | cut -d "=" -f2 ) 
    OSCAR_COMMIT=$(grep 'COMMIT_MESSAGE'  latestStable  | tail -n 1 | cut -d "=" -f2 ) 
    SHA1=""


    #BUILD=$(grep '<title>' build | head -n 1 | sed "s/<title>$WGET_VERSION #\([0-9]*\).*/\1/;s/^[[:space:]]*//;s/[[:space:]]*$//")
    ##buildDateTime=$(grep '       (' build | head -n 1 |sed 's/^[[:space:]]*(//;s/)[[:space:]]*$//')
    ##SHA1=$(grep 'Revision' build | head -n 1 |sed 's/.*Revision.* \(.*\)/\1/')
   else
      echo build is custom
      BUILD=$custom
      buildDateTime=date 
      SHA1=""
fi
echo "+++++++++++++++++++++++"
echo build=$BUILD

echo WAR_URL=$WAR_URL
echo buildDateTime=$buildDateTime
echo "current date="$(date)

# you can tick up when a newer build of the installer is made 
# or when the release tag needs to change eg beta to RC
# TRUNK
REVISION=${DEB_SUBVERSION}~${BUILD}
echo REVISION=$REVISION
ICD=9

# For simplicity lets pick Tomcat 7
TOMCAT=tomcat7
#C_HOME=/usr/share/${TOMCAT}/
C_BASE=/var/lib/${TOMCAT}/
# FILEREPO=~/Documents/release/
#tomcat_path=${C_HOME}
TODAY=$(date)

# used to pick up virgin properties file and if building a deb directly from source
SRC=~/git/oscar


# TODO Check the dir from which you are being called


DEBNAME="oscar_emr${VERSION}-${REVISION}"


if [ -d "$DEBNAME" ]; then
	echo prexisting directory with this build found
	SKIP_NEW_WAR=true
	rm -R ./${DEBNAME}/
else
    if [ $custom ]; then
        echo custom build
    else
        echo cleaning up prior build
	    rm ${TARGET}
        ##rm drugref2-1.0-SNAPSHOT.war
    fi
fi

echo "cleaning up"




rm tmp*
rm -R -f ./oscar_documents

# echo "loading documents"
mkdir -p ./${DEBNAME}/usr/share/doc/${PACKAGE}/
cp -R copyright ./${DEBNAME}/usr/share/doc/${PACKAGE}/

# echo "loading control scripts"
mkdir -p ./${DEBNAME}/DEBIAN/


if [ "${SKIP_NEW_WAR}" = "true" ] ; then
	    echo skipping redownloading of wars
    else

        curl -L -o drugref2-1.0-SNAPSHOT.war ${D_WAR_URL}
        echo "drugref war build ${D_BUILD} of ${D_buildDateTime} up"

    if [ -z "$1" ]
        then
            echo "No argument supplied.. proceed with last stable build at ${WAR_URL} and saving to ${TARGET}"
            curl -L -o $TARGET ${WAR_URL}
        else
            if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
              echo "numeric argument supplied.. proceed with build ${1} from bitbucket using -L to follow redirects"
                curl -L -o $TARGET https://bitbucket.org/oscaremr/oscar/downloads/oscar-19.${1}.war
            else
            curl -L -o $TARGET ${WAR_URL}
            fi
    fi
fi

SHA1=$(sha1sum ${TARGET})
echo The ${TARGET} SHA1=$SHA1


echo "changelog"


if [ -z "$1" ]
    then
        echo "No argument supplied.. proceed with last stable build"
    else
        if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
          echo "numeric argument supplied.. proceed with build ${1}"
            ##curl -o changes http://jenkins.oscar-emr.com:8080/job/oscar-stable/${1}/changes
        else
          echo "non numeric argument supplied.. proceed with last build regardless of stability"
            ##curl -o changes http://jenkins.oscar-emr.com:8080/job/oscar-stable/changes
        fi
fi
#curl -o changes http://jenkins.oscar-emr.com:8080/job/oscar-stable/changes

sed \
-e 's/yyy-1.0/'"$VERSION"'-'"$BUILD"'/' \
-e 's/package/'"$PROGRAM"'/' \
-e 's/releasedate/'"$TODAY"'/' \
changestemplate > tmp

head -n 1 tmp > tmp2
#grep "^                [a-zA-Z#]" changes | tail -n +3 |sed 's/&039\;/'/;s/^[[:space:]]*/  *   /;s/[[:space:]]*$//' > tmp3
#grep "^                [ a-zA-Z#]" changes | tail -n +13 |sed 's/&#039\;//;s/&nbsp\;/ /;s/&quot\;/\"/;s/&quot\;/\"/;s/&quot\;/\"/;s/&quot\;/\"/;s/id:\;//;s/ID://;s/ID \#//;s/Bug \#//;s/Bug ID //;s/Oscar Host - //;s/\#//;s/^[[:space:]]*/  * /;s/[[:space:]]*$//' >tmp3
# lots of cleanup to extract the pith from the changes and then truncate at 80 columns as per DEBIAN requirement

#grep "<\/h2>"  changes | sed 's/^[[:space:]]*/  * /;s/, [0-9]* [0-9]*:[0-9][0-9]:[0-9][0-9] [A|P]M//;s/<\/a><\/h2><ol><li>//;s/OSCAREMR-//;s/[[:space:]]*$//' > tmp3
#grep 'COMMIT_MESSAGE'  latestStable  | tail -n 1 | cut -d "=" -f2 > tmp3
echo  ${OSCAR_COMMIT} > tmp3
echo  ${D_COMMIT} >> tmp3

sed -r 's/(^.{80}).*/\1/' tmp3 > tmp4
tail -n 1 tmp > tmp5


cat tmp2 \
tmp4 \
tmp5 \
> changelog.Debian

cat latestStable >> cumulative
cat latestDrugref >> cumulative

#curl -o summary http://jenkins.oscar-emr.com:8080/job/oscar-stable/$BUILD/changes
## Commit f8a5567c8a733b6990f70a8c857079b5b1d0c75d
#SHA1=$(sed -n '12p' summary)

echo "+++++++++++++++++++++++"
echo build=$BUILD
#buildDateTime=$(grep '       (' build | head -n 1 |sed 's/^[[:space:]]*(//;s/)[[:space:]]*$//')
echo buildDateTime=$buildDateTime
#SHA1=$(grep 'Revision' build | head -n 1 |sed 's/.*Revision.* \(.*\)/\1/')
echo SHA1=$SHA1
echo DEBNAME=${DEBNAME}
echo ""
echo "OSCAR changes"
head -n 5 changelog.Debian
echo ""
#echo "Drugref2 Changes"
#cat drugrefChangesClean
echo "+++++++++++++++++++++++"

#rm build
#rm drugrefChangesClean

gzip -9 changelog.Debian
mv changelog.Debian.gz ./${DEBNAME}/usr/share/doc/${PACKAGE}/
#  6      4     4
# user   group  world
# r+w    r      r
# 4+2+0  4+0+0  4+0+0  = 644
#chmod 644 ./${DEBNAME}/DEBIAN/changelog

echo "Configuring config"
sed -e 's/^PROGRAM.*/PROGRAM='"$PROGRAM"'/' \
-e 's/^PACKAGE.*/PACKAGE='"$PACKAGE"'/' \
-e 's/^db_name.*/db_name='"$db_name"'/' \
-e 's/^db_switch.*/db_switch='"$db_switch"'/' \
-e 's/^VERSION.*/VERSION='"$VERSION"'/' \
-e 's/^PREVIOUS.*/PREVIOUS='"$PREVIOUS"'/' \
-e 's/^REVISION.*/REVISION='"$REVISION"'/' \
-e 's/^buildDateTime.*/buildDateTime=\"'"$buildDateTime"'\"/' \
config > ./${DEBNAME}/DEBIAN/config

# 7       5     5
# user   group  world
# r+w+x  r+x    r+x
# 4+2+1  4+0+1  4+0+1  = 755
chmod 755 ./${DEBNAME}/DEBIAN/config

echo "Configuring control"
sed -e 's/Version: 8-x.x/Version: '"$VERSION"'-'"$REVISION"'/' \
control > ./${DEBNAME}/DEBIAN/control

chmod 644 ./${DEBNAME}/DEBIAN/control

echo "Configuring postinst"
# note that this requires a drugref.sql with DROP TABLE syntax
# mysqldump -uroot -p --add-drop-table drugref > drugref.sql

# determine the date of the drugref.sql that we have to load 
# lets take the last history revision on the line by cutting backwards
# NOTE requires a one line insert like
# INSERT INTO `history` (`id`, `date_time`, `action`) VALUES (1, '2022-09-20 19:04:45', 'update db');

newdate=$(grep "INSERT INTO \`history\`" drugref.sql | rev | cut -f 4 -d "'" | rev | cut -f 1 -d " ")

echo "SANITY CHECK THIS..."
echo "... the DEB will provide a drugref from " $newdate
echo ""

sed -e 's/^PROGRAM.*/PROGRAM='"$PROGRAM"'/' \
-e 's/^PACKAGE.*/PACKAGE='"$PACKAGE"'/' \
-e 's/^db_name.*/db_name='"$db_name"'/' \
-e 's/^VERSION.*/VERSION='"$VERSION"'/' \
-e 's/^PREVIOUS.*/PREVIOUS='"$PREVIOUS"'/' \
-e 's/^REVISION.*/REVISION='"$REVISION"'/' \
-e 's/^buildDateTime.*/buildDateTime=\"'"$buildDateTime"'\"/' \
-e 's/^newdate.*/newdate='"$newdate"'/' \
postinst > ./${DEBNAME}/DEBIAN/postinst
#
chmod 755 ./${DEBNAME}/DEBIAN/postinst

echo "Configuring postrm"
sed -e 's/^PROGRAM.*/PROGRAM='"$PROGRAM"'/' \
-e 's/^PACKAGE.*/PACKAGE='"$PACKAGE"'/' \
-e 's/^db_name.*/db_name='"$db_name"'/' \
-e 's/^VERSION.*/VERSION='"$VERSION"'/' \
-e 's/^PREVIOUS.*/PREVIOUS='"$PREVIOUS"'/' \
-e 's/^REVISION.*/REVISION='"$REVISION"'/' \
-e 's/^buildDateTime.*/buildDateTime=\"'"$buildDateTime"'\"/' \
postrm > ./${DEBNAME}/DEBIAN/postrm

chmod 755 ./${DEBNAME}/DEBIAN/postrm

echo "Configuring prerm"
sed -e 's/^PROGRAM.*/PROGRAM='"$PROGRAM"'/' \
-e 's/^PACKAGE.*/PACKAGE='"$PACKAGE"'/' \
-e 's/^db_name.*/db_name='"$db_name"'/' \
-e 's/^VERSION.*/VERSION='"$VERSION"'/' \
-e 's/^PREVIOUS.*/PREVIOUS='"$PREVIOUS"'/' \
-e 's/^REVISION.*/REVISION='"$REVISION"'/' \
prerm > ./${DEBNAME}/DEBIAN/prerm


chmod 755 ./${DEBNAME}/DEBIAN/prerm

cp -R templates ./${DEBNAME}/DEBIAN/

chmod 644 ./${DEBNAME}/DEBIAN/templates

echo "loading utilities and properties"
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/

echo "make up the appropriate source.txt for this build"
echo SHA1=${SHA1}



sed -e 's/SHA1/'"$SHA1"'/' \
-e 's/yyy-x.x/'"$VERSION"'-'"$REVISION"'/' \
-e 's/oscarprogram/'"$PROGRAM"'/' \
-e 's/build xxx/build '"$BUILD"'/' \
source.txt > ./${DEBNAME}/usr/share/${PACKAGE}/source.txt

echo "make up the appropriate rebooting script"
sed -e 's/^PROGRAM.*/PROGRAM='"$PROGRAM"'/' \
reOscar.sh > ./${DEBNAME}/usr/share/${PACKAGE}/reOscar.sh
# note that the origional scripts are .sh
# end users should rename to prevent overwrites

chmod 711 ./${DEBNAME}/usr/share/${PACKAGE}/reOscar.sh
cp gateway.sh ./${DEBNAME}/usr/share/${PACKAGE}/gateway.sh
cp letsencrypt.cron ./${DEBNAME}/usr/share/${PACKAGE}/letsencrypt.sh
chmod 755 ./${DEBNAME}/usr/share/${PACKAGE}/gateway.sh
chmod 755 ./${DEBNAME}/usr/share/${PACKAGE}/letsencrypt.sh

#cd NDSS/
#zip ../ndss.zip *
#cd ../
#cd rbr2014/
#zip ../rbr2014.zip *
#cd ../

echo "copying over utility scripts"
cp -R ExcellerisDownload.sh ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R usr.local.bin.wkhtmltopdf ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R usr.bin.wkhtmltopdf ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R demo.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R drugref.sql ./${DEBNAME}/usr/share/${PACKAGE}/
##cp -R CVC.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R OfficeCodes.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R OLIS.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R Oscar11_to_oscar_12.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R oscar10_12_to_Oscar11.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R oscar_12_to_oscar_12_1.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R rbr2014.zip ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R ndss.zip ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R RourkeEform.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R RourkeEformNational.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R ndss.sql ./${DEBNAME}/usr/share/${PACKAGE}/

cp -R tallMAN.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R tallMANdrugref.sql ./${DEBNAME}/usr/share/${PACKAGE}/

cp -R ontarioLab.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R FIT.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R opr2017.sql ./${DEBNAME}/usr/share/${PACKAGE}/

#rm ndss.zip
#rm rbr2014.zip

chmod 644 ./${DEBNAME}/usr/share/${PACKAGE}/rbr2014.zip
chmod 644 ./${DEBNAME}/usr/share/${PACKAGE}/ndss.zip


cp -R patch19.sql ./${DEBNAME}/usr/share/${PACKAGE}/patch.sql

cp -R oscar_12_1_to_oscar_12_1_1.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R oscar_12_1_1_to_oscar_15.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R oscar_15_to_oscar_19.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R legacyMyISAM.sql ./${DEBNAME}/usr/share/${PACKAGE}/

# use the stock properties file as config will fix as needed
# use the specific one for this build from this makers folder
cp -R oscar_mcmaster.properties ./${DEBNAME}/usr/share/${PACKAGE}/oscar_mcmaster.properties

#cp -R OscarON15.sql ./${DEBNAME}/usr/share/${PACKAGE}/OscarON15.sql
cp -R OscarON19.sql ./${DEBNAME}/usr/share/${PACKAGE}/OscarON19.sql
#cp -R OscarBC15.sql ./${DEBNAME}/usr/share/${PACKAGE}/OscarBC15.sql
cp -R OscarBC19.sql ./${DEBNAME}/usr/share/${PACKAGE}/OscarBC19.sql

## TODO make consolidated sql's to start off for version 20

#cp -R OscarON${VERSION}.sql ./${DEBNAME}/usr/share/${PACKAGE}/OscarON${VERSION}.sql
#cp -R OscarBC${VERSION}.sql ./${DEBNAME}/usr/share/${PACKAGE}/OscarBC${VERSION}.sql

cp -R README.txt ./${DEBNAME}/usr/share/${PACKAGE}/

cp -R RNGPA.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R special.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R unDemo.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R OLIS.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R indicatorTemplatePANEL.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R DoBC_dashboard.sql ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R bc_billing_dashboard.sql ./${DEBNAME}/usr/share/${PACKAGE}/

cp -R tomcat7server.xml ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R tomcat8server.xml ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R tomcat8LEserver.xml ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R tomcat9server.xml ./${DEBNAME}/usr/share/${PACKAGE}/
cp -R tomcat9LEserver.xml ./${DEBNAME}/usr/share/${PACKAGE}/

cp -R run_rxquery.sh ./${DEBNAME}/usr/share/${PACKAGE}/
chmod 711 ./${DEBNAME}/usr/share/${PACKAGE}/run_rxquery.sh
#cp -R 2FA.sh ./${DEBNAME}/usr/share/${PACKAGE}/
#chmod 711 ./${DEBNAME}/usr/share/${PACKAGE}/2FA.sh

echo "copying over now the backup scripts"
cp -R oscar_backup.sh ./${DEBNAME}/usr/share/${PACKAGE}/
chmod 711 ./${DEBNAME}/usr/share/${PACKAGE}/oscar_backup.sh
#mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/oscar_backup/
cp -R restore.sh ./${DEBNAME}/usr/share/${PACKAGE}/
chmod 711 ./${DEBNAME}/usr/share/${PACKAGE}/restore.sh
cp -R drugrefUpdate.cron ./${DEBNAME}/usr/share/${PACKAGE}/
chmod +x ./${DEBNAME}/usr/share/${PACKAGE}/drugrefUpdate.cron

echo "getting and loading wars"
mkdir -p ./${DEBNAME}${C_BASE}webapps/

echo "build directory made to receive wars"



cp drugref2-1.0-SNAPSHOT.war drugref.war
cp drugref.war ./${DEBNAME}${C_BASE}webapps/drugref.war
cp $TARGET ./${DEBNAME}${C_BASE}webapps/$PROGRAM.war

##cd ../
##mvn -Dmaven.test.skip=true verify

# send the unpacked war into the webapps folder, then it won't clobber documents when installed

#mkdir -p ./${DEBNAME}${C_BASE}webapps/OscarDocument/

#until git clone git://git.code.sf.net/p/oscarmcmaster/oscar_documents; do
#  echo "Git clone disrupted, retrying in 2 seconds..."
#  sleep 2
#done

 
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/
cp -r OscarDocument/oscar/ ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/

echo "now adding in default inbox directories"
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/incomingdocs/
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/incomingdocs/1/Fax
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/incomingdocs/1/File
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/incomingdocs/1/Mail
mkdir -p ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/incomingdocs/1/Refile

echo "now adding in Ontario Lab eform"
cp -R labDecisionSupport.js ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/
cp -R 4422-84v9-1.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/
#cp -R OscarDocument/${PROGRAM}/eform/images/4422-84labReq.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/

echo "now adding in Ontario OPR 2017 files"
cp -R OscarDocument/${PROGRAM}/eform/images/OPR-2017a.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/
cp -R OscarDocument/${PROGRAM}/eform/images/OPR-2017b.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/
cp -R OscarDocument/${PROGRAM}/eform/images/OPR-2017c.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/
cp -R OscarDocument/${PROGRAM}/eform/images/OPR-2017d.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/
cp -R OscarDocument/${PROGRAM}/eform/images/OPR-2017e.png ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/

echo "now adding in Ontario pharmacy file for LU codes"
cp -R OscarDocument/${PROGRAM}/eform/images/data_extract.xml ./${DEBNAME}/usr/share/${PACKAGE}/OscarDocument/${PROGRAM}/eform/images/

echo "now invoking dpkg -b ${DEBNAME}"

dpkg -b ${DEBNAME}
echo ""
echo "Testing the deb for update locally"
echo "#########" `date` "#########" 
dpkg -i ${DEBNAME}.deb
echo ""
echo ""
echo ""
echo "If it works please remember to"
echo scp ${DEBNAME}.deb peter_hc@frs.sourceforge.net:\"/home/frs/project/oscarmcmaster/Oscar\\ Debian\\+Ubuntu\\ deb\\ Package/\"
echo ""
echo "so then people can"
echo wget http://sourceforge.net/projects/oscarmcmaster/files/Oscar\\ Debian\\+Ubuntu\\ deb\\ Package/${DEBNAME}.deb
echo "the md5sum is" 
md5sum ${DEBNAME}.deb
echo "#########" `date` "#########" 





