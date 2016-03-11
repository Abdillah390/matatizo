_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

global.jQuery = require 'jquery'
require 'tablesorter'

Reports = require '../models/Reports'
FacilityHierarchy = require '../models/FacilityHierarchy'

global.HTMLHelpers = require '../HTMLHelpers'

class CaseFollowupView extends Backbone.View
  events:
    "click .rpt-suboptions": "showDropDown"

  showDropDown: (e) =>
    id = '#'+ e.currentTarget.id + '-section'
    $("#{id}").slideToggle()
  
  getCases: (options) =>
    reports = new Reports()
    reports.getCases
      startDate: @startDate
      endDate: @endDate
      success: options.success
      mostSpecificLocation: Reports.mostSpecificLocationSelected()

  render: =>
    @reportOptions = Coconut.router.reportViewOptions
    district = @reportOptions.district || "ALL"

    @startDate = @reportOptions.startDate || moment(new Date).subtract(7,'days').format("YYYY-MM-DD")
    @endDate = @reportOptions.endDate || moment(new Date).format("YYYY-MM-DD")

    $('#analysis-spinner').show()

    @$el.html "
      <div id='dateSelector'></div>
      <img id='analysis-spinner' src='/images/spinner.gif'/> 	
      <div id='summary-dropdown'>
        <div id='unhide-icons'>
		  <!--
		  <span id='cases-drop' class='drop-pointer rpt-suboptions'>
		 	<button class='mdl-button mdl-js-button mdl-button--icon'> 
		 	   <i class='material-icons'>functions</i> 
		     </button>Summary
		  </span>
          -->	  
          <span id='legend-drop' class='drop-pointer rpt-suboptions'>
            <button class='mdl-button mdl-js-button mdl-button--icon'> 
              <i class='material-icons'>dashboard</i> 
            </button>
              Legend
          </span>
        </div>
      </div>	
      <div id='dropdown-container'>
           <div id='cases-drop-section'>
             <h4>Summary</h4>
             <div>
               <table class='mdl-data-table mdl-js-data-table mdl-shadow--2dp'>
                 <thead>
                   <tr>
                     <td class='mdl-data-table__cell--non-numeric'>Cases Reported at Facility</td>
                     <td>51</td>
                   </tr>
                 </thead>
                 <tbody>
                   <tr>
                     <td class='mdl-data-table__cell--non-numeric'>Additional People Tested</td>
                     <td>137</td>
                   </tr>
                   <tr>
                     <td class='mdl-data-table__cell--non-numeric'>Additional People Tested Positive</td>
                     <td>6</td>
                   </tr>
                 </tbody>
               </table>
             </div>	
             <hr />
           </div>
           
           <div id='legend-drop-section'>
             <h4>Legends</h4>	
             <h6>Click on a button for more details about the case.</h6>
             <button class='mdl-button mdl-js-button mdl-button--icon mdl-button--accent'><i class='material-icons'>account_circle</i></button> - Positive malaria result found at household<br />
             <button class='mdl-button mdl-js-button mdl-button--icon'><i class='material-icons  c_orange'>account_circle</i></button> - Positive malaria result found at household with no travel history (probable local transmission). <br />
             <button class='mdl-button mdl-js-button mdl-button--icon'><i class='material-icons  household'>home</i></button> - Index case had no travel history (probable local transmission).<br />
             <button class='mdl-button mdl-js-button mdl-button--icon mdl-button--accent'><i class='material-icons'>error_outline</i></button> - Case not followed up to facility after 24 hours. <br />
             <span style='font-size:75%;color:#3F51B5;font-weight:bold'>SHEHIA</span> - is a shehia classified as high risk based on previous data. <br />
             <button class='btn btn-small  mdl-button--primary'>caseid</button> - Case not followed up after 48 hours. <br />
          </div>
      </div>
      <div id='results' class='result'>
        <table class='summary tablesorter'>
          <thead><tr></tr></thead>
          <tbody>
          </tbody>
        </table>
      </div>	
    "
    $('#analysis-spinner').hide()
    tableColumns = ["Case ID","Diagnosis Date","Health Facility District","Shehia","USSD Notification"]

    Coconut.database.query "zanzibar/byCollection",
      key: "question"
    .catch (error) -> console.error error
    .then (result) ->
      tableColumns = tableColumns.concat _(result.rows).pluck("id")
      
      _.each tableColumns, (text) ->
        $("table.summary thead tr").append "<th>#{text} (<span id='th-#{text.replace(/\s/,"")}-count'></span>)</th>"

    @getCases
      success: (cases) =>
        _.each cases, (malariaCase) =>

          $("table.summary tbody").append "
            <tr id='case-#{malariaCase.caseID}'>
              <td class='CaseID'>
                <a href='#show/case/#{malariaCase.caseID}'>
                  <button class='not-followed-up-after-48-hours-#{malariaCase.notFollowedUpAfter48Hours()}'>#{malariaCase.caseID}</button>
                </a>
              </td>
              <td class='IndexCaseDiagnosisDate'>
                #{malariaCase.indexCaseDiagnosisDate()}
              </td>
              <td class='HealthFacilityDistrict'>
                #{
                  if malariaCase["USSD Notification"]?
                    FacilityHierarchy.getDistrict(malariaCase["USSD Notification"].hf)
                  else
                    ""
                }
              </td>
              <td class='HealthFacilityDistrict #{if malariaCase.highRiskShehia() then "high-risk-shehia" else ""}'>
                #{
                  malariaCase.shehia()
                }
              </td>
              <td class='USSDNotification'>
                #{HTMLHelpers.createDashboardLinkForResult(malariaCase,"USSD Notification", "<img src='images/ussd.png'/>")}
              </td>
              <td class='CaseNotification'>
                #{HTMLHelpers.createDashboardLinkForResult(malariaCase,"Case Notification","<img src='images/caseNotification.png'/>")}
              </td>
              <td class='Facility'>
                #{HTMLHelpers.createDashboardLinkForResult(malariaCase,"Facility", "<img src='images/facility.png'/>","not-complete-facility-after-24-hours-#{malariaCase.notCompleteFacilityAfter24Hours()}")}
              </td>
              <td class='Household'>
                #{HTMLHelpers.createDashboardLinkForResult(malariaCase,"Household", "<img src='images/household.png'/>","travel-history-#{malariaCase.indexCaseHasTravelHistory()}")}
              </td>
              <td class='HouseholdMembers'>
                #{
                  _.map(malariaCase["Household Members"], (householdMember) =>
                    malariaPositive = householdMember.MalariaTestResult? and (householdMember.MalariaTestResult is "PF" or householdMember.MalariaTestResult is "Mixed")
                    noTravelPositive = householdMember.OvernightTravelinpastmonth isnt "Yes outside Zanzibar" and malariaPositive
                    buttonText = "<img src='images/householdMember.png'/>"
                    unless householdMember.complete?
                      unless householdMember.complete
                        buttonText = buttonText.replace(".png","Incomplete.png")
                    HTMLHelpers.createCaseLink
                      caseID: malariaCase.caseID
                      docId: householdMember._id
                      buttonClass: if malariaPositive and noTravelPositive
                       "no-travel-malaria-positive"
                      else if malariaPositive
                       "malaria-positive"
                      else ""
                      buttonText: buttonText
                  ).join("")
                }
              </td>
            </tr>
          "

        _.each tableColumns, (text) ->
          columnId = text.replace(/\s/,"")
          $("#th-#{columnId}-count").html $("td.#{columnId} button").length

        $("#Cases-Reported-at-Facility").html $("td.CaseID button").length
        $("#Additional-People-Tested").html $("td.HouseholdMembers button").length
        $("#Additional-People-Tested-Positive").html $("td.HouseholdMembers button.malaria-positive").length

        if $("table.summary tr").length > 1
          $("table.summary").tablesorter
            widgets: ['zebra']
            sortList: [[1,1]]

        districtsWithFollowup = {}
        _.each $("table.summary tr"), (row) ->
            row = $(row)
            if row.find("td.USSDNotification button").length > 0
              if row.find("td.CaseNotification button").length is 0
                if moment().diff(row.find("td.IndexCaseDiagnosisDate").html(),"days") > 2
                  districtsWithFollowup[row.find("td.HealthFacilityDistrict").html()] = 0 unless districtsWithFollowup[row.find("td.HealthFacilityDistrict").html()]?
                  districtsWithFollowup[row.find("td.HealthFacilityDistrict").html()] += 1
        $("#alerts").append "
        <style>
          #alerts,table.alerts{
            font-size: 80% 
          }

        </style>
        The following districts have USSD Notifications that have not been followed up after two days. Recommendation call the DMSO:
          <table class='alerts'>
            <thead>
              <tr>
                <th>District</th><th>Number of cases</th>
              </tr>
            </thead>
            <tbody>
              #{
                _.map(districtsWithFollowup, (numberOfCases,district) -> "
                  <tr>
                    <td>#{district}</td>
                    <td>#{numberOfCases}</td>
                  </tr>
                ").join("")
              }
            </tbody>
          </table>
        "

module.exports = CaseFollowupView
