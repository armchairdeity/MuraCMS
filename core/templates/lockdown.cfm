<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><cfoutput>#REReplace(application.settingsManager.getSite(request.siteID).getEnableLockdown(), "([a-z]{1})", "\U\1", "ONE" )# Mode</cfoutput></title>

<style type="text/css">

body {
	background: #f1f1f1;
	font-family: "Helvetica", "Arial", sans-serif;
	color: #343434;
	margin: 0; padding: 0;
}

#wrapper {
	width: 300px;
	margin: 100px auto;
	background: #FCFCFC;
	padding: 25px;
	border: 1px solid #ccc;
	-moz-border-radius: 5px; -webkit-border-radius: 5px; border-radius: 5px;
}

.alert {
	font-weight: bold;
    text-align: center;
}

form label {
	display: block;
	width: 100%;
	font-size: 14px;
}

form input.text {
	font-size: 12px;
	width: 288px;
	margin: 5px 0 25px;
	padding: 6px;
	border: 1px solid #ccc;
	-moz-border-radius: 3px; -webkit-border-radius: 3px; border-radius: 3px;
	transition: border 100ms linear;
	-moz-transition: border 100ms linear; /* Firefox 4 */
	-webkit-transition: border 100ms linear; /* Safari and Chrome */
	-o-transition: border 100ms linear; /* Opera */

}

form input.text:focus {
	outline: 0;
	border: 1px solid #959595;
}

form select {
	font-size: 12px;
	margin: 5px 0 25px;
	padding: 6px;
	border: 1px solid #ccc;
	-moz-border-radius: 3px; -webkit-border-radius: 3px; border-radius: 3px;
	transition: border 100ms linear;
	-moz-transition: border 100ms linear; /* Firefox 4 */
	-webkit-transition: border 100ms linear; /* Safari and Chrome */
	-o-transition: border 100ms linear; /* Opera */

}

form select {
	outline: 0;
	border: 1px solid #959595;
}

form input.submit {
	background: #444;
	color: #fff;
	text-shadow: 0 -1px 0 #000;
	text-transform: uppercase;
	font-size: 12px;
	font-weight: normal;
	padding: 7px 14px;
	border: 0;
	cursor: pointer;
	-moz-border-radius: 3px; -webkit-border-radius: 3px; border-radius: 3px;
	transition: background 100ms linear;
	-moz-transition: background 100ms linear; /* Firefox 4 */
	-webkit-transition: background 100ms linear; /* Safari and Chrome */
	-o-transition: background 100ms linear; /* Opera */

}

form input.submit:hover {
	background: #666;
}

form p#submitWrap {
	text-align: right;
	margin: 0; padding: 0;
}

form p#error {
	color: #A70001;
	padding: 5px 10px;
	font-size: 12px;
	margin: 0;
	float: left;
}

</style>
</head>
<body>
	<div id="wrapper">
		<cfif application.settingsManager.getSite(request.siteID).getEnableLockdown() eq "maintenance">
			<div class="alert"><cfoutput>#application.settingsManager.getSite(request.siteID).getSite()#</cfoutput> is currently undergoing maintenance.</div>
		<cfelseif application.settingsManager.getSite(request.siteID).getEnableLockdown() eq "development">
			<form method="post" action="<cfif application.configBean.getLockdownHTTPS() eq true><cfoutput>#replacenocase(arguments.$.getContentRenderer().createHREF(siteid = request.siteid, filename = arguments.event.getScope().currentfilename, complete = true), "http:", "https:")#</cfoutput></cfif>">

				<cfoutput>
					<!--- Use Google oAuth Button --->
					<cfif listFindNoCase($.globalConfig().getEnableOauth(), 'google')>
						<div style="padding-bottom: 5px">
							<a href="#$.getBean('googleLoginProvider').generateAuthUrl(session.urltoken)#" title="#$.rbKey('login.loginwithgoogle')#">
		                      <img src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/images/btn_google_signin_light_normal_web@2x.png" class="mura-login-auth-img-google">
							</a>
						</div>
					</cfif>
					<!--- Use Facebook oAuth Button --->
					<cfif listFindNoCase($.globalConfig().getEnableOauth(), 'facebook')>
						<div style="padding-bottom: 5px">
							<a href="#$.getBean('facebookLoginProvider').generateAuthUrl(session.urltoken)#" title="#$.rbKey('login.loginwithfacebook')#">
						       <img src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/images/btn_facebook_continue@2x.png" class="mura-login-auth-img-facebook">
							</a>
						</div>
					</cfif>

					<cfif listFindNoCase($.globalConfig().getEnableOauth(), 'google') or listFindNoCase($.globalConfig().getEnableOauth(), 'facebook') >
						<h3>#$.rbKey('login.loginwithcredentials')#</h3>
					</cfif>
				</cfoutput>


				<label for="locku">Username</label>
				<input type="text" name="locku" id="locku" class="text" />

				<label for="lockp">Password</label>
				<input type="password" name="lockp" id="lockp" class="text" />

				<label for="expires">Log me in for:</label>
				<select name="expires">
					<option value="session">Session</option>
					<option value="1">One Day</option>
					<option value="7">One Week</option>
					<option value="30">One Month</option>
					<option value="10950">Forever</option>
				</select>

				<input type="hidden" name="locks" value="true" />
				<cfif len(event.getValue('locks'))>
					<p id="error">Login failed!</p>
				</cfif>
				<p id="submitWrap"><input type="submit" name="submit" value="Login" class="submit" /></p>
			</form>
		</cfif>
	</div>
</body>
</html>
<cfabort>
