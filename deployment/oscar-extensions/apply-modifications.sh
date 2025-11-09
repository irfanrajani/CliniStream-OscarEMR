#!/bin/bash
# Apply NextScript modifications to base OSCAR files

set -e

OSCAR_SOURCE=$1

if [ -z "$OSCAR_SOURCE" ]; then
    echo "Usage: $0 <oscar-source-directory>"
    exit 1
fi

echo "Applying NextScript modifications to OSCAR source..."

# 1. Add NextScript action mapping to struts-config.xml
echo "Adding action mapping to struts-config.xml..."
sed -i '/<action input="\/admin\/manageFaxes.jsp"/a\
\t<action input="/admin/nextscriptSettings.jsp" path="/admin/NextScriptConfig" scope="request" parameter="method" type="org.oscarehr.integration.nextscript.NextScriptConfigAction">\
\t\t<forward name="completed" path="/admin/nextscriptSettings.jsp"/>\
\t</action>' "$OSCAR_SOURCE/src/main/webapp/WEB-INF/struts-config.xml"

# 2. Add NextScript link to admin.jsp
echo "Adding link to admin.jsp..."
sed -i '/<h3>&nbsp;<bean:message key="admin.admin.Integration" \/><\/h3>/,/<ul>/{
    /<ul>/a\
\t\t<li><a href="nextscriptSettings.jsp">NextScript Integration Settings (RingCentral, Ocean, Labs)</a></li>
}' "$OSCAR_SOURCE/src/main/webapp/admin/admin.jsp"

echo "NextScript modifications applied successfully!"
