_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $
PouchDB = require 'pouchdb'
moment = require 'moment'

DataTables = require 'datatables'
Reports = require '../models/Reports'

class RainfallReportView extends Backbone.View
  el: "#content"

  render: =>
    options = Coconut.router.reportViewOptions
    $('#analysis-spinner').show()
    @$el.html "
      <div id='dateSelector'></div>
      <div id='messages'></div>
    "
    Coconut.database.query "zanzibar-server/rainfallDataByDateAndLocation",
      startkey: [moment(options.startDate).year(), moment(options.startDate).week()]
      endkey: [moment(options.endDate).year(), moment(options.endDate).week()] 
      include_docs: true
    .catch (error) -> 
      coconut.debug "Error: #{JSON.stringify error}"
      console.error error
    .then (results) =>
      $('#analysis-spinner').hide()
      @$el.append "
        <table class='tablesorter' id='rainfallReports'>
          <thead>
            <th>Station</th>
            <th>Year</th>
            <th>Week</th>
            <th>Amount</th>
          </thead>
          <tbody>
          #{
             _(results.rows).map (row) =>
               "
                <tr>
                  <td>#{row.value[0]}</td>
                  <td>#{row.key[0]}</td>
                  <td>#{row.key[1]}</td>
                  <td>#{row.value[1]}</td>
                </tr>
               "
             .join("")
          }
          </tbody>
        </table>
      "

    $("#rainfallReports").dataTable
      aaSorting: [[1,"desc"],[2,"desc"]]
      iDisplayLength: 5
      dom: 'T<"clear">lfrtip'
      tableTools:
        sSwfPath: "js-libraries/copy_csv_xls.swf"
        aButtons: [
          "copy",
          "csv",
          "print"
        ]

module.exports = RainfallReportView