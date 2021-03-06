<cfcomponent extends="controller" output="false">

<cffunction name="setPluginManager" output="false">
	<cfargument name="pluginManager">
	<cfset variables.pluginManager=arguments.pluginManager>
</cffunction>

<cffunction name="setClusterManager" output="false">
	<cfargument name="clusterManager">
	<cfset variables.clusterManager=arguments.clusterManager>
</cffunction>

<cffunction name="before" output="false">
	<cfargument name="rc">

	<cfif not listFind(session.mura.memberships,'S2')>
		<cfset secure(arguments.rc)>
	</cfif>
</cffunction>

<cffunction name="list" output="false">
	<cfargument name="rc">
	<cfparam name="arguments.rc.orderID" default="" />
	<cfparam name="arguments.rc.orderno" default="" />
	<cfparam name="arguments.rc.deploy" default="" />
	<cfparam name="arguments.rc.action" default="" />
	<cfparam name="arguments.rc.siteid" default="" />
	<cfparam name="arguments.rc.siteSortBy" default="site" />

	<cfif isdefined("arguments.rc.ckUpdate")>
		<cfset rc.sitesUpdated = updateSiteFilesToLatestVersion(rc) />
	</cfif>

	<cfif isdefined("arguments.rc.refresh")>
		<cfset variables.fw.redirect(action="cSettings.list",append="activeTab",path="")>
	</cfif>
	
	<cfif arguments.rc.action eq 'deploy'>
		<cfset variables.settingsManager.publishSite(arguments.rc.siteid)  />
	</cfif>
	
	<cfset variables.settingsManager.saveOrder(arguments.rc.orderno,arguments.rc.orderID)  />
	<cfset variables.settingsManager.saveDeploy(arguments.rc.deploy,arguments.rc.orderID) />
	<cfset arguments.rc.rsSites=variables.settingsManager.getList(sortBy=arguments.rc.siteSortBy) />
	<cfset arguments.rc.rsPlugins=variables.pluginManager.getAllPlugins() />
</cffunction>

<cffunction name="editSite" output="false">
	<cfargument name="rc">
	<cfset arguments.rc.siteBean=variables.settingsManager.read(arguments.rc.siteid) />
</cffunction>

<cffunction name="deletePlugin" output="false">
	<cfargument name="rc">
	<cfset variables.pluginManager.deletePlugin(arguments.rc.moduleID) />
	<cfset arguments.rc.activeTab=1>
	<cfset arguments.rc.refresh=1>
	<cfset variables.fw.redirect(action="cSettings.list",append="activeTab,refresh",path="")>
</cffunction>

<cffunction name="editPlugin" output="false">
	<cfargument name="rc">
	<cfset arguments.rc.pluginXML=variables.pluginManager.getPluginXML(arguments.rc.moduleID) />
	<cfset arguments.rc.rsSites=variables.settingsManager.getList() />
</cffunction>

<cffunction name="updatePluginVersion" output="false">
	<cfargument name="rc">
	<cfset arguments.rc.pluginConfig=variables.pluginManager.getConfig(arguments.rc.moduleID) />
</cffunction>

<cffunction name="deployPlugin" output="false">
	<cfargument name="rc">
	<cfset var tempID="">
	<cfparam name="arguments.rc.moduleID" default="" />
	
	<cfset tempID=variables.pluginManager.deploy(arguments.rc.moduleID) />
	
	<cfif len(tempID)>
		<cfset arguments.rc.moduleID=tempID>
		<cfset variables.fw.redirect(action="cSettings.editPlugin",append="moduleid",path="")>
	<cfelse>
		<cfif len(arguments.rc.moduleID)>
			<cfset variables.fw.redirect(action="cSettings.editPlugin",append="moduleid",path="")>
		<cfelse>
			<cfset arguments.rc.activeTab=1>
			<cfset arguments.rc.refresh=1>
			<cfset variables.fw.redirect(action="cSettings.list",append="activeTab,refresh",path="")>
		</cfif>	
	</cfif>
	
</cffunction>

<cffunction name="updatePlugin" output="false">
	<cfargument name="rc">
	<cfset arguments.rc.moduleID=variables.pluginManager.updateSettings(arguments.rc) />
	<cfset arguments.rc.activeTab=1>
	<cfset arguments.rc.refresh=1>
	<cfset variables.fw.redirect(action="cSettings.list",append="activeTab,refresh",path="")>
</cffunction>

<cffunction name="updateSite" output="false">
	<cfargument name="rc">
	<cfset var bean="">
	<cfif arguments.rc.action eq 'Update'>
			<cfset bean=variables.settingsManager.update(arguments.rc)  />
			<cfset variables.clusterManager.reload() />
			<cfif not structIsEmpty(bean.getErrors())>
				<cfset getCurrentUser().setValue("errors",bean.getErrors())>
			</cfif>
	</cfif>
	<cfif arguments.rc.action eq 'Add'>
			<cfset bean=variables.settingsManager.create(arguments.rc)  />
			<cfset variables.settingsManager.setSites()  />
			<cfset variables.clusterManager.reload() />
			<cfset session.userFilesPath = "#application.configBean.getAssetPath()#/#rc.siteid#/assets/">
			<cfset session.siteid=rc.siteid />
			<cfif not structIsEmpty(bean.getErrors())>
				<cfset getCurrentUser().setValue("errors",bean.getErrors())>
			</cfif>
	</cfif>
	<cfif arguments.rc.action eq 'Delete'>
			<cfset variables.settingsManager.delete(arguments.rc.siteid)  />
			<cfset session.siteid="default" />
			<cfset session.userFilesPath = "#application.configBean.getAssetPath()#/default/assets/">
			<cfset arguments.rc.siteid="default"/>
	</cfif>
	<cfset variables.fw.redirect(action="cSettings.list",path="")>
</cffunction>

<cffunction name="sitecopyselect" output="false">
	<cfargument name="rc">
	<cfset arguments.rc.rsSites=variables.settingsManager.getList()>
</cffunction>

<cffunction name="exportHTML" output="false">
	<cfargument name="rc">
	<cfset variables.settingsManager.getSite(arguments.rc.siteID).exportHTML()>
</cffunction>
<cffunction name="sitecopy" output="false">
	<cfargument name="rc">
	<cfif arguments.rc.fromSiteID neq arguments.rc.toSiteID>
		<cfset getBean('publisher').copy(fromSiteID=rc.fromSiteID,toSiteID=rc.toSiteID)>
	</cfif>
	<cfset variables.fw.redirect(action="cSettings.sitecopyresult",append="fromSiteID,toSiteID",path="")>
</cffunction>

<cffunction name="createBundle" output="false">
	<cfargument name="rc">
	<cfparam name="arguments.rc.moduleID" default="">
	<cfparam name="arguments.rc.BundleName" default="">
	<cfparam name="arguments.rc.includeTrash" default="false">
	<cfparam name="arguments.rc.includeVersionHistory" default="false">
	<cfparam name="arguments.rc.includeMetaData" default="false">
	<cfparam name="arguments.rc.includeMailingListMembers" default="false">
	<cfparam name="arguments.rc.includeUsers" default="false">
	<cfparam name="arguments.rc.includeFormData" default="false">
	<cfparam name="arguments.rc.saveFile" default="false">
	<cfparam name="arguments.rc.saveFileDir" default="">
	
	<cfif len(arguments.rc.saveFileDir)>
		<cfif directoryExists(arguments.rc.saveFileDir)>
			<cfset arguments.rc.saveFile=true>
		<cfelse>
			<cfset arguments.rc.saveFileDir="">
			<cfset arguments.rc.saveFile=false>
		</cfif>
	</cfif>
	
	<cfset arguments.rc.bundleFilePath=application.serviceFactory.getBean("Bundle").Bundle(
			siteID=arguments.rc.siteID,
			moduleID=arguments.rc.moduleID,
			BundleName=arguments.rc.BundleName, 
			includeVersionHistory=arguments.rc.includeVersionHistory,
			includeTrash=arguments.rc.includeTrash,
			includeMetaData=arguments.rc.includeMetaData,
			includeMailingListMembers=arguments.rc.includeMailingListMembers,
			includeUsers=arguments.rc.includeUsers,
			includeFormData=arguments.rc.includeFormData,
			saveFile=arguments.rc.saveFile,
			saveFileDir=arguments.rc.saveFileDir
			) />
</cffunction>

<cffunction name="selectBundleOptions" output="false">
	<cfargument name="rc">
	<cfset arguments.rc.rsplugins=application.serviceFactory.getBean("pluginManager").getSitePlugins(arguments.rc.siteID) />
</cffunction>

	<cffunction name="updateSiteFilesToLatestVersion" access="private" output="false" returntype="string">
		<cfargument name="rc" required="true" type="struct" />
		<cfscript>
			var local = StructNew();
			local.str = '';
			if ( not StructKeyExists(rc, 'ckUpdate') ) {
				return local.str;
			};
		</cfscript>
		<cfsavecontent variable="local.str">
			<cfoutput>
				<cfloop list="#rc.ckUpdate#" index="local.i" delimiters=",">
					<cftry>
						<cfscript>
							local.updated = application.autoUpdater.update(local.i);
							local.files = local.updated.files;
						</cfscript>
						<div class="success">
							<dl>
								<dt>#local.i#</dt>
								<dd>Updated to version #application.autoUpdater.getCurrentCompleteVersion(local.i)#</dd>
								<dd>Updated Files (#ArrayLen(local.files)#)</dd>
								<!---<cfif ArrayLen(local.files)>
									<dd>
										<cfloop from="1" to="#ArrayLen(local.files)#" index="local.f"> 
											#local.files[local.f]#<br />
										</cfloop>
									</dd>
								</cfif>--->					
							</dl>
						</div>
						<cfcatch>
							<div class="error">
								<h3>An error occurred while trying to update #local.i#</h3>
								<cfif len(trim(cfcatch.message))>
									<p><strong>Error Message</strong><br />#cfcatch.message#</p>
								</cfif>
								<cfif len(trim(cfcatch.detail))>
									<p><strong>Error Detail</strong><br />#cfcatch.detail#</p>
								</cfif>
							</div>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.str />
	</cffunction>

</cfcomponent>