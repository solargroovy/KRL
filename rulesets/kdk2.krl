ruleset a41x228 {
  meta {
    name "KDK"
    description <<
      KDK

      This is the Kynetx Developer Kit. It includes the ability
      to manage registered rulesets as well as the interface for the
      KRL application.

      Copyright 2013 Kynetx, All Rights Reserved
    >>
    author "Jessie A. Morris and MEH"

    use module a169x701 alias CloudRain
    use module a41x196 alias SquareTag
    use module a41x226 alias appManager
    use module a169x625 alias CloudOS
    use module a169x667 alias myThings
    use module a169x676 alias pds

    key system_credentials {
      "root": "YmY4MzNlZWQzN2Q3Zjg1ZTg1YWE3MDYyZGJmMGEwN2M5YzM0NGVjNmU2YzI3MmM2NmRjZTBjNWQzNWIwOTkwYzYwZjc1NGM5NjAxMDll"
    }

    logging on
  }

  dispatch {
    // Some example dispatch domains
    // domain "example.com"
    // domain "other.example.com"
  }

  global {
    get_rulesets_gallery = function() {
    	ruleset_list = rsm:list_rulesets(meta:eci());
    	struct = ruleset_list.map(function(x){
    		details = rsm:get_ruleset(x);
    		rid = details{"rid"};
    		uri = details{"uri"};
    		html = <<
    			<tr>
    				<td data-title = "RID">#{rid}</td>
    				<td data-title = "URI">#{uri}</td>
    				<td data-title = "FLUSH">
    					<button type="button" class="btn btn-default btn-xs">
    						<span class="glyphicon glyphicon-refresh"></span> Flush
    					</button>
    				</td>
    			</tr>
    		>>;
    		html
    	});
    	list_text = ruleset_list.encode();
    	struct_text = struct.encode();
    	also_div = <<
    		#{struct}
    	>>;
    	also_div;
    };
    get_apps_gallery = function(){
      appThumbnails = appManager:get_my_apps().values().map(function(app) {
        appName = app{'appName'};
        appECI  = app{'appECI'};
        appIcon = app{'appImageURL'};
        thisApp = <<
          <li class="span2" id="myApps-#{appRID}">
            <div class="thumbnail mycloud-thumbnail">
              <a href="#!/app/#{meta:rid()}/editApp&appECI=#{appECI}"><img src="#{appIcon}" alt="#{appName}"></a>
              <h5 class="cloudUI-center">#{appName}</h5>
            </div>  <!-- .thumbnail -->
          </li>
        >>;
        thisApp
      }).join(" ");

      appGallery = <<
        <ul id="myApps-app-list" class="thumbnails mycloud-thumbnails">
          #{appThumbnails}
        </ul>
      >>;

      appGallery
    };

    css <<
        #kdk-channel-manager {
            color: #e6e6e6;
            font-family: "Helvitica Neue", "Helvitica", sans-serif;
            padding: 10px;
        }

        #kdk-channel-manager h5 {
            padding: 0;
            margin: 0;
        }

        #kdk-channel-manager h2 {
            display: inline-block;
        }
    >>;
  }

  rule removeAppPanel {
    select when web cloudAppSelected
      or        web cloudAppAction
    pre {
      cloudAppPanel = "#cloudAppPanel-#{meta:rid()}";
    }
    {
      emit <<
        $K(cloudAppPanel).remove();
      >>;
    }
  }

  rule showApps {
    select when web cloudAppSelected
    pre {
      appsGallery = get_apps_gallery();
	  rulesetsGallery = get_rulesets_gallery();
      html = <<
        <p>
          Welcome to the Kynetx Developer Kit. Below are your applications. Click on one to view more information about it.
        </p>
		<div class="squareTag wrapper">
          <ul id="kdkTab" class="nav nav-tabs">
          	<li class="active"><a href="#rulesetTab" data-toggle="tab">Rulesets</a></li>
          	<li class=""><a href="#appsTab" data-toggle="tab">Applications</a></li>
          </ul>
          <div class="tab-content" id="kdkTabContent">
            <div class="tab-pane fade active in" id="rulesetTab">
              #{rulesetsGallery}
            </div>

            <div class="tab-pane fade" id="appsTab">
              #{appsGallery}
            </div>
          </div>	
        
        
      >>;

      appMenu = [
        {
          "label": "Create App",
          "action": "createApp"
        },
        {
          "label": "Delete All Apps",
          "action": "deleteApps"
        },
        {
          "label": "List Rulesets",
          "action": "listRulesets"
        },
        {
          "label": "Lookup Scheduled Event",
          "action": "lookupScheduledEvent"
        },
        {
          "label": "List Entity & App Variables",
          "action": "listVariables"
        },
        {
            "label": "Channel Manager",
            "action": "channels"
        }
      ];
    }
    {
      CloudRain:createLoadPanel("Kynetx Developer Kit--Good Parts Version", appMenu, html);
    }
  }

  rule editApp {
    select when web cloudAppAction action re/editApp/
    pre {
      app = appManager:get_app(event:attr("appECI")) || {};

      appName = app{"appName"};
      appDescription = app{"appDescription"};
      appImageURL = app{"appImageURL"};
      appDeclinedURL = app{"appDeclinedURL"};
      appCallbackURL = app{"appCallbackURL"};
      appSecret = app{"appSecret"};
      appECI = app{"appECI"};

      linkToOAuthInit = pci:request_uri(appECI, appCallbackURL);

      callback_urls = pci:list_callback(appECI);

      html = <<
        <form id="formUpdateApp" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="appName">App Name</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appName" value="#{appName}" title="Your app's name (Required)" placeholder="Your app's name (Required)" required />
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appDescription">App Description</label>
              <div class="controls">
                <textarea type="text" class="input-xlarge" name="appDescription" title="Your app's description" placeholder="Your app's description">#{appDescription}</textarea>
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appCallbackURL">App Image URL</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appImageURL" value="#{appImageURL}" title="The URL that contains your app's image (Required)" placeholder="The URL that contains your app's image (Required)" required />
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appCallbackURL">App Callback URL</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appCallbackURL" value="#{appCallbackURL}" title="The URL to take the user if authorization succeeds (Required)" placeholder="The URL to take the user if authorization succeeds (Required)" required />
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appDeclinedURL">App Declined URL</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appDeclinedURL" value="#{appDeclinedURL}" title="The URL to take the user if authorization fails (Required)" placeholder="The URL to take the user if authorization fails (Required)" required />
              </div>
            </div>
            <div class="form-actions">
              <input type="hidden" name="appECI" value="#{appECI}" />
              <button type="submit" class="btn btn-primary">Save Entry</button>
            </div>
          </fieldset>
        </form>

        <p>
          Token (App ECI): #{appECI} <br />
          App Secret: #{appSecret}<br />
          URL: #{linkToOAuthInit}
        </p>

      >>;
    }
    {
      CloudRain:createLoadPanel("Create New App", [], html);
      CloudRain:skyWatchSubmit("#formUpdateApp", "");
    }
  }

  rule updateApp {
    select when web submit "#formUpdateApp"
    pre {
      appName = event:attr("appName");
      appDescription = event:attr("appDescription");
      appImageURL = event:attr("appImageURL");
      appCallbackURL = event:attr("appCallbackURL");
      appDeclinedURL = event:attr("appDeclinedURL");
      appECI = event:attr("appECI");

      appData = {
        "appName": appName,
        "appDescription": appDescription,
        "appImageURL": appImageURL,
        "appDeclinedURL": appDeclinedURL,
        "appCallbackURL": appCallbackURL
      };
    }
    {
      CloudRain:setHash("/app/#{meta:rid()}/show");
    }
    fired {
      raise explicit event updateApp for a41x226
        with appData = appData
        and appECI = appECI;
    }
  }

  rule createNewOAuthApp {
    select when web cloudAppAction action re/createApp/
    pre {
      html = <<
        <form id="formCreateNewApp" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="appName">App Name</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appName" title="Your app's name (Required)" placeholder="Your app's name (Required)" required />
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appDescription">App Description</label>
              <div class="controls">
                <textarea type="text" class="input-xlarge" name="appDescription" title="Your app's description" placeholder="Your app's description"></textarea>
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appCallbackURL">App Image URL</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appImageURL" title="The URL that contains your app's image (Required)" placeholder="The URL that contains your app's image (Required)" required />
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appCallbackURL">App Callback URL</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appCallbackURL" title="The URL to take the user if authorization succeeds (Required)" placeholder="The URL to take the user if authorization succeeds (Required)" required />
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="appDeclinedURL">App Declined URL</label>
              <div class="controls">
                <input type="text" class="input-xlarge" name="appDeclinedURL" title="The URL to take the user if authorization fails (Required)" placeholder="The URL to take the user if authorization fails (Required)" required />
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Save Entry</button>
            </div>
          </fieldset>
        </form>
      >>;
    }
    {
      CloudRain:createLoadPanel("Create App", [], html);
      CloudRain:skyWatchSubmit("#formCreateNewApp", "");
    }
  }

  rule saveApp {
    select when web submit "#formCreateNewApp"
    pre {
      appName = event:attr("appName");
      appDescription = event:attr("appDescription");
      appImageURL = event:attr("appImageURL");
      appCallbackURL = event:attr("appCallbackURL");
      appDeclinedURL = event:attr("appDeclinedURL");

      appData = {
        "appName": appName,
        "appDescription": appDescription,
        "appImageURL": appImageURL,
        "appDeclinedURL": appDeclinedURL,
        "appCallbackURL": appCallbackURL
      };
    }
    {
      CloudRain:setHash("/app/#{meta:rid()}/show");
    }
    fired {
      raise explicit event createNewApp for a41x226
        with appData = appData;
    }
  }

  rule showRulesets {
    select when web cloudAppAction action re/listRulesets/
    pre {
      rulesets = rsm:list_rulesets(meta:eci());

      rulesetGallery = rulesets.map(function(rid){
        ridInfo = (rid) => rsm:get_ruleset(rid) | {};

        appURL = ridInfo{"uri"};

        ridHTML = <<
          <tr>
            <td>
              <a href="#!/app/#{meta:rid()}/editRuleset&rulesetID=#{rid}">
                #{rid}
              </a>
            </td>
            <td>
              <a href="#{appURL}">
                #{appURL}
              </a>
            </td>
          </tr>
        >>;

        (ridInfo) => ridHTML | ""
      }).join("");

      html = <<
        <div class="squareTag wrapper">
          <table class="table table-striped">
            <thead>
              <tr>
                <th>
                  RID
                </th>
                <th>
                  Source URL
                </th>
              </tr>
            </thead>
            <tbody>
              #{rulesetGallery}
            </tbody>
          </table>
        </div>
      >>;

      appMenu = [
        {
          "label": "Register Ruleset",
          "action": "registerRuleset"
        }
      ];
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Rulesets", appMenu, html);
    }
  }

  rule editRuleset {
    select when web cloudAppAction action re/editRuleset/
    pre {
      rid = event:attr("rulesetID");

      rulesetData = rsm:get_ruleset(rid);

      html = displayRuleset(rulesetData);

      appURL = rulesetData{"uri"};

      html = <<
        <form id="formUpdateRuleset" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="appURL">Source URL</label>
              <div class="controls">
                <textarea class="input-xlarge" name="appURL" title="The location your KRL source resides" placeholder="The location your KRL source resides" required>#{appURL}</textarea>
              </div>
            </div>
            <div class="form-actions">
              <input type="hidden" value="#{rid}" name="rulesetID" />
              <button type="submit" class="btn btn-primary">Update Ruleset</button>
            </div>
          </fieldset>
        </form>
      >>;
    }
    {
      CloudRain:createLoadPanel("Edit Rulesets", [], html);
      CloudRain:skyWatchSubmit("#formUpdateRuleset", "");
    }
  }

  rule updateRuleset {
    select when web submit "#formUpdateRuleset"
    pre {
      rulesetID = event:attr("rulesetID");
      newURL = event:attr("appURL");
    }
    {
      rsm:update(rulesetID) setting(updatedSuccessfully)
        with uri = newURL;
      CloudRain:setHash('/refresh');
    }
    fired {
      raise system event rulesetUpdated
        with rulsetID = rulesetID if(updatedSuccessfully);
    }
  }

  rule createRuleset {
    select when web cloudAppAction action re/registerRuleset/
    pre {
      html = <<
        <p>
          Here you can register a new ruleset. In order to
          successfully register it, the source code must be
          accessible by HTTP access. You can encode the username
          and password into the URL by using
          <a href="https://en.wikipedia.org/wiki/Basic_access_authentication">
            HTTP basic authentication.
          </a>
          At some point I will expose the functionality to allow you to put authentication data in the headers as well. For now, though, you're restricted to Basic Auth only.
        </p>
        <form id="formRegisterNewRuleset" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="appURL">Source URL</label>
              <div class="controls">
                <textarea class="input-xlarge" name="appURL" title="The location your KRL source resides" placeholder="The location your KRL source resides" required></textarea>
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Register Ruleset</button>
            </div>
          </fieldset>
        </form>
      >>;
    }
    {
      CloudRain:createLoadPanel("Create Ruleset", [], html);
      CloudRain:skyWatchSubmit("#formRegisterNewRuleset", "");
    }
  }

  rule createRulesetSubmit {
    select when web submit "#formRegisterNewRuleset"
    pre {
      appURL = event:attr("appURL");
    }
    {
      rsm:register(appURL) setting (rid);
      CloudRain:setHash('/app/#{meta:rid()}/listRulesets');
    }
    fired {
      raise system event rulesetCreated
        with rulsetID = rid{"rid"} if(rid);
    }
  }

  rule deleteRulesets {
    select when web cloudAppAction action re/deleteRulesets/
    {
      CloudRain:setHash('/app/#{meta:rid()}/listRulesets');
    }
    //fired {
      //TODO: Need to delete the ruleset.
    //}
  }

  rule showVariables {
    select when web cloudAppAction action re/listVariables/
    pre {
      keys = rsm:entity_keys();
      justKeys = rsm:entity_keys().keys();

      html = <<
      >>;
    }
    {
      CloudRain:createLoadPanel("Entity & App Variables", [], html);
    }
  }

  rule showScheduledLog {
    select when web cloudAppAction action re/lookupScheduledEvent/
    pre {
      html = <<
        <form id="formLookupScheduledEvent" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="scheduleID">Schedule ID</label>
              <div class="controls">
                <textarea class="input-xlarge" name="scheduleID" title="The ID of the schedule you want info for" placeholder="The ID of the schedule you want info for" required></textarea>
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Lookup Schedule</button>
            </div>
          </fieldset>
        </form>
      >>;
    }
    {
      CloudRain:createLoadPanel("Entity & App Variables", [], html);
      CloudRain:skyWatchSubmit("#formLookupScheduledEvent", meta:eci());
    }
  }

  rule getScheduledLog {
    select when web submit "#formLookupScheduledEvent"
    pre {
      scheduleID = event:attr("scheduleID");

      eventHistory = event:get_history(scheduleID);
    }
    {
      alert(eventHistory.encode());
    }
  }

    rule view_and_edit_channels {
        select when web cloudAppAction action re/channels/
        pre {
            // just define the function here because its not really used anywhere else, nor will it be.
            get_channels_for_cloud = function(eci) {
                CloudOS:channelList(eci)
            };
            // get the cloud data and channels for the current cloud. (IE, the cloud that this rule is being run in).
            current_cloud_info = pds:get_all_me();
            current_cloud_name = current_cloud_info{"myProfileName"};
            current_cloud_channels = CloudOS:channelList();
            current_cloud_channels_html = current_cloud_channels{"channels"}.map(function(channel) {
                name = channel{"name"};
                id = channel{"cid"};

                "<h5>Name:#{name}</h5><h5>ID:#{id}</h5><br />"
            }).reverse().join(" "); // show the newest eci's first.
            all_other_family_clouds = pci:list_children();
            current_cloud_option = <<
                <option value = "#{meta:eci()}">#{current_cloud_name}</option>
            >>;
            all_other_family_cloud_options = all_other_family_clouds.map(function(cloud_eci_data) {
                desired_channel = cloud_eci_data.head();
                profile = CloudRain:getProfile(desired_channel);
                name = profile{"myProfileName"};

                '<option value = "#{desired_channel}">#{name}</option>'
            }).join(" ");
            all_other_family_cloud_channels_html = all_other_family_clouds.map(function(cloud_eci_data) {
                desired_channel = cloud_eci_data.head();
                // CloudOS:channelList() only works for the current cloud. Silly, actually.
                this_cloud_channels = pci:list_eci(desired_channel);
                this_cloud_channels_html = this_cloud_channels{"channels"}.map(function(channel) {
                    name = channel{"name"};
                    id = channel{"cid"};

                    "<h5>Name:#{name}</h5><h5>ID:#{id}</h5><br />"

                }).reverse().join(" "); // show the newest eci's first.
                this_cloud_channels_div = << 
                    <div class = 'cloud-channels' data-contains-channels-for = '#{desired_channel}' style = 'display:none;'>
                        #{this_cloud_channels_html}
                    </div>
                >>;

                this_cloud_channels_div
            }).join(" ");
            cloud_options = <<
                #{current_cloud_option}
                #{all_other_family_cloud_options}
            >>;
            cloud_select = <<
                <select id = "kdk-channels-for-cloud">
                    #{cloud_options}
                </select>
            >>;
            container = <<
                <div id = "kdk-channel-manager">
                    <h1>Welcome to the Channel Manager. Here you can view and add channels for your personal cloud or clouds that you own.</h1>
                    <h2>View Event Channels for Cloud:</h2>#{cloud_select}
                    <button id = "add-channel" class = "btn">Add an Event Channel for this cloud</button>
                    <div id = "current-cloud-channels" class = "cloud-channels" data-contains-channels-for = "#{meta:eci()}" style = "display:none;">
                        #{current_cloud_channels_html}
                    </div>
                    #{all_other_family_cloud_channels_html}
                </div>
                <div id = "add-modal" class = "modal hide fade">
                    <div class = "modal-header">
                        <h3>Add Channel to cloud <span id = "modal-header-cloud-name"></span></h3>
                    </div>
                    <div class = "modal-body">
                        <label for = "channel-name">Channel Name:</label>
                        <input type = "text" name = "channel-name" id = "channel-name" placeholder = "Channel Name" required />
                    </div>
                    <div class = "modal-footer">
                        <button id = "add-create-channel" class = "btn">Add Channel</button>
                    </div>
                </div>
            >>;
        }
        {
            CloudRain:createLoadPanel("Channel Manager", [], container);
            emit <<
                $K("[data-contains-channels-for = '"+ $K("#kdk-channels-for-cloud").val() + "']").show();
                $K("#kdk-channels-for-cloud").on("change", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    $K(".cloud-channels").hide();
                    $K("[data-contains-channels-for = '"+ this.value + "']").show();
                });

                $K("#add-channel").on("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    $K("#modal-header-cloud-name").text($K("#kdk-channels-for-cloud option:selected").text()).data("cloud-eci", $K("#kdk-channels-for-cloud").val());
                    $K("#channel-name").val('');
                    $K("#add-modal").modal("show");
                });

                $K("#add-create-channel").on("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();

                    $K("#modalSpinner").modal("show");
                    
                    var channel_name = $K("#channel-name").val();

                    var eci = $K("#modal-header-cloud-name").data("cloud-eci");
                    var event_id = Math.floor(Math.random() * 99999);
                    var signal_url = "https://cs.kobj.net/sky/cloud/cloudos/channelCreate?channelName="+ channel_name;

                    $K.ajax({
                        url: signal_url,
                        type: "GET",
                        success: function(data) {
                            // hide the spinny and eci creation modals.
                            $K("#modalSpinner").modal("hide");
                            $K("#add-modal").modal("hide");
                            $K("[data-contains-channels-for = '"+ eci +"']").prepend("<h5>Name:"+ channel_name +"</h5><h5>ID:"+ data.token +"</h5><br />");
                        },
                        error: function() {
                            KOBJ.log("ECI creation not succesful.");
                            for (var i = 0; i < arguments.length; i++) {
                                console.log(JSON.stringify(arguments[i], null, 4));
                            }
                        },
                        beforeSend: function(jqXHR) {
                            jqXHR.setRequestHeader("Kobj-Session", eci);
                        }
                    });
                });

                $K("#channel-name").on("keyup", function(e) {

                    // if the enter key was pressed and the input element is not empty and 
                    // there's at least one character that is not a space.
                    if (e.which === 13 && this.value && this.value.match(/\S/)) {
                        e.preventDefault();
                        e.stopPropagation();

                        $K("#add-create-channel").trigger("click");
                    }
                });
            >>;
        }
    }
}
