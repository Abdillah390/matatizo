_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

Reports = require '../models/Reports'
Dialog = require './Dialog'
Config = require '../models/Config'
CONST = require '../Constants'

class SystemSettingsView extends Backbone.View
  el: "#content"

  events:
    "click button#updateBtn": "updateConfig"
    
  updateConfig: (e) =>  
    Coconut.database.get("coconut.config")
    .then (doc) ->
      fields = ['appName','appIcon','country','timezone','dateFormat','graphColorScheme','cloud_database_name','cloud','cloud_credentials','design_doc_name','role_types']
      _(fields).map (field) =>
        doc["#{field}"] = $("##{field}").val()
      return Coconut.database.put(doc)
        .then () ->
          Dialog.createDialogWrap()
          Dialog.confirm("Configuration has been saved. You need to reload your screen in order for settings to take effect.", 'System Settings',['Ok']) 
          dialog.addEventListener 'close', ->
            location.reload(true)
        .catch (error) ->
          console.error error
          Dialog.errorMessage(error)
    .catch (error) ->
      console.error error
      Dialog.errorMessage(error)

    .then ()->
      Config.getConfig
        error: ->
          console.log("Error Retrieving Config")
        success: ->
          console.log("Retrieve Config Successful")
  
    return false
    
  render: =>
    countries = _.pluck(CONST.Countries, 'name')
    timezones = _.pluck(CONST.Timezones,'DisplayName')
    #countries = ['Zanzibar','Zimbabwe','Unites States']
    #timezones = ['East Africa','America/NY']
    dateFormats = CONST.dateFormats
    colorSchemes = CONST.graphColorSchemes

    @$el.html "
      <h4>Global System Settings</h4>
      <form id='system_settings'>
        <div class='indent m-l-20'>
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='appName' value='#{Coconut.config.appName}'>
            <label class='mdl-textfield__label' for='appName'>Application Title</label>
          </div> 
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='appIcon' value='#{Coconut.config.appIcon}'>
            <label class='mdl-textfield__label' for='appIcon'>Application Icon File name</label>
          </div> 
          <div class='mdl-select mdl-js-select mdl-select--floating-label setting_inputs'>
            <select class='mdl-select__input' id='country' name='country'>
              <option value=''></option>
              #{
                countries.map (country) =>
                  "<option value='#{country}' #{if Coconut.config.country is country then "selected='true'" else ""}>
                    #{country}
                   </option>"
                .join ""
              }
            </select>
            <label class='mdl-select__label' for=country'>Country</label>
          </div><br />
          <div class='mdl-select mdl-js-select mdl-select--floating-label setting_inputs'>
            <select class='mdl-select__input' id='timezone' name='timezone'>
              <option value=''></option>
              #{
                timezones.map (tzone) =>
                  "<option value='#{tzone}' #{if Coconut.config.timezone is tzone then "selected='true'" else ""}>
                    #{tzone}
                   </option>"
                .join ""
              }
            </select>
            <label class='mdl-select__label' for='timeZone'>Time Zone</label>
          </div><br />
          <div class='mdl-select mdl-js-select mdl-select--floating-label setting_inputs'>
            <select class='mdl-select__input' id='dateFormat' name='dateFormat'>
              <option value=''></option>
              #{
                dateFormats.map (dformat) =>
                  "<option value='#{dformat}' #{if Coconut.config.dateFormat is dformat then "selected='true'" else ""}>
                    #{dformat}
                   </option>"
                .join ""
              }
            </select>
            <label class='mdl-select__label' for='dateFormat'>Date Format</label>
          </div><br />
          <div class='mdl-select mdl-js-select mdl-select--floating-label setting_inputs'>
            <select class='mdl-select__input' id='graphColorScheme' name='graphColorScheme'>
              <option value=''></option>
              #{
                colorSchemes.map (cscheme) =>
                  "<option value='#{cscheme}' #{if Coconut.config.graphColorScheme is cscheme then "selected='true'" else ""}>
                    #{cscheme}
                   </option>"
                .join ""
              }
            </select>
            <label class='mdl-select__label' for='graphColorScheme'>Graph Color Scheme</label>
          </div>
        </div>
        <h4>Database Settings</h4>
        <div class='indent m-l-20'>
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='cloud_database_name' value='#{Coconut.config.cloud_database_name}'>
            <label class='mdl-textfield__label' for='cloud_database_name'>Cloud Database Name</label>
          </div> 
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='cloud' value='#{Coconut.config.cloud}'>
            <label class='mdl-textfield__label' for='cloud'>Cloud URL</label>
          </div>
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='cloud_credentials' value='#{Coconut.config.cloud_credentials}'>
            <label class='mdl-textfield__label' for='cloud_credentials'>Cloud Credentials</label>
          </div>
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='design_doc_name' value='#{Coconut.config.design_doc_name}'>
            <label class='mdl-textfield__label' for='design_doc_name'>Design Doc Name</label>
          </div>
          <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label setting_inputs'>
            <input class='mdl-textfield__input' type='text' id='role_types' value='#{Coconut.config.role_types}'>
            <label class='mdl-textfield__label' for='role_types'>Role Types</label>
          </div>
        </div>
        <hr />
        <div id='dialogActions'>
         <button class='mdl-button mdl-js-button mdl-button--primary' id='updateBtn' type='submit' value='save'><i class='material-icons'>save</i> Update</button> &nbsp;
        </div>
      </form>
      
    "
    Dialog.markTextfieldDirty()
    
    
module.exports = SystemSettingsView