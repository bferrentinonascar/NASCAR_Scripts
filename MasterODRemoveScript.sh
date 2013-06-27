#!/bin/bash

# Heavily modified from code by Patrick Gallagher http://www.macadmincorner.com
# Updated 06/25/13 by Ben Ferrentino and Jared Egenes for NASCAR
# dogs > cats

# Static variables - NASCAR OD
# OD Admin
odAdmin="diradmin"
# OD Admin PW
odPassword="Enigma2011"
# FQDN of OD domain
domain="clt-od-srv1.nascar.com"
# Invaild OD address
badDomain1="CLT-OD-SRV1.nascar.com"
# Invaild OD address
badDomain2="clt-od-srv1"
# Invaild OD address
badDomain3="CLT-OD-SRV1"
# Primary OD group
computerGroup=casperimage_corp

# variables
nicAddress=`ifconfig en0 | grep ether | awk '{print $2}'`
computerName=`networksetup -getcomputername`
computerSecureName=$computerName$
check4OD=`dscl localhost -list /LDAPv3`
check4BadODacct=`dscl /LDAPv3/${domain} -read Computers/${computerName} RecordName | awk '{ print $2 }'`
listAllRecords=`dscl /LDAPv3/${domain} -search /Computers ENetAddress ${nicAddress} | awk ' { print $1 } ' | sed -e '/)/d' -e '/:/d'`
falseENet=`dscl /LDAPv3/${domain} -search /Computers ENetAddress ${nicAddress} | awk ' { print $1 } ' | sed -e '/)/d' -e '/:/d' | grep -wv ${computerSecureName} | sed -n 1p`

# FIRST OD check
if [ "${check4OD}" == "${domain}" ]; then
dsconfigldap -r ${domain}
sleep 3
echo "y" | dsconfigldap -a $domain -n $domain -u $odAdmin -p $odPassword
sleep 3
echo "This machine was rebound to ${domain}."

# SECOND OD check
else if [ "${check4OD}" == "${badDomain1}" ]; then
dsconfigldap -r "${badDomain1}"
sleep 3
echo "y" | dsconfigldap -a $domain -n $domain -u $odAdmin -p $odPassword
sleep 3
echo "This machine was bound to ${domain}."

# THIRD OD check
else if [ "${check4OD}" == "${badDomain2}" ]; then
dsconfigldap -r "${badDomain2}"
sleep 3
echo "y" | dsconfigldap -a $domain -n $domain -u $odAdmin -p $odPassword
sleep 3
echo "This machine was bound to ${domain}."

# FOURTH OD check
else if [ "${check4OD}" == "${badDomain3}" ]; then
dsconfigldap -r "${badDomain3}"
sleep 3
echo "y" | dsconfigldap -a $domain -n $domain -u $odAdmin -p $odPassword
sleep 3
echo "This machine was bound to ${domain}."

# FRESH bind to OD
else
echo "y" | dsconfigldap -a $domain -n $domain -u $odAdmin -p $odPassword
sleep 3
fi
fi
fi
fi

# Check for matching ENetAddress and non-matching records
if [ "${computerSecureName}" = "${listAllRecords}" ]; then
        echo "BAM - We're g2g"

# Another Check
else if [ "${computerSecureName}" != "${listAllRecords}" ]; then
        echo "Oh snap - Found something off!"
        dscl /LDAPv3/${domain} -delete /Computers/${falseENet}
        echo "Deleted that sucker"

# Another Check
#else if [ "${computerSecureName}" != "${listAllRecords}" ]; then
#        echo "Oh snap - Found something off!"
#        else dscl /LDAPv3/${domain} -delete /Computers/${falseENet}

# Another Check
#else if [ "${computerSecureName}" != "${listAllRecords}" ]; then
#        echo "Oh snap - Found something off!"
#        else dscl /LDAPv3/${domain} -delete /Computers/${falseENet}
# Note we don't know how to make this a loop yet... 
#fi
#fi
fi
fi

# Add to casperimage_corp

echo "Have a Nice Day :)"

exit
