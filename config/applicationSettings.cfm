<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. �See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. �If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes
the preparation of a derivative work based on Mura CMS. Thus, the terms and 	
conditions of the GNU General Public License version 2 (�GPL�) cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission
to combine Mura CMS with programs or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, �the copyright holders of Mura CMS grant you permission
to combine Mura CMS �with independent software modules that communicate with Mura CMS solely
through modules packaged as Mura CMS plugins and deployed through the Mura CMS plugin installation API,
provided that these modules (a) may only modify the �/trunk/www/plugins/ directory through the Mura CMS
plugin installation API, (b) must not alter any default objects in the Mura CMS database
and (c) must not alter any files in the following directories except in cases where the code contains
a separately distributed license.

/trunk/www/admin/
/trunk/www/tasks/
/trunk/www/config/
/trunk/www/requirements/mura/

You may copy and distribute such a combined work under the terms of GPL for Mura CMS, provided that you include
the source code of that other code when and as the GNU GPL requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception
for your modified version; it is your choice whether to do so, or to make such modified version available under
the GNU General Public License version 2 �without this exception. �You may, if you choose, apply this exception
to your own modified versions of Mura CMS.
--->
	<cfset this.configPath=getDirectoryFromPath(getCurrentTemplatePath())>
	<!--- Application name, should be unique --->
	<cfset this.name = "mura" & hash(getCurrentTemplatePath()) />
	<!--- How long application vars persist --->
	<cfset this.applicationTimeout = createTimeSpan(3,0,0,0)>
	<!--- Where should cflogin stuff persist --->
	<cfset this.loginStorage = "cookie">
	
	<cfset this.sessionManagement = true>
	
	<!--- Should we set cookies on the browser? --->
	<cfset this.setClientCookies = true>
	
	<!--- should cookies be domain specific, ie, *.foo.com or www.foo.com 
	<cfset this.setDomainCookies = not refind('\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b',listFirst(cgi.http_host,":"))>
	--->
	<!--- should we try to block 'bad' input from users --->
	<cfset this.scriptProtect = false>
	<!--- should we secure our JSON calls? --->
	<cfset this.secureJSON = false>
	<!--- Should we use a prefix in front of JSON strings? --->
	<cfset this.secureJSONPrefix = "">
	<!--- Used to help CF work with missing files and dir indexes --->
	<cfset this.welcomeFileList = "">

<!--- Preferred method for ColdFusion 8, allows you to skip administering these settings in the CF admin	
	1. Place Mura requirements directory in your webroot
	2. Place Mura Custom Tags directory into "requirements/custom_tags/"
	2. Change basedir to point to your webroot
	3. Uncomment the code below
	--->
	
	<!--- Define the location of your frameworks 
		The default here is dynamically pointing at the webroot
	--->
	<cfset baseDir= left(this.configPath,len(this.configPath)-8) />
			
	<cfif StructKeyExists(SERVER,"bluedragon") and not findNoCase("Windows",server.os.name)>
		<cfset mapPrefix="$" />
	<cfelse>
		<cfset mapPrefix="" />
	</cfif>

	<!--- define custom coldfusion mappings. Keys are mapping names, values are full paths  --->
	<cfset this.mappings = structNew()>
	<cfset this.mappings["/plugins"] = mapPrefix & baseDir & "/plugins">
	<cfset this.mappings["/muraWRM"] = mapPrefix & baseDir>
	<cfset this.mappings["/savaWRM"] = mapPrefix & baseDir>
	<cfset this.mappings["/config"] = mapPrefix & baseDir & "/config">
	
	<cftry>
		<cfinclude template="/config/mappings.cfm">
		<cfset hasMainMappings=true>
		<cfcatch>
			<cfset hasMainMappings=false>
		</cfcatch>
	</cftry>
	<cftry>
		<cfinclude template="/plugins/mappings.cfm">
		<cfset hasPluginMappings=true>
		<cfcatch>
			<cfset hasPluginMappings=false>
		</cfcatch>
	</cftry>
	
	<cfif not fileExists(baseDir & "/config/settings.ini.cfm")>
		<cftry>
		<cffile action="copy" source="#baseDir#/config/templates/settings.template.cfm" destination="#baseDir#/config/settings.ini.cfm" mode="777">
		<cfcatch>
			<cffile action="copy" source="#baseDir#/config/templates/settings.template.cfm" destination="#baseDir#/config/settings.ini.cfm">
		</cfcatch>
		</cftry>
	</cfif>
	
	<cfset properties = createObject( 'java', 'java.util.Properties' ).init()>
	<cfset fileStream = createObject( 'java', 'java.io.FileInputStream').init( getDirectoryFromPath(getCurrentTemplatePath()) & "/settings.ini.cfm")>
	<cfset properties.load( fileStream )>
	
	<cfset request.userAgent = LCase( CGI.http_user_agent ) />
	<!--- Should we even use sessions? --->
	<cfset request.trackSession = not (NOT Len( request.userAgent ) OR
	 REFind( "bot\b", request.userAgent ) OR
	 Find( "_bot_", request.userAgent ) OR
	 Find( "crawl", request.userAgent ) OR
	 REFind( "\brss", request.userAgent ) OR
	 Find( "feed", request.userAgent ) OR
	 Find( "news", request.userAgent ) OR
	 Find( "blog", request.userAgent ) OR
	 Find( "reader", request.userAgent ) OR
	 Find( "syndication", request.userAgent ) OR
	 Find( "coldfusion", request.userAgent ) OR
	 Find( "slurp", request.userAgent ) OR
	 Find( "google", request.userAgent ) OR
	 Find( "zyborg", request.userAgent ) OR
	 Find( "emonitor", request.userAgent ) OR
	 Find( "jeeves", request.userAgent ) OR 
	 Find( "ping", request.userAgent ) OR 
	 FindNoCase( "java", request.userAgent ) OR 
	 FindNoCase( "cfschedule", request.userAgent ) OR
	 FindNoCase( "reeder", request.userAgent ) OR
	 Find( "spider", request.userAgent ))>
	 
	<!--- How long do session vars persist? --->
	<cfif request.trackSession>
		<cfset this.sessionTimeout = (properties.getProperty("sessionTimeout","180") / 24) / 60>
	<cfelse>
		<cfset this.sessionTimeout = createTimeSpan(0,0,5,0)>
	</cfif>
	
	<!--- define a list of custom tag paths. --->
	<cfset this.customtagpaths = properties.getProperty("customtagpaths","") />
	<cfset this.customtagpaths = listAppend(this.customtagpaths,mapPrefix & baseDir  &  "/requirements/custom_tags/")>
	
	<cfset this.clientManagement = properties.getProperty("clientManagement","false") />
	<cfset this.clientStorage = properties.getProperty("clientStorage","registry") />
	<cfset this.ormenabled = properties.getProperty("ormenabled","true") />
	<cfset this.datasource = properties.getProperty("datasource","") />
	<cfset this.ormSettings=structNew()>
	<cfset this.ormSettings.cfclocation=arrayNew(1)>
	
	<cfif this.ormenabled>
		<cfswitch expression="#properties.getProperty('dbtype','')#">
			<cfcase value="mssql">
				<cfset this.ormSettings.dialect = "MicrosoftSQLServer" />
			</cfcase>
			<cfcase value="mysql">
				<cfset this.ormSettings.dialect = "MySQL" />
			</cfcase>
			<cfcase value="oracle">
				<cfset this.ormSettings.dialect = "Oracle10g" />
			</cfcase>
		</cfswitch>
		<cfset this.ormSettings.dbcreate = properties.getProperty("ormdbcreate","update") />
		<cfif len(properties.getProperty("ormcfclocation",""))>
			<cfset arrayAppend(this.ormSettings.cfclocation,properties.getProperty("ormcfclocation")) />
		</cfif>
		<cfset this.ormSettings.flushAtRequestEnd = properties.getProperty("ormflushAtRequestEnd","false") />
		<cfset this.ormsettings.eventhandling = properties.getProperty("ormeventhandling","true") />
		<cfset this.ormSettings.automanageSession = properties.getProperty("ormautomanageSession","false") />
		<cfset this.ormSettings.savemapping=properties.getProperty("ormsavemapping","false") />
		<cfset this.ormSettings.skipCFCwitherror=properties.getProperty("ormskipCFCwitherror","false") />
		<cfset this.ormSettings.useDBforMapping=properties.getProperty("ormuseDBforMapping","true") />
		<cfset this.ormSettings.autogenmap=properties.getProperty("ormautogenmap","true") />
	</cfif>
	
	<cfset request.muraFrontEndRequest=false>
	<cfset request.muraChangesetPreview=false>
	<cfset request.muraExportHtml = false>
	<cfset request.muraMobileRequest=false>
	<cfset request.muraHandledEvents = structNew()>
	<cfset request.altTHeme = "">	
	<cfset request.customMuraScopeKeys = structNew()>	
	
	<cftry>
		<cfinclude template="/plugins/cfapplication.cfm">
		<cfset hasPluginCFApplication=true>
		<cfcatch>
			<cfset hasPluginCFApplication=false>
		</cfcatch>
	</cftry>
	<cftry>
		<cfinclude template="/config/cfapplication.cfm">
		<cfset request.hasCFApplicationCFM=true>
		<cfcatch>
			<cfset request.hasCFApplicationCFM=false>
		</cfcatch>
	</cftry>
	
	<cfif not (isSimpleValue(this.ormSettings.cfclocation) and len(this.ormSettings.cfclocation))
		and not (isArray(this.ormSettings.cfclocation) and arrayLen(this.ormSettings.cfclocation))>
		<cfset this.ormenabled=false>
	</cfif>