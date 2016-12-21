$ = require 'jquery'
require('jquery-ui')
Backbone = require 'backbone'
Backbone.$  = $
moment = require 'moment'
require 'bootstrap-daterangepicker'

class DateSelectorView extends Backbone.View
  el: "#dateSelector"
    
  events:
    "change #select-by": "selectBy"
    "click .submitBtn": "updateReportView"
    "click button#dateFilter": "showDateFilter"
    "apply.daterangepicker #dateRange": "updateReportView"

  showDateFilter: (e) =>
    e.preventDefault
    $("div#filters-section").slideToggle()

  updateReportView: (e, picker) =>
    e.preventDefault
    @startDate = picker.startDate
    @endDate = picker.endDate
    Coconut.router.reportViewOptions['startDate'] = @startDate.format("YYYY-MM-DD")
    Coconut.router.reportViewOptions['endDate'] = @endDate.format("YYYY-MM-DD")
    if Coconut.dateSelectorView.reportType is 'dashboard'
      url = "#{Coconut.dateSelectorView.reportType}/#{Coconut.router.reportViewOptions['startDate']}/#{Coconut.router.reportViewOptions['endDate']}"
    else  
      url = "#{Coconut.dateSelectorView.reportType}/"+("#{option}/#{value}" for option,value of Coconut.router.reportViewOptions).join("/")
    Coconut.router.navigate(url,{trigger: true})

  render: =>
    @$el.html "
      <div id='dateRange' class='f-left'>
          <i class='material-icons'>event</i>&nbsp;
          <span></span><i class='material-icons f-right'>arrow_drop_down</i>
      </div>
      <div id='noDataFound' class='f-left'>No data found for date range selected. Using predefined default dates</div>
      <div style='clear:both'></div>
    "
    $('#dateRange span').html(@startDate + ' - ' + @endDate) 
    $('#dateRange').daterangepicker
      "startDate": @startDate
      "endDate": @endDate
      "showWeekNumbers": true
      "ranges": 
        'Today': [moment(), moment()],
        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
        'This Year': [moment().startOf('year'), moment().endOf('year')],
        'Last Year': [moment().subtract(1, 'year').startOf('year'), moment().subtract(1, 'year').endOf('year')]
      "locale": 
        "format": "YYYY-MM-DD"
        "separator": " - "
        "applyLabel": "Apply"
        "cancelLabel": "Cancel"
        "fromLabel": "From"
        "toLabel": "To"
        "customRangeLabel": "Custom"
        "weekLabel": "W"
        "daysOfWeek": ["Su","Mo","Tu","We","Th","Fr","Sa"]
        "monthNames": ["January","February","March","April","May","June","July","August","September","October","November","December"]
        "firstDay": 1
      "alwaysShowCalendars": true
    ,(start,end,label) ->
      @startDate = start
      @endDate = end
      $('#dateRange span').html(@startDate.format('YYYY-MM-DD') + ' - ' + @endDate.format('YYYY-MM-DD'))

module.exports = DateSelectorView
