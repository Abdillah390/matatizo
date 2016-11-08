_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

Graphs = require '../models/Graphs'
moment = require 'moment'
dc = require 'dc'
d3 = require 'd3'
crossfilter = require 'crossfilter'

class TimeToCompleteGraphView extends Backbone.View
  el: "#content"

  render: =>
    console.log(Coconut.config)
    options = $.extend({},Coconut.router.reportViewOptions)
    @$el.html "
       <style>div#target_container { width: 93%; color: #ccc; overflow: auto}</style>
       <div id='dateSelector'></div>
       <div class='chart-title'>Time To Complete</div>
       <div id='target_container'><span class='f-right'>Notification target: #{Coconut.config.case_notification} hours &nbsp; : &nbsp; Followup target: #{Coconut.config.case_followup} hours</span></div>
       <div id='chart_container_1' class='chart_container'>
         <div class='mdl-grid'>
           <div class='mdl-cell mdl-cell--12-col mdl-cell--8-col-tablet mdl-cell--4-col-phone'>
             <div id='errMsg'></div>
             <div id='chart'></div>
           </div>
         </div>
       </div>
    "
    HTMLHelpers.resizeChartContainer()
    $('#analysis-spinner').show()
    options.adjustX = 10
    options.adjustY = 40
    startDate = options.startDate
    endDate = options.endDate
    Coconut.database.query "caseCounter",
      startkey: [startDate]
      endkey: [endDate]
      reduce: false
      include_docs: false
    .then (result) =>
      dataForGraph = result.rows
      if (dataForGraph.length == 0  or _.isEmpty(dataForGraph[0]))
        $(".chart_container").html HTMLHelpers.noRecordFound()
        $('#analysis-spinner').hide()
      else
        dataForGraph.forEach((d) ->
          d.dateICD = moment(d.key[0])
#          d.dateICD = new Date(d.key[0]+' ') # extra space at end cause it to use UTC format.
        )
        composite = dc.compositeChart("#chart")
        Graphs.timeToComplete(dataForGraph, composite, options)

        window.onresize = () ->
          HTMLHelpers.resizeChartContainer()
          Graphs.compositeResize(composite, 'chart_container', options)
          
        $('#analysis-spinner').hide()
        
    .catch (error) ->
      console.error error
      $('#errMsg').html("Sorry. Unable to complete due to an error: </br>"+error)
      $('#analysis-spinner').hide()
    
       
module.exports = TimeToCompleteGraphView
