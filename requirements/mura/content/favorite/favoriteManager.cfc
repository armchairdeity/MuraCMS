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
<cfcomponent extends="mura.cfobject" output="false">
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="configBean" type="any" required="yes">
		<cfargument name="settingsManager" type="any" required="yes">
		
		<cfset variables.configBean=arguments.configBean>
		<cfset variables.settingsManager=arguments.settingsManager>
		<cfset variables.dsn=variables.configBean.getDatasource()/>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="getFavorites" access="public" returntype="any">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="favoriteType" type="string" required="yes" default="all">
		<cfargument name="siteID" type="string" required="yes">
	
		<cfset var rs = "" />
		<cfquery name="rs" datasource="#variables.dsn#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
		select * from tusersfavorites
		where userID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>
		
		<cfif favoriteType neq 'all'>
			and type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.favoriteType#"/>
			and siteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
			order by rowNumber
		<cfelse>
			and siteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
			order by dateCreated
		</cfif>
		</cfquery>
		<cfreturn rs />
	</cffunction>
	
	
<cffunction name="getBean" access="public" returntype="any">
	<cfreturn createObject("component","favoriteBean").init(variables.configBean)>
</cffunction>

<cffunction name="getInternalContentFavorites" access="public" output="false" returntype="query">
	<cfargument name="userID" type="string" required="yes">
	<cfargument name="siteID" type="String">
	<cfargument name="type" type="String" required="false" default="">
	
	<cfset var rs ="" />

	<cfquery name="rs" datasource="#variables.configBean.getDatasource()#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
	SELECT tusersfavorites.favoriteID, tusersfavorites.favorite, tusersfavorites.dateCreated, tcontent.title, tcontent.releasedate, tcontent.menuTitle, tcontent.lastupdate, tcontent.summary, 
	tcontent.filename, tcontent.type, tcontent.contentid,
	tcontent.target,tcontent.targetParams, tcontent.restricted, tcontent.restrictgroups, tcontent.displaystart, tcontent.displaystop, tcontent.orderno,tcontent.sortBy,tcontent.sortDirection,
	tcontent.fileid, tcontent.credits, tcontent.remoteSource, tcontent.remoteSourceURL, tcontent.remoteURL,
	tfiles.fileSize,tfiles.fileExt
	FROM 	tcontent Inner Join tusersfavorites ON (tcontent.contentID=tusersfavorites.favorite 
									AND tcontent.siteID=tusersfavorites.siteID)
		Left Join tfiles ON (tcontent.fileID=tfiles.fileID)
		Left Join tcontent tparent on (tcontent.parentid=tparent.contentid
					    			and tcontent.siteid=tparent.siteid
					    			and tparent.active=1)
	WHERE
	tcontent.siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
	and tusersfavorites.userid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>
	
	<cfif len(arguments.type)>
	and tusersfavorites.type= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"/>
	</cfif>
	
	and tcontent.active=1
	
	  AND (
		  tcontent.Display = 1
		  OR
		  (	tcontent.Display = 2
			and (
					(tcontent.DisplayStart <= #createodbcdatetime(now())# 
					AND (tcontent.DisplayStop >= #createodbcdatetime(now())# or tcontent.DisplayStop is null))
					
					OR tparent.type='Calendar'
				)
		   )
			
		)
	ORDER BY tusersfavorites.dateCreated DESC
	</cfquery>
	
	<cfreturn rs />
	
	
</cffunction>
	
	<cffunction name="readFavorite" access="public" returntype="any">
		<cfargument name="favoriteID" type="string" required="yes">
	
		<cfset var favorite = getBean() />
		<cfset favorite.setFavoriteID(arguments.favoriteID) />
		<cfset favorite.load(argumentcollection=arguments) />
		 
		<cfreturn favorite />
	</cffunction>
	
	<cffunction name="checkForFavorite" access="public" returntype="boolean">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="contentID" type="string" required="yes">
		<cfargument name="type" type="string" required="false">
		
		<cfset var returnVar = "" />
		<cfset var rs = "" />
		
		<cfquery name="rs" datasource="#variables.configBean.getDatasource()#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
		select favorite from tusersfavorites where favorite= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
		and userID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>
			<cfif isDefined( "arguments.type" )>
				and type= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"/>
			</cfif>
		</cfquery>
	
		<cfif rs.recordCount gt 0>
			<cfset returnVar = true />
		<cfelse>
			<cfset returnVar = false />
		</cfif>
		
		<cfreturn returnVar />
	</cffunction>
	
	<cffunction name="saveFavorite" access="public" returntype="any">
		<cfargument name="favoriteID" type="string" required="yes">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="siteID" type="string" required="yes">
		<cfargument name="favoriteName" type="string" required="yes">
		<cfargument name="favoriteLocation" type="string" required="yes">
		<cfargument name="type" type="string" required="yes">
		<cfargument name="columnNumber" type="string" required="yes" default="">
		<cfargument name="rowNumber" type="string" required="yes" default="">
		<cfargument name="maxRssItems" type="string" required="yes" default="">
	
		<cfset var favorite = getBean() />
		<cfif arguments.favoriteID neq ''>
			<cfset favorite.setFavoriteID(arguments.favoriteID) />
		<cfelse>
			<cfset favorite.setFavoriteID(createUUID()) />
		</cfif>
		<cfset favorite.setSiteID(arguments.siteID) />
		<cfset favorite.setUserID(arguments.userID) />
		<cfset favorite.setFavoriteName(arguments.favoriteName) />
		<cfset favorite.setFavorite(arguments.favoriteLocation) />
		<cfset favorite.setType(arguments.type) />
		<cfset favorite.setColumnNumber(arguments.columnNumber) />
		<cfset favorite.setRowNumber(arguments.rowNumber) />
		<cfset favorite.setMaxRssItems(arguments.maxRssItems) />
		<cfset favorite.setDateCreated(now()) />
		
		
		<cfset favorite.save() />
		 
		<cfreturn favorite />
			
	</cffunction>
	
	<cffunction name="deleteFavorite" access="public" returntype="void">
		<cfargument name="favoriteID" type="string" required="yes">
		
	
		<cfset var favorite = getBean() />
		<cfset favorite.setFavoriteID(arguments.favoriteID) />
		
		
		<cfset favorite.delete() />
			
	</cffunction>
	
	<cffunction name="deleteRSSFavoriteByUserID" access="public" returntype="void">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="siteID" type="string" required="yes">
	
		<cfquery datasource="#application.configBean.getDatasource()#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			delete from tusersfavorites where type = 'RSS' 
			and userID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>
			and siteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
		</cfquery>
		
		
			
	</cffunction>

</cfcomponent>