<cfif thisTag.ExecutionMode eq 'start'>
	<cfsilent>
		<cfscript>
			if(server.coldfusion.productname != 'ColdFusion Server'){
				backportdir='';
				include "/mura/backport/backport.cfm";
			} else {
				backportdir='/mura/backport/';
				include "#backportdir#backport.cfm";
			}
		</cfscript>

		<cfset $=application.serviceFactory.getBean("muraScope").init(session.siteid)>

		<cfif not isdefined('attributes.params')>
			<cfif isDefined("form.params") and isJSON(form.params)>
				<cfset attributes.params=deserializeJSON(form.params)>
			<cfelse>
				<cfset attributes.params={}>
			</cfif>
		</cfif>

		<cfparam name="attributes.configurable" default="true">
	 	<cfparam name="attributes.basictab" default="true">
		<cfparam name="attributes.params.class" default="">
		<cfparam name="attributes.params.cssclass" default="">
		<cfparam name="attributes.params.metacssclass" default="">
		<cfparam name="attributes.params.metacssid" default="">
		<cfparam name="attributes.params.contentcssclass" default="">
		<cfparam name="attributes.params.contentcssid" default="">
		<cfparam name="attributes.params.cssid" default="">
		<cfparam name="attributes.params.label" default="">
		<cfparam name="attributes.params.object" default="">

		<cfparam name="request.hasbasicoptions" default="false">
		<cfparam name="request.hasmetaoptions" default="false">
		<cfparam name="request.haspositionoptions" default="false">
		<cfparam name="attributes.params.isbodyobject" default="false">

		<cfparam name="request.colorOptions" default="">
		<cfif structKeyExists($.getContentRenderer(),'coloroptions')>
			<cfset request.colorOptions = $.getContentRenderer().coloroptions>
		<cfelseif structKeyExists($.getContentRenderer(),'colorArray')>
			<cfset request.colorOptions = $.getContentRenderer().colorArray>
		</cfif>

		<cfparam name="request.modulethemeoptions" default="#arrayNew(1)#">
		<cfif structKeyExists($.getContentRenderer(),'modulethemeoptions') and isArray($.getContentRenderer().modulethemeoptions)>
			<cfset request.modulethemeoptions = $.getContentRenderer().modulethemeoptions>
		<cfelseif structKeyExists($.getContentRenderer(),'modulethemeArray') and isArray($.getContentRenderer().modulethemeArray)>
			<cfset request.modulethemeoptions = $.getContentRenderer().modulethemeArray>
		</cfif>

		<cfset contentcontainerclass=esapiEncode("javascript",$.getContentRenderer().expandedContentContainerClass)>

		<cfif not (isDefined("attributes.params.stylesupport.objectstyles") and isStruct(attributes.params.stylesupport.objectstyles))>
			<cfif isDefined("attributes.params.stylesupport.objectstyles") and isJSON(attributes.params.stylesupport.objectstyles)>
				<cfset attributes.params.stylesupport.objectstyles=deserializeJSON(attributes.params.stylesupport.objectstyles)>
			<cfelse>
				<cfset attributes.params.stylesupport.objectstyles={}>
			</cfif>
		</cfif>

		<cfif not (isDefined("attributes.params.stylesupport.metastyles") and isStruct(attributes.params.stylesupport.metastyles))>
			<cfif isDefined("attributes.params.stylesupport.metastyles") and isJSON(attributes.params.stylesupport.metastyles)>
				<cfset attributes.params.stylesupport.metastyles=deserializeJSON(attributes.params.stylesupport.metastyles)>
			<cfelse>
				<cfset attributes.params.stylesupport.metastyles={}>
			</cfif>
		</cfif>
		<cfif not (isDefined("attributes.params.stylesupport.contentstyles") and isStruct(attributes.params.stylesupport.contentstyles))>
			<cfif isDefined("objectParams.contentcssstyles") and isJSON(attributes.params.stylesupport.contentstyles)>
				<cfset attributes.params.stylesupport.contentstyles=deserializeJSON(attributes.params.stylesupport.contentstyles)>
			<cfelse>
				<cfset attributes.params.stylesupport.contentstyles={}>
			</cfif>
		</cfif>

		<cfif not request.hasbasicoptions>
		<cfset request.hasbasicoptions=attributes.basictab>
		</cfif>

		<cfif not listFindNoCase('folder,gallery,calendar',attributes.params.object) and not (isBoolean(attributes.params.isbodyobject) and attributes.params.isbodyobject)>
			<cfset request.haspositionoptions = true>
		</cfif>

		<cfscript>
			attributes.positionoptions = [
					{value='',label='Auto'}
					,{value='mura-one', label='1/12',percent='8.33%'}
					,{value='mura-two', label='1/6',percent='16.66%'}
					,{value='mura-three', label='1/4',percent='25%'}
					,{value='mura-four', label='1/3',percent='33.33%'}
					,{value='mura-five', label='5/12',percent='41.66%'}
					,{value='mura-six', label='1/2',percent='50%'}
					,{value='mura-seven', label='7/12',percent='58.33%'}
					,{value='mura-eight', label='2/3',percent='66.66%'}
					,{value='mura-nine', label='3/4',percent='75%'}
					,{value='mura-ten', label='5/6',percent='41.66%'}
					,{value='mura-eleven', label='11/12',percent='91.66%'}
					,{value='mura-twelve', label='Full',percent='100%'}
					,{value='mura-expanded', label='Expanded',percent='100%'}
				];
		</cfscript>

	</cfsilent>

	<cfif $.getContentRenderer().useLayoutManager()>
		<cfoutput>
		<cfset request.muraconfiguratortag=true>
		<div id="availableObjectContainer"<cfif not attributes.configurable> style="display:none"</cfif>>
			<div class="mura-panel-group" id="configurator-panels" role="tablist" aria-multiselectable="true">
			<!--- Basic panel --->
			<cfif request.hasbasicoptions>
			<div class="mura-panel panel">
				<div class="mura-panel-heading" role="tab" id="heading-basic">
					<h4 class="mura-panel-title">
						<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-basic" aria-expanded="true" aria-controls="panel-basic">
							<i class="mi-sliders"></i>Settings <!--- #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.basic')# --->
						</a>
					</h4>
				</div>
				<div id="panel-basic" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-basic">
					<div class="mura-panel-body">
			</cfif>
		</cfoutput>
	</cfif>
<!--- /end start mode --->
<cfelseif thisTag.ExecutionMode eq 'end'>
	<cfset $=application.serviceFactory.getBean("muraScope").init(session.siteid)>

	<cfif $.getContentRenderer().useLayoutManager()>

	<cfoutput>

		<!--- close the basic or style panel --->
		<cfif request.hasbasicoptions or request.hasmetaoptions and not (IsBoolean(attributes.params.isbodyobject) and attributes.params.isbodyobject)>
				</div> <!--- /end  mura-panel-collapse --->
			</div> <!--- /end  mura-panel-body --->
		</div> <!--- /end panel --->
		</cfif>

		<!--- style --->
		<div class="mura-panel panel">
			<div class="mura-panel-heading" role="tab" id="heading-style">
				<h4 class="mura-panel-title">
					<!--- todo: rbkey for style --->
					<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-style" aria-expanded="false" aria-controls="panel-style">
						<i class="mi-tint"></i>Style
					</a>
				</h4>
			</div>
			<div id="panel-style" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-style">
				<div class="mura-panel-body">
					<div class="container">
						<!--- nested panels --->
						<cfinclude template="objectconfigpanels/stylepanels.cfm">
					</div> <!--- /end container --->
				</div> <!--- /end  mura-panel-body --->
			</div> <!--- /end  mura-panel-collapse --->
		</div> <!--- /end style panel --->
	</div><!--- /end panels --->
	</cfoutput>
</div> <!--- /end availableObjectContainer --->

	<script>
		$(function(){

			currentPanel="";
			re="[^0-9\\-\\.]";
			numRE = new RegExp(re,"g")
			window.configuratorInited=false;

			$('#panel-gds-object,.mura-panel-heading').click(function(){
				if(!$(this).is('.panel-content, .panel-meta')){
					currentPanel="";
					frontEndProxy.post(
					{
						cmd:'setCurrentPanel',
						instanceid:instanceid,
						currentPanel:currentPanel
					});
				}
			});

			$('#panel-gds-content, .panel-content').click(function(){
				currentPanel="content";
				frontEndProxy.post(
				{
					cmd:'setCurrentPanel',
					instanceid:instanceid,
					currentPanel:currentPanel
				});
			});

			$('#panel-gds-meta,.panel-meta').click(function(){
				currentPanel="meta";
				frontEndProxy.post(
				{
					cmd:'setCurrentPanel',
					instanceid:instanceid,
					currentPanel:currentPanel
				});
			});

			$('.mura-panel-heading, .panel-gds-box').on('click',function(){
				setConfigPanelStates();
			})

			$('.panel-gds-box').on('click',function(){
				var gdspanel = $(this).attr('data-gdsel');
				var gdstarget = $('#' + gdspanel);
				$('.panel-gds-box').removeClass('active');
				$(this).addClass('active');
				$('#style-panels > .mura-panel > .panel-collapse.in').removeClass('in');
				$(gdstarget).addClass('in');
				return false;
			})

			function setActiveGDSpanel(){
				var visiblekids = $('#style-panels > .mura-panel > .panel-collapse.in');
				if (!visiblekids.length){
					$('#panel-gds-object').trigger('click');
				} else {
					$('.panel-gds-box[data-gdsel="' + visiblekids[0].id + '"]').trigger('click');
				}				
			}

			// set panel state cookie
			function setConfigPanelStates(){
				var savedStates = JSON.parse(getConfigPanelStates());
				var newStates = [];

				for (i in savedStates){
					if (newStates.length <= 10){					
						var item = savedStates[i];
						if (item[0] != instanceid){
							newStates.push(item);
						}
					}
				}

				setTimeout(function(){
				 	var openPanels = $('#configurator-panels').find('.panel-collapse.in').map(function(){
				 			return this.id;
				 	}).get();
				 	var thisArr = [instanceid,openPanels];
				 	newStates.unshift(thisArr);
				 	var str = JSON.stringify(newStates);
				 	Mura.createCookie('mura_configpanelstate',encodeURIComponent(str));
				
				},500);
			}

			// get panel state cookie
			function getConfigPanelStates(){
					var cps = Mura.readCookie('mura_configpanelstate');
					if (cps == ''){
						return JSON.stringify([]);
					} else {
						return cps;
					}
			}	

			// apply open panels
			function applyConfigPanelStates(){
					var cps = JSON.parse(getConfigPanelStates());

					for (i in cps){
						var savedinstanceid = cps[i][0];
						var panelarr = cps[i][1];
						if (panelarr.length && savedinstanceid == instanceid){
							$('#configurator-panels').find('.panel-collapse.in').removeClass('in');
							$('#configurator-panels').find('.mura-panel-title a.collapse').addClass('collapsed');
							for (i in panelarr){
								$('#'+ panelarr[i]).addClass('in').siblings('.mura-panel-heading').find('a.collapse').removeClass('collapsed');
							}
						}
					}
			}

			// run on load
			$('#style-panels').addClass('no-header');
			$('#panel-style-object').addClass('in');
			applyConfigPanelStates();
			setActiveGDSpanel();

			$('#labelText').change(function(item){
				if(Mura.trim(Mura(this).val())){
					Mura('#panel-gds-meta').show();
				} else {
					Mura('#panel-gds-meta').hide();
					$('#panel-style-label').removeClass('in');
					$('#panel-style-object').addClass('in');
					$('#panel-gds-object').addClass('active');
				}
			});

			function updateDynamicClasses(){
				var classInput=$('input[name="class"]');
				classInput.val('');

				$('.classtoggle,.classToggle').each(function(){
					var input=$(this);
					if(classInput.val() ){
						classInput.val(classInput.val() + ' ' + input.val());
					} else {
						classInput.val(input.val());
					}
				})

				classInput.val($.trim(classInput.val()));

	  		var contentcssclass=$('input[name="contentcssclass"]');
				var expandedContentContainerClass='<cfoutput>#contentcontainerclass#</cfoutput>';
				var contentcssclassArray=[];
				if(typeof contentcssclass.val() =='string'){
					contentcssclassArray=contentcssclass.val().split(' ');
				}
				var constraincontent=$('select[name="constraincontent"]');

				if(constraincontent.length){
					if($('select[name="width"].classtoggle').val()=='mura-expanded'){
						$('.constraincontentcontainer').show();
						if(constraincontent.val()=='constrain'){
							if(contentcssclassArray.indexOf(expandedContentContainerClass)==-1){
								if(contentcssclassArray.length){
									contentcssclass.val(contentcssclass.val() + ' ' + expandedContentContainerClass);
								} else {
									contentcssclass.val(expandedContentContainerClass);
								}
							}
						} else {
							if(contentcssclassArray.indexOf(expandedContentContainerClass) > -1){
								for( var i = 0; i < contentcssclassArray.length; i++){
									if ( contentcssclassArray[i] === expandedContentContainerClass) {
										contentcssclassArray.splice(i, 1);
									}
								}
							}
							contentcssclass.val(contentcssclassArray.join(' '));
						}
					} else {
						$('.constraincontentcontainer').hide();
						if(contentcssclassArray.indexOf(expandedContentContainerClass) > -1){
							for( var i = 0; i < contentcssclassArray.length; i++){
								if ( contentcssclassArray[i] === expandedContentContainerClass) {
									contentcssclassArray.splice(i, 1);
								}
							}
						}
						contentcssclass.val(contentcssclassArray.join(' '));
					}
					contentcssclass.val($.trim(contentcssclass.val()));
				}
				if(typeof updateDraft == 'function'){
					updateDraft();
				}
			}

			updateDynamicClasses();

			$('#globalSettingsBtn').click(function(){
				$('#availableObjectContainer').hide();
				$('#objectSettingsBtn').show();
				$('#globalObjectParams').fadeIn();
				$('#globalSettingsBtn').hide();
			});

			$('#objectSettingsBtn').click(function(){
				$('#availableObjectContainer').fadeIn();
				$('#objectSettingsBtn').hide();
				$('#globalObjectParams').hide();
				$('#globalSettingsBtn').show();
			});

			$('.mura-ui-link').on('click',function(){
				var targetEl = $(this).attr('data-reveal');
				if (targetEl.length > 0){
					$('#' + targetEl).toggle();
				}
				return false;
			})

			$('.classtoggle,.classToggle').on('change', function() {
				updateDynamicClasses();
			});

			// Begin Object Margin and Padding
			function updateObjectPadding(){
				var t = $('#objectpaddingtop').val().replace(numRE,'');
				var r = $('#objectpaddingright').val().replace(numRE,'');
				var b = $('#objectpaddingbottom').val().replace(numRE,'');
				var l =$('#objectpaddingleft').val().replace(numRE,'');
				var u = $('#objectpaddinguom').val();
				if (t.length){ $('#objectpaddingtopval').val(t + u); } else { $('#objectpaddingtopval').val(''); }
				if (r.length){ $('#objectpaddingrightval').val(r + u); } else { $('#objectpaddingrightval').val(''); }
				if (b.length){ $('#objectpaddingbottomval').val(b + u); } else { $('#objectpaddingbottomval').val(''); }
				if (l.length){ $('#objectpaddingleftval').val(l + u); } else { $('#objectpaddingleftval').val(''); }
				if (t == r && r == b && b == l){
					$('#objectpaddingall').val(t);
				} else {
					$('#objectpaddingall').val('');
					$('#objectpaddingadvanced').show();
				}
				$('#objectpaddingtopval').trigger('change');
			}

			$('#objectpaddingall').on('keyup', function(){
				var v = $('#objectpaddingall').val().replace(numRE,'');
				$('#objectpaddingadvanced').hide();
				$('#objectpaddingtop').val(v);
				$('#objectpaddingleft').val(v);
				$('#objectpaddingright').val(v);
				$('#objectpaddingbottom').val(v);
			})

			$('#objectpaddingtop,#objectpaddingright,#objectpaddingbottom,#objectpaddingleft,#objectpaddingall').on('keyup', function(){
				updateObjectPadding();
			})

			$('#objectpaddinguom').on('change',function(){
				updateObjectPadding();
			});

			updateObjectPadding();

			// margin
			function updateObjectMargin(){
				var t = $('#objectmargintop').val().replace(numRE,'');
				var r = $('#objectmarginright').val();
				if(r != 'auto'){r=r.replace(numRE,'')}
				var b = $('#objectmarginbottom').val().replace(numRE,'');
				var l =$('#objectmarginleft').val();
				if(l != 'auto'){l=l.replace(numRE,'')}
				var u = $('#objectmarginuom').val();
				if (t.length){ $('#objectmargintopval').val(t + u); } else { $('#objectmargintopval').val(''); }
				if(r=='auto'){
					$('#objectmarginrightval').val(r);
				} else {
					if (r.length){ $('#objectmarginrightval').val(r + u); } else { $('#objectmarginrightval').val(''); }
				}
				if (b.length){ $('#objectmarginbottomval').val(b + u); } else { $('#objectmarginbottomval').val(''); }
				if(l=='auto'){
					$('#objectmarginleftval').val(r);
				} else {
					if (l.length){ $('#objectmarginleftval').val(l + u); } else { $('#objectmarginleftval').val(''); }
				}
				if (t == r && r == b && b == l){
					$('#objectmarginall').val(t);
				} else {
					$('#objectmarginall').val('');
					$('#objectmarginadvanced').show();
				}
				$('#objectmargintopval').trigger('change');
			}

			$('#objectmarginall').on('keyup', function(){
				var v = $('#objectmarginall').val().replace(numRE,'');
				$('#objectmarginadvanced').hide();
				$('#objectmargintop').val(v);
				$('#objectmarginleft').val(v);
				$('#objectmarginright').val(v);
				$('#objectmarginbottom').val(v);
			})

			$('a.input-auto').on('click',function(){
				var ai = '#' + $(this).attr('data-auto-input');
				$(ai).val('auto').trigger('keyup');
				return false;
			})

			$('#objectmargintop,#objectmarginright,#objectmarginbottom,#objectmarginleft,#objectmarginall').on('keyup', function(){
				var val=$(this).val();
				if(!(val=='a' || val=='au' || val=='aut')){
					updateObjectMargin();
				}
			});

			$('#objectmarginuom').on('change',function(){
				updateObjectMargin();
			});

			updateObjectMargin();
			//End Object Margin and Padding

			// Begin Meta Margin and Padding
			<cfif request.hasmetaoptions and not (IsBoolean(attributes.params.isbodyobject) and attributes.params.isbodyobject)>
			function updateMetaPadding(){
				var t = $('#metapaddingtop').val().replace(numRE,'');
				var r = $('#metapaddingright').val().replace(numRE,'');
				var b = $('#metapaddingbottom').val().replace(numRE,'');
				var l =$('#metapaddingleft').val().replace(numRE,'');
				var u = $('#metapaddinguom').val();
				if (t.length){ $('#metapaddingtopval').val(t + u); } else { $('#metapaddingtopval').val(''); }
				if (r.length){ $('#metapaddingrightval').val(r + u); } else { $('#metapaddingrightval').val(''); }
				if (b.length){ $('#metapaddingbottomval').val(b + u); } else { $('#metapaddingbottomval').val(''); }
				if (l.length){ $('#metapaddingleftval').val(l + u); } else { $('#metapaddingleftval').val(''); }
				if (t == r && r == b && b == l){
					$('#metapaddingall').val(t);
				} else {
					$('#metapaddingall').val('');
					$('#metapaddingadvanced').show();
				}
				$('#metapaddingtopval').trigger('change');
			}

			$('#metapaddingall').on('keyup', function(){
				var v = $('#metapaddingall').val().replace(numRE,'');
				$('#metapaddingadvanced').hide();
				$('#metapaddingtop').val(v);
				$('#metapaddingleft').val(v);
				$('#metapaddingright').val(v);
				$('#metapaddingbottom').val(v);
			})

			$('#metapaddingtop,#metapaddingright,#metapaddingbottom,#metapaddingleft,#metapaddingall').on('keyup', function(){
				updateMetaPadding();
			})

			$('#metapaddinguom').on('change',function(){
				updateMetaPadding();
			});

			updateMetaPadding();

			// margin
			function updateMetaMargin(){
				var t = $('#metamargintop').val().replace(numRE,'');
				var r = $('#metamarginright').val();
				if(r != 'auto'){r=r.replace(numRE,'')}
				var b = $('#metamarginbottom').val().replace(numRE,'');
				var l =$('#metamarginleft').val();
				if(l != 'auto'){l=l.replace(numRE,'')}
				var u = $('#metamarginuom').val();
				if (t.length){ $('#metamargintopval').val(t + u); } else { $('#metamargintopval').val(''); }
				if(r=='auto'){
					$('#metamarginrightval').val(r);
				} else {
					if (r.length){ $('#metamarginrightval').val(r + u); } else { $('#metamarginrightval').val(''); }
				}
				if (b.length){ $('#metamarginbottomval').val(b + u); } else { $('#metamarginbottomval').val(''); }
				if(l=='auto'){
					$('#metamarginleftval').val(r);
				} else {
					if (l.length){ $('#metamarginleftval').val(l + u); } else { $('#metamarginleftval').val(''); }
				}
				if (t == r && r == b && b == l){
					$('#metamarginall').val(t);
				} else {
					$('#metamarginall').val('');
					$('#metamarginadvanced').show();
				}
				$('#metamargintopval').trigger('change');
			}

			$('#metamarginall').on('keyup', function(){
				var v = $('#metamarginall').val().replace(numRE,'');
				$('#metamarginadvanced').hide();
				$('#metamargintop').val(v);
				$('#metamarginleft').val(v);
				$('#metamarginright').val(v);
				$('#metamarginbottom').val(v);
			})

			$('#metamargintop,#metamarginright,#metamarginbottom,#metamarginleft,#metamarginall').on('keyup', function(){
				var val=$(this).val();
				if(!(val=='a' || val=='au' || val=='aut')){
					updateMetaMargin();
				}
			});

			$('#metamarginuom').on('change',function(){
				updateMetaMargin();
			});

			updateMetaMargin();
			</cfif>
			// End Meta Margin and Padding

			// Begin Content Content Margin and Padding
			function updateContentPadding(){
				var t = $('#contentpaddingtop').val().replace(numRE,'');
				var r = $('#contentpaddingright').val().replace(numRE,'');
				var b = $('#contentpaddingbottom').val().replace(numRE,'');
				var l =$('#contentpaddingleft').val().replace(numRE,'');
				var u = $('#contentpaddinguom').val();
				if (t.length){ $('#contentpaddingtopval').val(t + u); } else { $('#contentpaddingtopval').val(''); }
				if (r.length){ $('#contentpaddingrightval').val(r + u); } else { $('#contentpaddingrightval').val(''); }
				if (b.length){ $('#contentpaddingbottomval').val(b + u); } else { $('#contentpaddingbottomval').val(''); }
				if (l.length){ $('#contentpaddingleftval').val(l + u); } else { $('#contentpaddingleftval').val(''); }
				if (t == r && r == b && b == l){
					$('#contentpaddingall').val(t);
				} else {
					$('#contentpaddingall').val('');
					$('#contentpaddingadvanced').show();
				}
				$('#contentpaddingtopval').trigger('change');
			}

			$('#contentpaddingall').on('keyup', function(){
				var v = $('#contentpaddingall').val().replace(numRE,'');
				$('#contentpaddingadvanced').hide();
				$('#contentpaddingtop').val(v);
				$('#contentpaddingleft').val(v);
				$('#contentpaddingright').val(v);
				$('#contentpaddingbottom').val(v);
			})

			$('#contentpaddingtop,#contentpaddingright,#contentpaddingbottom,#contentpaddingleft,#contentpaddingall').on('keyup', function(){
				updateContentPadding();
			})

			$('#contentpaddinguom').on('change',function(){
				updateContentPadding();
			});

			updateContentPadding();

 			// margin
			function updateContentMargin(){
				var t = $('#contentmargintop').val().replace(numRE,'');
				var r = $('#contentmarginright').val();
				if(r != 'auto'){r=r.replace(numRE,'')}
				var b = $('#contentmarginbottom').val().replace(numRE,'');
				var l =$('#contentmarginleft').val();
				if(l != 'auto'){l=l.replace(numRE,'')}
				var u = $('#contentmarginuom').val();
				if (t.length){ $('#contentmargintopval').val(t + u); } else { $('#contentmargintopval').val(''); }
				if(r=='auto'){
					$('#contentmarginrightval').val(r);
				} else {
					if (r.length){ $('#contentmarginrightval').val(r + u); } else { $('#contentmarginrightval').val(''); }
				}
				if (b.length){ $('#contentmarginbottomval').val(b + u); } else { $('#contentmarginbottomval').val(''); }
				if(l=='auto'){
					$('#contentmarginleftval').val(r);
				} else {
					if (l.length){ $('#contentmarginleftval').val(l + u); } else { $('#contentmarginleftval').val(''); }
				}
				if (t == r && r == b && b == l){
					$('#contentmarginall').val(t);
				} else {
					$('#contentmarginall').val('');
					$('#contentmarginadvanced').show();
				}
				$('#contentmargintopval').trigger('change');
			}

			$('#contentmarginall').on('keyup', function(){
				var v = $('#contentmarginall').val().replace(numRE,'');
				$('#contentmarginadvanced').hide();
				$('#contentmargintop').val(v);
				$('#contentmarginleft').val(v);
				$('#contentmarginright').val(v);
				$('#contentmarginbottom').val(v);
			})

			$('#contentmargintop,#contentmarginright,#contentmarginbottom,#contentmarginleft,#contentmarginall').on('keyup', function(){
				updateContentMargin();
			});

			$('#contentmarginuom').on('change',function(){
				var val=$(this).val();
				if(!(val=='a' || val=='au' || val=='aut')){
					updateContentMargin();
				}
			});

			updateContentMargin();
			// End Content Content Margin and Padding

			// Begin Object background
			$('#objectminheightnum,#objectminheightoum').on('change',function(){
				var el = $('#objectminheightuomval');
				var str = $('#objectminheightuom').val();
				var num = $('#objectminheightnum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#contentminheightnum,#contentminheightoum').on('change',function(){
				var el = $('#contentminheightuomval');
				var str = $('#contentminheightuom').val();
				var num = $('#contentminheightnum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			// background position x/y
			function updatePositionSelection(sel){
				var v = $(sel).val();
				var el = $(sel).attr('data-numfield');
				if (v == 'px' || v == '%'){
					$('#' + el).show();
				} else {
					$('#' + el).hide();
				}
			}

			// background image
			$('#objectbackgroundimageurl').on('change',function(){
				var v = $(this).val();
				var str = "";
				if (typeof v !='undefined' && v.length > 3){
					str = "url('" + v + "')";
					$('.object-css-bg-option').show();
				} else {
					$('.object-css-bg-option').hide();
				}
				$('#objectbackgroundimage').val(str).trigger('change');
			});

			var v = $('#objectbackgroundimageurl').val();
			var str = "";
			if (typeof v !='undefined' && v.length > 3){
				str = "url('" + v + "')";
				$('.object-css-bg-option').show();
			} else {
				$('.object-css-bg-option').hide();
			}

			//$('#objectbackgroundimageurl').trigger('change');

			$('#objectbackgroundpositiony,#objectbackgroundpositionynum').on('change',function(){
				var el = $('#objectbackgroundpositionyval');
				var str = $('#objectbackgroundpositiony').val();
				var num = $('#objectbackgroundpositionynum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#objectbackgroundpositionx,#objectbackgroundpositionxnum').on('change',function(){
				var el = $('#objectbackgroundpositionxval');
				var str = $('#objectbackgroundpositionx').val();
				var num = $('#objectbackgroundpositionxnum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#objectbackgroundpositionx,#objectbackgroundpositiony').on('change',function(){
				updatePositionSelection($(this));
			});

			$('#objectbackgroundpositionx,#objectbackgroundpositiony').each(function(){
				updatePositionSelection($(this));
			});
			//End Object Background

			// background image
			$('#metabackgroundimageurl').on('change',function(){
				var v = $(this).val();
				var str = "";
				if (typeof v != 'undefined' && v.length > 3){
					str = "url('" + v + "')";
					$('.meta-css-bg-option').show();
				} else {
					$('.meta-css-bg-option').hide();
				}
				$('#metabackgroundimage').val(str).trigger('change');
			});

			var v = $('#metabackgroundimageurl').val();
			var str = "";
			if (typeof v != 'undefined' && v.length > 3){
				str = "url('" + v + "')";
				$('.meta-css-bg-option').show();
			} else {
				$('.meta-css-bg-option').hide();
			}

			$('#metabackgroundpositiony,#metabackgroundpositionynum').on('change',function(){
				var el = $('#metabackgroundpositionyval');
				var str = $('#metabackgroundpositiony').val();
				var num = $('#metabackgroundpositionynum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#metabackgroundpositionx,#metabackgroundpositionxnum').on('change',function(){
				var el = $('#metabackgroundpositionxval');
				var str = $('#metabackgroundpositionx').val();
				var num = $('#metabackgroundpositionxnum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#metabackgroundpositionx,#metabackgroundpositiony').on('change',function(){
				updatePositionSelection($(this));
			});

			$('#metabackgroundpositionx,#metabackgroundpositiony').each(function(){
				updatePositionSelection($(this));
			});
			//End Meta Background

			// background image
			$('#contentbackgroundimageurl').on('change',function(){
				var v = $(this).val();
				var str = "";
				if (typeof v !='undefined' && v.length > 3){
					str = "url('" + v + "')";
					$('.content-css-bg-option').show();
				} else {
					$('.content-css-bg-option').hide();
				}
				$('#contentbackgroundimage').val(str).trigger('change');
			});

			var v = $('#contentbackgroundimageurl').val();
			var str = "";
			if (typeof v !='undefined' && v.length > 3){
				str = "url('" + v + "')";
				$('.content-css-bg-option').show();
			} else {
				$('.content-css-bg-option').hide();
			}

			$('#contentbackgroundpositiony,#contentbackgroundpositionynum').on('change',function(){
				var el = $('#contentbackgroundpositionyval');
				var str = $('#contentbackgroundpositiony').val();
				var num = $('#contentbackgroundpositionynum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#contentbackgroundpositionx,#contentbackgroundpositionxnum').on('change',function(){
				var el = $('#contentbackgroundpositionxval');
				var str = $('#contentbackgroundpositionx').val();
				var num = $('#contentbackgroundpositionxnum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			$('#contentbackgroundpositionx,#contentbackgroundpositiony').on('change',function(){
				updatePositionSelection($(this));
			});

			$('#contentbackgroundpositionx,#contentbackgroundpositiony').each(function(){
				updatePositionSelection($(this));
			});
			//End Object Background

			$('#contentwidthnum,#contentwidthuom').on('change',function(){
				var el = $('#contentwidthuomval');
				var str = $('#contentwidthuom').val();
				var num = $('#contentwidthnum').val();
				if (num.length > 0){
					str = num + str;
				}
				$(el).val(str).trigger('change');
			});

			// numeric input - select on focus
			$('#configuratorContainer input.numeric').on('click', function(){
				$(this).select();
			});

			// numeric input - restrict value
			$('#configuratorContainer input.numeric').on('keyup', function(){
				var v = $(this).val();
				var n = $(this).attr('name').toLowerCase();
				if (n == 'contentmarginleft' || n == 'contentmarginright' || n == 'metamarginleft' || n == 'metamarginright'){
					if (v == 'a'){
						v = 'auto';
					}
					if(!(v=='a' || v=='au' || v=='aut'|| v=='auto')){
						v=v.replace(numRE,'');
					}
				} else {
					v=v.replace(numRE,'');
				}
				$(this).val(v);
			});

			// range sliders
			<!--- todo: this or jquery-ui range slider --->
			<!---
			var rangeSlider = $("input.mura-rangeslider").bootstrapSlider();
			$(rangeSlider).on('change',function(){
				var v = rangeSlider.bootstrapSlider('getValue');
				var targetEl = $(this).attr('data-slider-valuefield');
				$(targetEl).val(v).hide();
			});
			--->

			// colorpicker
			$('.mura-colorpicker input[type=text]').on('keyup',function(){
				if ($(this).val().length == 0){
					$(this).parents('.mura-colorpicker').find('.mura-colorpicker-swatch').css('background-color','transparent');
				}
			})
			
			window.configuratorInited=true;
		});
	</script>
	</cfif>
</cfif>