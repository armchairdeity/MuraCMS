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

<cfset theTime=now()/>
<cfparam name="application.lastMonitored" default="#dateadd('n',-1,theTime)#"/>
<cfset addPrev=minute(application.lastMonitored) neq minute(dateadd("n",-30,theTime))/>

<cfif addPrev>
<cfset application.contentManager.sendReminders(dateadd("n",-30,theTime)) />
</cfif>
<cfset application.contentManager.sendReminders(theTime) />

<!---<cfif hour(theTime) eq 2 and (minute(theTime) eq 0 or (addPrev and minute(application.lastMonitored) eq 0))>
<cfset application.advertiserManager.compact() />
</cfif>--->

<cfset application.emailManager.send() />

<cfset emailList="" />
<cfloop collection="#application.settingsManager.getSites()#" item="site"> 
<cfset theEmail = application.settingsManager.getSite(site).getMailServerUsername() />
	<cfif application.settingsManager.getSite(site).getEmailBroadcaster()>
		<cfif not listFind(emailList,theEmail)>
			<cfset application.emailManager.trackBounces(site) />
			<cfset listAppend(emailList,theEmail) />
		</cfif>
	</cfif>
</cfloop>

<cfif (minute(theTime) eq 0 and hour(theTime) eq 0) or (addPrev and (minute(application.lastMonitored) eq 0 and hour(application.lastmonitored) eq 0))>
	<cfset application.settingsManager.purgeAllCache() />
	<cftry>
	<cfset application.projectManager.sendReminders() />
	<cfcatch></cfcatch>
	</cftry>
<cfelse>
	<cfquery name="rsChanges" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
	select distinct tcontent.siteid from tcontent inner join tcontent tcontent2 on tcontent.parentid=tcontent2.contentid 
	where tcontent.approved=1 and tcontent.active=1 and tcontent.display=2 and tcontent2.type <> 'Calendar'
	and ((tcontent.displaystart >=#createodbcdatetime(application.lastmonitored)#
	and tcontent.displaystart <=#createodbcdatetime(theTime)#)
	or
	(tcontent.displaystop >=#createodbcdatetime(application.lastmonitored)#
	and tcontent.displaystop <=#createodbcdatetime(theTime)#))
	group by tcontent.siteid
	</cfquery>
	
	<cfif rsChanges.recordcount>
		<cfloop query="rsChanges">
			<cfset application.settingsManager.getSite(rsChanges.siteid).purgeCache() />
		</cfloop>
	</cfif>
</cfif>
<!--- clear out old temp files --->
<cfdirectory name="tmpFiles" action="list" directory="#application.configBean.getTempDir()#" >

 <cfloop query="tmpFiles">
  <cfif tmpFiles.type eq "File" and DateDiff('n',tmpFiles.datelastmodified,now()) gt 30>
  <cffile action="delete" file="#application.configBean.getTempDir()##tmpFiles.name#">
  </cfif>
</cfloop> 

<cfset pluginEvent = createObject("component","#application.configBean.getMapDir()#.event") />
<cfset application.pluginManager.executeScripts('onSiteMonitor','',pluginEvent)/>

<cfset application.lastMonitored=theTime/>