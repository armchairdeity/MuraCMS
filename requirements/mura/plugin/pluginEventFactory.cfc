<!--- This file is part of Mura CMS.

    Mura CMS is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, Version 2 of the License.

    Mura CMS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Mura CMS.  If not, see <http://www.gnu.org/licenses/>.
	
	As a special exception to the terms and conditions of version 2.0 of
	the GPL, you may redistribute this Program as described in Mura CMS'
	Plugin exception. You should have recieved a copy of the text describing
	this exception, and it is also available here:
	'http://www.getmura.com/exceptions.txt"

	 --->
<cfcomponent extends="mura.Factory" output="false">

<cffunction name="init" output="false" returnType="any">
<cfargument name="class">
<cfargument name="siteid">
<cfargument name="genericManager">
<cfargument name="pluginManager">
	<cfset variables.class=arguments.class>
	<cfset variables.siteid=arguments.siteid>
	<cfset variables.genericManager=arguments.genericManager>
	<cfset variables.pluginManager=arguments.pluginManager>
	<cfset super.init() />
	<cfreturn this>
</cffunction>

<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="localHandler" default="" required="true" />
		<cfargument name="persist" default="true" required="true" />
		<cfset var hashKey = getHashKey( arguments.key ) />
		<cfset var checkKey= "__check__" & arguments.key>
		<cfset var localKey=arguments.key & variables.class>
		<cfset var hashCheckKey = getHashKey( checkKey ) />
		<cfset var rs="" />
		<cfset var event="" />
		<cfset var classInstance="" />
		<cfset var wrappedClassInstance="" />
	
		<!---If the local handler has a locally defined method then use it instead --->
		<cfif NOT arguments.persist or NOT has( localKey )>
			<cfif isObject(arguments.localHandler) and structKeyExists(arguments.localHandler, localKey)>
				<cfset classInstance=localHandler>
				<cfset wrappedClassInstance=variables.genericManager.getFactory(variables.class).wrapHandler(classInstance, localKey)>	
				<cfif arguments.persist>
					<cfset super.set( localKey, wrappedClassInstance )>
				</cfif>
				<cfreturn wrappedClassInstance />
			</cfif>
		
			<!---If there is a non plugin listener then use it instead --->
			<cfset classInstance=variables.pluginManager.getSiteListener(variables.siteID, localKey)>
			<cfif isObject(classInstance)>
				<cfset wrappedClassInstance=variables.genericManager.getFactory(variables.class).wrapHandler(classInstance, localKey)>
				<cfif arguments.persist>
					<cfset super.set( localKey, wrappedClassInstance )>			
				</cfif>
				<cfreturn wrappedClassInstance />
			</cfif>
		</cfif>
		
		<!--- Check if the prelook for plugins has been made --->
		<cfif NOT arguments.persist or NOT has( checkKey )>	
			
			<cfset rs=variables.pluginManager.getScripts(localKey, variables.siteid)>
			<!--- If it has not then get it--->
			<cfif arguments.persist>
				<cfset super.set( checkKey, rs.recordcount ) />
			</cfif>
			
			<cfif rs.recordcount>
				<cfset classInstance=variables.pluginManager.getComponent("plugins.#rs.directory#.#rs.scriptfile#", rs.pluginID, variables.siteID, rs.docache)>
				<cfset wrappedClassInstance=variables.genericManager.getFactory(variables.class).wrapHandler(classInstance, localKey)>
				<cfif arguments.persist>
					<cfset super.set( localKey, wrappedClassInstance )>
				</cfif>
				<cfreturn wrappedClassInstance />
			</cfif>
		</cfif>
		
		<cfif super.has( localKey )>
			<!--- It's already in cache --->
			<cfreturn super.get( localKey )>
		<cfelse>
			<!--- return cached context --->		
			<cfreturn variables.genericManager.getFactory(variables.class).get(arguments.key,arguments.persist) />
		</cfif>

</cffunction>


</cfcomponent>