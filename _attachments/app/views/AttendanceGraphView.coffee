_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

DataTables = require( 'datatables.net' )()
Reports = require '../models/Reports'
moment = require 'moment'
Graphs = require '../models/Graphs'

class AttendanceGraphView extends Backbone.View
  el: "#content"

  render: =>
    options = $.extend({},Coconut.router.reportViewOptions)
    @$el.html "
       <div id='dateSelector'></div>
       <div class='chart-title'>Attendance</div>
       <div id='chart_container_1' class='chart_container'>
         <div class='mdl-grid'>
           <div class='mdl-cell mdl-cell--11-col mdl-cell--7-col-tablet mdl-cell--3-col-phone'>
             <div id='y_axis_1' class='y_axis'></div>
             <div id='chart_1' class='chart_lg'></div>
             <div id='x_axis_1' class='x_axis'></div>
           </div>
           <div class='mdl-cell mdl-cell--1-col mdl-cell--1-col-tablet mdl-cell--1-col-phone'>   
             <div id='legend' class='legend'></div>
           </div>
         </div>
       </div>
    "
    
    $('#analysis-spinner').show()
    options.container = 'chart_container_1'
    options.y_axis = 'y_axis_1'
    options.x_axis = 'x_axis_1'
    options.chart = 'chart_1'
    options.renderer = 'scatterplot'
    options.names = ["Age < 5","Age >= 5"]
    options.couch_views = ["positiveCasesByFacilityLT5","positiveCasesByFacilityGTE5"]
    Graphs.create options
    .catch (err) ->
      console.error err
    .then () ->
      $('#analysis-spinner').hide()
    
module.exports = AttendanceGraphView