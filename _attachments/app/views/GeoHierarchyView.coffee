_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

Tabulator = require 'tabulator-tables'

class GeoHierarchyView extends Backbone.View
  el: '#content'

  events:
    "click #updateFromDhis": "updateFromDhis"
    "click #download": "csv"

  csv: => @tabulator.download "csv", "CoconutTableExport.csv"
    
  render: =>
    @$el.html "
      <h2>Regions, Districts, Facilities and Shehias</h2>
      <button>Show differences with DHIS2</button>
      <button id='updateFromDhis'>Update from DHIS2</button>
      <button id='addAlias'>Add an alias</button>
      (These buttons are not enabled yet)
      <br/>
      <br/>
      <button id='download'>CSV ↓</button>
      <div id='tabulator'></div>
    "

    @tabulator = new Tabulator "#tabulator",
      height: 500
      columns: for field in [
        "Name"
        "Level"
        "One level up"
        "Two levels up"
        "Aliases"
      ]
        result = {
          title: field
          field: field
          headerFilter: "input"
        }
        switch field
          when "Name"
            result["formatterParams"] = urlField: "url"
            result["formatter"] = "link"
        result

      data: for unit in GeoHierarchy.units
        {
          Name: unit.name
          Level: unit.levelName
          "One level up": "#{unit.parent()?.levelName or ""}: #{unit.parent()?.name or ""}"
          "Two levels up": "#{unit.parent()?.parent()?.levelName or ""}: #{unit.parent()?.parent()?.name or ""}"
          url: "#dashboard/administrativeLevel/#{unit.levelName}/administrativeName/#{unit.name}"
          "Aliases": if (alias = GeoHierarchy.externalAliases[unit.name]) then alias else ""
        }



module.exports = GeoHierarchyView
