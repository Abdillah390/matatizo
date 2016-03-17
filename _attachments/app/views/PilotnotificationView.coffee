_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

DataTables = require 'datatables'
Reports = require '../models/Reports'

class PilotnotificationView extends Backbone.View
  el: "#content"

  render: =>

    @$el.html "
        <div id='dateSelector'></div>
    "
    options = Coconut.router.reportViewOptions

module.exports = PilotnotificationView
