<cfsilent>
<cfsavecontent variable="headFormBuilder">
<cfoutput>
<script src="#application.configBean.getContext()#/admin/assets/js/jquery/jquery.jsonform.js" type="text/javascript" language="Javascript"></script>
<script src="#application.configBean.getContext()#/admin/assets/js/templatebuilder/jquery.templatebuilder.0.3.js" type="text/javascript" language="Javascript"></script>
<script src="#application.configBean.getContext()#/admin/assets/js/minigrid/jquery-ui-minigrid-0.7.js" type="text/javascript" language="Javascript"></script>
</cfoutput>
</cfsavecontent>
</cfsilent>
<cfhtmlhead text="#headFormBuilder#" >