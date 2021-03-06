<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. ÔøΩSee the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. ÔøΩIf not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes
the preparation of a derivative work based on Mura CMS. Thus, the terms and 	
conditions of the GNU General Public License version 2 (ÔøΩGPLÔøΩ) cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission
to combine Mura CMS with programs or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, ÔøΩthe copyright holders of Mura CMS grant you permission
to combine Mura CMS ÔøΩwith independent software modules that communicate with Mura CMS solely
through modules packaged as Mura CMS plugins and deployed through the Mura CMS plugin installation API,
provided that these modules (a) may only modify the ÔøΩ/trunk/www/plugins/ directory through the Mura CMS
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
the GNU General Public License version 2 ÔøΩwithout this exception. ÔøΩYou may, if you choose, apply this exception
to your own modified versions of Mura CMS.
--->
<cfcomponent output="false" extends="mura.cfobject">

<cffunction name="purgeSiteCache" returntype="any" access="remote" output="false">
	<cfargument name="siteid" required="true" default="">
	<cfargument name="appreloadkey" required="true" default="">
	<cfargument name="instanceID" required="true" default="">
	<cfif arguments.instanceID neq application.instanceID 
		and arguments.appreloadkey eq application.appreloadkey>
		<cfif len(arguments.siteid)>
			<cfset application.settingsManager.getSite(arguments.siteID).getCacheFactory().purgeAll()>	
		<cfelse>
			<cfset application.settingsManager.purgeAllCache()>
		</cfif>
	</cfif>
</cffunction>

<cffunction name="reload" returntype="any" access="remote" output="false">
	<cfargument name="appreloadkey" required="true" default="">
	<cfargument name="instanceID" required="true" default="">
	<cfif arguments.instanceID neq application.instanceID 
		and arguments.appreloadkey eq application.appreloadkey>
		<cfset application.appInitialized=false/>
		<cfset application.broadcastInit=false />
	</cfif>
</cffunction>

<cffunction name="login" returntype="any" output="false" access="remote">
	<cfargument name="username">
	<cfargument name="password">
	<cfargument name="siteID">
	<cfset var authToken=hash(createUUID())>
	<cfset var rsSession="">
	<cfset var sessionData="">
	
	<cfset application.loginManager.remoteLogin(arguments)>
	
	<cfif session.mura.isLoggedIn>
		<cfwddx action="cfml2wddx" output="sessionData" input="#session.mura#">

		<cfquery name="rsSession" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			select * from tuserremotesessions
			where userID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">
		</cfquery>
		
		<cfif rsSession.recordcount>
			
			<cfif rsSession.lastAccessed gte dateAdd("h",-3,now()) and application.configBean.getSharableRemoteSessions()>
				<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
					update tuserremotesessions set
					data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#sessionData#">,
					lastAccessed=#createODBCDateTime(now())#
					where userID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">
				</cfquery>
				
				<cfset authToken=rsSession.AuthToken>
				
			<cfelse>
				<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
					update tuserremotesessions set
					authToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
					data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#sessionData#">,
					created=#createODBCDateTime(now())#,
					lastAccessed=#createODBCDateTime(now())#
					where userID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">
				</cfquery>
				
			</cfif>
		<cfelse>
			<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
				INSERT Into tuserremotesessions (userID,authToken,data,created,lastAccessed)
				values(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#sessionData#">,
				#createODBCDateTime(now())#,
				#createODBCDateTime(now())#
				)
			</cfquery>
	
		</cfif>
		
		
		<cfreturn authToken>
	<cfelse>
		<cfif isDate(session.blockLoginUntil) and session.blockLoginUntil gt now()>
			<cfset application.loginManager.logout()>
			<cfreturn "blocked">
		<cfelse>
			<cfset application.loginManager.logout()>
			<cfreturn "false">
		</cfif>
	</cfif>
</cffunction>

<cffunction name="logout" returntype="any" output="false" access="remote">
	<cfargument name="authToken">
	
	<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		update tuserremotesessions set
		lastAccessed=#createODBCDateTime(dateAdd("h",-3,now()))#
		where authToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
	</cfquery>
	
	<cfset application.loginManager.logout()>

</cffunction>

<cffunction name="getService" returntype="any" output="false">
<cfargument name="serviceName">
	
	<cfif not structKeyExists(application,"proxyServices")>
		<cfset application.proxyServices=structNew()>
	</cfif>
	
	<cfif not structKeyExists(application.proxyServices, arguments.serviceName)>
		<cfset application.proxyServices[arguments.serviceName]=createObject("component","mura.proxy.#arguments.serviceName#").init()>
	</cfif>
	
	<cfreturn application.proxyServices[arguments.serviceName]>
</cffunction>

<cffunction name="isValidSession" returntype="any" output="false">
<cfargument name="authToken">
	<cfset var rsSession="">
	
	<cfif not len(arguments.authToken)>
		<cfreturn false>
	<cfelse>
		<cfquery name="rsSession" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			select authToken from tuserremotesessions
			where authtoken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
			and lastAccessed > #createODBCDateTime(dateAdd("h",-3,now()))#
		</cfquery>
		
		<cfreturn rsSession.recordcount>
	</cfif>
</cffunction>

<cffunction name="getSession" returntype="any" output="false">
<cfargument name="authToken">
	<cfset var rsSession="">
	<cfset var sessionData=structNew()>
	
	<cfquery name="rsSession" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		select * from tuserremotesessions
		where authtoken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
	</cfquery>
	
	<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		update tuserremotesessions
		set lastAccessed=#createODBCDateTime(now())#
		where authToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
	</cfquery>
	
	<cfwddx action="wddx2cfml" input="#rsSession.data#" output="sessionData">
	
	<cfreturn sessionData>
</cffunction>

<cffunction name="call" returntype="any" access="remote">
<cfargument name="serviceName">
<cfargument name="methodName">
<cfargument name="authToken" default="">
<cfargument name="args" default="#structNew()#">

<cfset var event="">
<cfset var service="">	

<cfif isJSON(arguments.args)>
	<cfset arguments.args=deserializeJSON(arguments.args)>
<cfelseif isWddx(arguments.args)>
	<cfwddx action="wddx2cfml" input="#arguments.args#" output="arguments.args">
</cfif>

<cfif (isDefined("session.mura.isLoggedIn") and session.mura.isLoggedIn)
		or (len(arguments.authToken) and isValidSession(arguments.authToken))>
	
	<cfif len(arguments.authToken)>
		<cfset session.mura=getSession(arguments.authToken)>
		<cfset session.siteID=session.mura.siteID>
		<cfset application.rbFactory.resetSessionLocale()>
	</cfif>
	
	<cfif not isObject(arguments.args)>
		<cfset event=createObject("component","mura.event")>
		<cfset event.init(args)>
		<cfset event.setValue("proxy",this)>
	<cfelse>
		<cfset event=args>
	</cfif>

	<cfset event.setValue("isProxyCall",true)>
	<cfset event.setValue("serviceName",arguments.serviceName)>
	<cfset event.setValue("methodName",arguments.methodName)>
	<cfset service=getService(event.getValue('serviceName'))>
	
	<cfinvoke component="#service#" method="call">
		<cfinvokeargument name="event" value="#event#" />
	</cfinvoke>
	
	<cfif len(arguments.authToken)>
		<cfset application.loginManager.logout()>
	</cfif>
	
	<cfreturn event.getValue("__response__")>

<cfelse>
	<cfreturn "invalid session">
</cfif>
</cffunction>

</cfcomponent>