<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://www.sakaiproject.org/samigo" prefix="samigo" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--
<%--
***********************************************************************************
*
* Copyright (c) 2004, 2005, 2006 The Sakai Foundation.
*
* Licensed under the Educational Community License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.osedu.org/licenses/ECL-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License. 
*
**********************************************************************************/
--%>
-->
 <f:view>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
      <head><%= request.getAttribute("html.head") %>
      <title><h:outputText
        value="#{commonMessages.total_scores}" /></title>
		<style type="text/css">
			.disabled
			{
				background-color: #f1f1f1;
			}
		</style>
      <script src='/library/js/spinner.js<h:outputText value="#{totalScores.CDNQuery}" />'></script>
<%@ include file="/js/delivery.js" %>

      <script>includeWebjarLibrary('awesomplete')</script>
      <script src='/library/js/sakai-reminder.js<h:outputText value="#{totalScores.CDNQuery}" />'></script>

<script>
function toPoint(id)
{
  var x=document.getElementById(id).value
  document.getElementById(id).value=x.replace(',','.')
}

function pause(numberMillis)
{
var now = new Date();
var exitTime = now.getTime() + numberMillis;
while (true)
{
now = new Date();
if (now.getTime() > exitTime)
return;
}
}

function inIt()
{
  var inputs= document.getElementsByTagName("INPUT");
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].name.indexOf("applyScoreButton") >=0) {
      inputs[i].disabled=false;
    }
  }
}

function disableIt()
{
  var inputs= document.getElementsByTagName("INPUT");
  for (var i = 0; i < inputs.length; i++) {
    if (inputs[i].name.indexOf("applyScoreButton") >=0) {
      inputs[i].disabled=true;
    }
  }
}

$(document).ready(function(){

  // The current class is assigned using Javascript because we don't use facelets and the include directive does not support parameters.
  var currentLink = $('#editTotalResults\\:totalScoresMenuLink');
  currentLink.addClass('current');
  // Remove the link of the current option
  currentLink.html(currentLink.find('a').text());

  $("a.sam-scoretable-deleteattempt").each(function(){
    this.existingOnclick = this.onclick;
    this.onclick = null;
    $(this).click(function(){
    	if ( confirm("<h:outputText value="#{commonMessages.confirm_delete_attempt}" escape="false"/>") ) {
        this.existingOnclick();
      } else {
        return false;
      }
    });
  });

  var sakaiReminder = new SakaiReminder();
  $('.awesomplete').each(function() {
    new Awesomplete(this, {
      list: sakaiReminder.getAll()
    });
  });
  $('#editTotalResults').submit(function(e) {
    $('textarea.awesomplete').each(function() {
      sakaiReminder.new($(this).val());
    });
  });

});

function showLoadingMessage() {
  let loadingMessageContainer = document.getElementById('editTotalResults:loadingMessage');
  loadingMessageContainer.classList.remove('hidden');
}

</script>
</head>
<body onload="disableIt();<%= request.getAttribute("html.body.onload") %>">
 <div class="portletBody container-fluid">

<!-- content... -->
<h:form id="editTotalResults">
  <h:inputHidden id="publishedId" value="#{totalScores.publishedId}" />
  <h:inputHidden id="itemId" value="#{totalScores.firstItem}" />

  <!-- HEADINGS -->
  <%@ include file="/jsf/evaluation/evaluationHeadings.jsp" %>

  <h:panelGroup layout="block" styleClass="page-header">
    <h1>
      <h:outputText value="#{commonMessages.total_scores}#{evaluationMessages.column} " escape="false"/>
      <small><h:outputText value="#{totalScores.assessmentName} " escape="false"/></small>
    </h1>
  </h:panelGroup>

  <!-- EVALUATION SUBMENU -->
  <%@ include file="/jsf/evaluation/evaluationSubmenu.jsp" %>

  <div class="hide">
    <h:outputText value="#{evaluationMessages.auto_scored_tip}" rendered="#{totalScores.isAutoScored}" />
  </div>

<div class="tier1">
  <h:messages styleClass="sak-banner-error" rendered="#{! empty facesContext.maximumSeverity}" layout="table"/>
  <!-- only shows Max Score Possible if this assessment does not contain random dawn parts -->

  <sakai:flowState bean="#{totalScores}" />

  <h:panelGroup styleClass="max-score-possible" layout="block" rendered="#{!totalScores.hasRandomDrawPart}">
    <h:outputText value="<h2>#{evaluationMessages.max_score_poss}<small>: #{totalScores.maxScore}</small></h2>" escape="false"/>
  </h:panelGroup>

  <h:panelGroup styleClass="apply-grades" layout="block">
    <h:commandButton value="#{evaluationMessages.applyGrades} " id="applyScoreButton" styleClass="active" type="submit" onclick="SPNR.disableControlsAndSpin( this, null );">
      <f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreUpdateListener" />
    </h:commandButton>
    <h:outputText value="&#160;" escape="false" />
    <h:inputText id="applyScoreUnsubmitted" value="#{totalScores.applyToUngraded}"  onkeydown="inIt()" onchange="toPoint(this.id);" size="5"/>
    <h:outputText value=" #{totalScores.allSubmissions ne '4' ? evaluationMessages.applyGradesDesc : evaluationMessages.applyGradesDescAvg}"/>
  </h:panelGroup>

  <h:panelGroup id="export-total-scores" layout="block" styleClass="mt-1 mb-1">
    <h:commandButton value="#{commonMessages.export_action}" action="#{totalScores.exportExcel}"/>
  </h:panelGroup>

<h:panelGroup styleClass="row total-score-box" layout="block" rendered="#{totalScores.anonymous eq 'false'}">

  <h:panelGroup styleClass="col-md-6" layout="block">
    <h:panelGroup styleClass="all-submissions form-group" layout="block">
      <h:outputLabel styleClass="col-md-2" value="#{evaluationMessages.view}"/>
      <h:selectOneMenu value="#{totalScores.allSubmissions}" id="allSubmissionsA1"
        required="true" onchange="showLoadingMessage();document.forms[0].submit();" rendered="#{totalScores.scoringOption eq '4'}">
      <f:selectItem itemValue="3" itemLabel="#{evaluationMessages.all_sub}" />
      <f:selectItem itemValue="4" itemLabel="#{evaluationMessages.average_sub}" />
      <f:valueChangeListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
     </h:selectOneMenu>

     <h:selectOneMenu value="#{totalScores.allSubmissions}" id="allSubmissionsL1"
        required="true" onchange="showLoadingMessage();document.forms[0].submit();" rendered="#{totalScores.scoringOption eq '2'}">
      <f:selectItem itemValue="3" itemLabel="#{evaluationMessages.all_sub}" />
      <f:selectItem itemValue="2" itemLabel="#{evaluationMessages.last_sub}" />
      <f:valueChangeListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
     </h:selectOneMenu>

     <h:selectOneMenu value="#{totalScores.allSubmissions}" id="allSubmissionsH1"
        required="true" onchange="showLoadingMessage();document.forms[0].submit();" rendered="#{totalScores.scoringOption eq '1'}">
      <f:selectItem itemValue="3" itemLabel="#{evaluationMessages.all_sub}" />
      <f:selectItem itemValue="1" itemLabel="#{evaluationMessages.highest_sub}" />
      <f:valueChangeListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
     </h:selectOneMenu>
     
     <!-- SECTION AWARE -->
     <h:outputText value="&nbsp;" escape="false" rendered="#{totalScores.multipleSubmissionsAllowed eq 'true'}"/>
     <h:outputText value="&nbsp;#{evaluationMessages.forAllSectionsGroups}" escape="false" rendered="#{totalScores.availableSectionSize < 1 && totalScores.multipleSubmissionsAllowed eq 'true'}"/>
     <h:outputText value="&nbsp;#{evaluationMessages.all_sections}" escape="false" rendered="#{totalScores.availableSectionSize < 1 && !totalScores.multipleSubmissionsAllowed eq 'true'}"/>
     <h:outputText value="&nbsp;#{evaluationMessages.for_s}&nbsp;&nbsp;" rendered="#{totalScores.availableSectionSize >= 1}" escape="false"/>

        <h:selectOneMenu value="#{totalScores.selectedSectionFilterValue}" id="sectionpicker" required="true" onchange="showLoadingMessage();document.forms[0].submit();" rendered="#{totalScores.availableSectionSize >= 1}">
          <f:selectItems value="#{totalScores.sectionFilterSelectItems}"/>
          <f:valueChangeListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener"/>
        </h:selectOneMenu>

        <h:panelGroup id="loadingMessage" styleClass="hidden">
          <h:panelGroup styleClass="spinner-border spinner-border-sm">
          </h:panelGroup>
          <h:outputText value="#{evaluationMessages.loading_submissions_message}" />
        </h:panelGroup>

      </h:panelGroup>

	  <h:panelGroup styleClass="search-student form-group" layout="block">
      <h:outputLabel styleClass="col-md-2" value="#{evaluationMessages.search}"/>
 	        <h:inputText
				id="searchString"
				value="#{totalScores.searchString}"
				onfocus="clearIfDefaultString(this, '#{evaluationMessages.search_default_student_search_string}')"
				onkeypress="return submitOnEnter(event, 'editTotalResults:searchSubmitButton');"/>
			<h:outputText value="&nbsp;" escape="false" />
			<h:commandButton actionListener="#{totalScores.search}" value="#{evaluationMessages.search_find}" id="searchSubmitButton" />
			<h:outputText value="&nbsp;" escape="false" />
			<h:commandButton actionListener="#{totalScores.clear}" value="#{evaluationMessages.search_clear}"/>
	  </h:panelGroup>
  </h:panelGroup>
   
  <h:panelGroup layout="block" styleClass="samigo-pager col-md-6" style="text-align: right">
    <sakai:pager id="pager1" totalItems="#{totalScores.dataRows}" firstItem="#{totalScores.firstRow}" pageSize="#{totalScores.maxDisplayedRows}" textStatus="#{evaluationMessages.paging_status}" />
  </h:panelGroup>
</h:panelGroup>

<h:panelGroup styleClass="total-scores-anon" layout="block" rendered="#{totalScores.anonymous eq 'true'}">
  <h:panelGroup>
	  <h:outputText value="#{evaluationMessages.view}" rendered="#{totalScores.multipleSubmissionsAllowed eq 'true' }"/>
      <h:panelGroup>
        <h:selectOneMenu value="#{totalScores.allSubmissions}" id="allSubmissionsL2"
         required="true" onchange="document.forms[0].submit();" rendered="#{totalScores.scoringOption eq '2' && totalScores.multipleSubmissionsAllowed eq 'true' }">
        <f:selectItem itemValue="3" itemLabel="#{evaluationMessages.all_sub}" />
        <f:selectItem itemValue="2" itemLabel="#{evaluationMessages.last_sub}" />
        <f:valueChangeListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        </h:selectOneMenu>

        <h:selectOneMenu value="#{totalScores.allSubmissions}" id="allSubmissionsH2"
         required="true" onchange="document.forms[0].submit();" rendered="#{totalScores.scoringOption eq '1' && totalScores.multipleSubmissionsAllowed eq 'true' }">
          <f:selectItem itemValue="3" itemLabel="#{evaluationMessages.all_sub}" />
          <f:selectItem itemValue="1" itemLabel="#{evaluationMessages.highest_sub}" />
          <f:valueChangeListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        </h:selectOneMenu>

		<h:selectOneMenu value="#{totalScores.allSubmissions}" id="allSubmissionsA2" required="true" onchange="document.forms[0].submit();" rendered="#{totalScores.scoringOption eq '4' && totalScores.multipleSubmissionsAllowed eq 'true' }">
		  <f:selectItem itemValue="3" itemLabel="#{evaluationMessages.all_sub}" />
		  <f:selectItem itemValue="4" itemLabel="#{evaluationMessages.average_sub}" />
          <f:valueChangeListener type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
		 </h:selectOneMenu>
      </h:panelGroup>
  </h:panelGroup>
  
  <h:panelGroup>
	<sakai:pager id="pager2" totalItems="#{totalScores.dataRows}" firstItem="#{totalScores.firstRow}" pageSize="#{totalScores.maxDisplayedRows}" textStatus="#{evaluationMessages.paging_status}" />
  </h:panelGroup>
</h:panelGroup>

  <!-- STUDENT RESPONSES AND GRADING -->
  <!-- note that we will have to hook up with the back end to get N at a time -->
<div class="table">
  <h:dataTable id="totalScoreTable" value="#{totalScores.agents}" var="description" styleClass="table table-striped table-bordered" columnClasses="textTable">

	<!-- Add Submission Attempt Deleter-->
	<h:column rendered="#{person.isAdmin || !totalScores.restrictedDelete}">
     <f:facet name="header">
       <h:outputText value="#{commonMessages.delete}" rendered="true" />
     </f:facet>
     <h:panelGroup> <span class="tier2">
       <h:outputText value="<a name=\"" escape="false" />
       <h:outputText value="#{description.lastInitial}" />
       <h:outputText value="\"></a>" escape="false" />

       <h:commandLink styleClass="sam-scoretable-deleteattempt" title="#{commonMessages.delete_attempt}" action="totalScores" immediate="true" rendered="true" >
         <h:panelGroup rendered="#{description.assessmentGradingId ne '-1'}">
	     <span class="fa fa-trash" aria-hidden="true"></span>
	     <span class="sr-only"><h:outputText value="#{commonMessages.delete}" /></span>
         </h:panelGroup>
         <f:actionListener  type="org.sakaiproject.tool.assessment.ui.listener.evaluation.GrantSubmissionListener" />
         <f:actionListener  type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener  type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
         <f:actionListener  type="org.sakaiproject.tool.assessment.ui.listener.author.AuthorActionListener" />
         <f:param name="studentid" value="#{description.idString}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
</span>
     </h:panelGroup>
    </h:column>
    
    <!-- NAME/SUBMISSION ID -->
    <h:column rendered="#{totalScores.anonymous eq 'false' && totalScores.sortType ne 'lastName'}">
     <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortLastName}" immediate="true" id="lastName" action="totalScores">
          <h:outputText value="#{evaluationMessages.name}" />
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="lastName" />
        <f:param name="sortAscending" value="true"/>        
        </h:commandLink>
     </f:facet>
      <sakai-user-photo user-id='<h:outputText value="#{description.agentId}"/>' profile-popup="on"></sakai-user-photo>
     <h:panelGroup>
       <h:outputText value="<a name=\"" escape="false" />
       <h:outputText value="#{description.lastInitial}" />
       <h:outputText value="\"></a>" escape="false" />

         <h:outputText value="#{description.lastName}" rendered="#{description.assessmentGradingId eq '-1' || description.forGrade == 'false' || totalScores.allSubmissions eq'4'}" />
         <h:outputText value=", " rendered="#{(description.assessmentGradingId eq '-1' || description.forGrade == 'false') && description.lastInitial ne 'Anonymous' || totalScores.allSubmissions eq'4'}"/>
         <h:outputText value="#{description.firstName}" rendered="#{description.assessmentGradingId eq '-1' || description.forGrade == 'false'  || totalScores.allSubmissions eq'4'}" />
         <h:outputText value="#{evaluationMessages.na}" rendered="#{description.lastInitial eq 'Anonymous' && (description.assessmentGradingId eq '-1' || description.forGrade == 'false')}" />
       <h:commandLink title="#{evaluationMessages.t_student}" action="studentScores" immediate="true" 
          rendered="#{description.forGrade == 'true' &&  description.assessmentGradingId ne '-1' && totalScores.allSubmissions!='4'}" >
         <h:outputText value="#{description.lastName}" />
         <h:outputText value=", " rendered="#{description.lastInitial ne 'Anonymous'}"/>
         <h:outputText value="#{description.firstName}" />
         <h:outputText value="#{evaluationMessages.na}" rendered="#{description.lastInitial eq 'Anonymous'}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.StudentScoreListener" />
         <f:param name="studentid" value="#{description.idString}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
     </h:panelGroup>
     <span class="itemAction">
       <h:panelGroup rendered="#{description.email != null && description.email != '' && email.fromEmailAddress != null && email.fromEmailAddress != ''}">
         <h:outputText value="<a href=\"mailto:#{description.email}?subject=#{totalScores.assessmentName} #{commonMessages.feedback}\">" escape="false" />
         <h:outputText value="<span class=\"fa fa-envelope\" aria-hidden=\"true\"></span><span class=\"sr-only\">#{evaluationMessages.email}</span></a> " escape="false" />
       </h:panelGroup>
       <h:panelGroup rendered="#{not empty description.alternativeInstructorReviewUrl}">
         <h:outputText value="<a target=\"blank\" href=\"#{description.alternativeInstructorReviewUrl}\"><span class=\"fa fa-video-camera\" aria-hidden=\"true\"></span><span class=\"sr-only\">#{evaluationMessages.instructor_review}</span></a>" escape="false" />
       </h:panelGroup>
     </span>
    </h:column>

    <h:column rendered="#{totalScores.anonymous eq 'false' && totalScores.sortType eq 'lastName' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortLastName}" action="totalScores">
          <h:outputText value="#{evaluationMessages.name}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortLastNameDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
      <sakai-user-photo user-id='<h:outputText value="#{description.agentId}"/>' profile-popup="on"></sakai-user-photo>
     <h:panelGroup>
       <h:outputText value="<a name=\"" escape="false" />
       <h:outputText value="#{description.lastInitial}" />
       <h:outputText value="\"></a>" escape="false" />

         <h:outputText value="#{description.lastName}" rendered="#{description.assessmentGradingId eq '-1' || description.forGrade == 'false' || totalScores.allSubmissions eq'4'}" />
         <h:outputText value=", " rendered="#{(description.assessmentGradingId eq '-1' || description.forGrade == 'false') && description.lastInitial ne 'Anonymous' || totalScores.allSubmissions eq'4'}"/>
         <h:outputText value="#{description.firstName}" rendered="#{description.assessmentGradingId eq '-1' || description.forGrade == 'false' ||totalScores.allSubmissions eq '4'}" />
         <h:outputText value="#{evaluationMessages.na}" rendered="#{description.lastInitial eq 'Anonymous' && (description.assessmentGradingId eq '-1' || description.forGrade == 'false')}" />
       <h:commandLink title="#{evaluationMessages.t_student}" action="studentScores" immediate="true" 
          rendered="#{description.forGrade == 'true' && description.assessmentGradingId ne '-1' &&  totalScores.allSubmissions!='4'}" >
         <h:outputText value="#{description.lastName}" />
         <h:outputText value=", " rendered="#{description.lastInitial ne 'Anonymous'}"/>
         <h:outputText value="#{description.firstName}" />
         <h:outputText value="#{evaluationMessages.na}" rendered="#{description.lastInitial eq 'Anonymous'}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.StudentScoreListener" />
         <f:param name="studentid" value="#{description.idString}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
     </h:panelGroup>
     <span class="itemAction">
       <h:panelGroup rendered="#{description.email != null && description.email != '' && email.fromEmailAddress != null && email.fromEmailAddress != ''}">
         <h:outputText value="<a href=\"mailto:#{description.email}?subject=#{totalScores.assessmentName} #{commonMessages.feedback}\">" escape="false" />
         <h:outputText value="<span class=\"fa fa-envelope\" aria-hidden=\"true\"></span><span class=\"sr-only\">#{evaluationMessages.email}</span></a> " escape="false" />
       </h:panelGroup>
       <h:panelGroup rendered="#{not empty description.alternativeInstructorReviewUrl}">
         <h:outputText value="<a target=\"_blank\" href=\"#{description.alternativeInstructorReviewUrl}\"><span class=\"fa fa-video-camera\" aria-hidden=\"true\"></span><span class=\"sr-only\">#{evaluationMessages.instructor_review}</span></a>" escape="false" />
       </h:panelGroup>
	 </span>

    </h:column>

    <h:column rendered="#{totalScores.anonymous eq 'false' && totalScores.sortType eq 'lastName' && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortLastName}" action="totalScores">
        <h:outputText value="#{evaluationMessages.name}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortLastNameAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
      <sakai-user-photo user-id='<h:outputText value="#{description.agentId}"/>' profile-popup="on"></sakai-user-photo>
            <h:panelGroup>
       <h:outputText value="<a name=\"" escape="false" />
       <h:outputText value="#{description.lastInitial}" />
       <h:outputText value="\"></a>" escape="false" />

         <h:outputText value="#{description.lastName}" rendered="#{description.assessmentGradingId eq '-1' || description.forGrade == 'false'}" />
         <h:outputText value=", " rendered="#{(description.assessmentGradingId eq '-1' || description.forGrade == 'false') && description.lastInitial ne 'Anonymous' || totalScores.allSubmissions eq'4'}"/>
         <h:outputText value="#{description.firstName}" rendered="#{description.assessmentGradingId eq '-1' || description.forGrade == 'false' || totalScores.allSubmissions eq'4' || totalScores.allSubmissions eq'4'}" />
         <h:outputText value="#{evaluationMessages.na}" rendered="#{description.lastInitial eq 'Anonymous' && (description.assessmentGradingId eq '-1' || description.forGrade == 'false')}" />
       <h:commandLink title="#{evaluationMessages.t_student}" action="studentScores" immediate="true" 
          rendered="#{description.forGrade == 'true' && description.assessmentGradingId ne '-1' &&  totalScores.allSubmissions!='4'}" >
         <h:outputText value="#{description.lastName}" />
         <h:outputText value=", " rendered="#{description.lastInitial ne 'Anonymous'}"/>
         <h:outputText value="#{description.firstName}" />
         <h:outputText value="#{evaluationMessages.na}" rendered="#{description.lastInitial eq 'Anonymous'}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.StudentScoreListener" />
         <f:param name="studentid" value="#{description.idString}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
     </h:panelGroup>

     <f:verbatim><br/></f:verbatim>

	 <span class="itemAction">
	  <h:panelGroup rendered="#{description.email != null && description.email != '' && email.fromEmailAddress != null && email.fromEmailAddress != ''}">
		 <h:outputText value="<a href=\"mailto:" escape="false" />
	     <h:outputText value="#{description.email}" />
	     <h:outputText value="?subject=" escape="false" />
		 <h:outputText value="#{totalScores.assessmentName} #{commonMessages.feedback}\">" escape="false" />
         <h:outputText value="  #{evaluationMessages.email}" escape="false"/>
         <h:outputText value="</a>" escape="false" />
	   </h:panelGroup>
	 </span>
	</h:column>
    

    <!-- ANONYMOUS and ASSESSMENTGRADINGID -->
    <h:column rendered="#{totalScores.anonymous eq 'true' && totalScores.sortType ne 'assessmentGradingId'}">
     <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortSubmissionId}" action="totalScores" >
          <h:outputText value="#{evaluationMessages.sub_id}" />
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="assessmentGradingId" />
        <f:param name="sortAscending" value="true"/>
        </h:commandLink>
     </f:facet>
     <h:panelGroup >
       <h:commandLink title="#{evaluationMessages.t_student}" action="studentScores" rendered="#{totalScores.allSubmissions != '4' && description.assessmentGradingId != -1}">
         <h:outputText value="#{description.assessmentGradingId}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.StudentScoreListener" />
         <f:param name="studentid" value="#{description.idString}"/>
         <f:param name="studentName" value="#{description.assessmentGradingId}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
       <h:outputText rendered="#{totalScores.allSubmissions eq '4' && description.assessmentGradingId != -1}" value="#{description.assessmentGradingId}" />
       <h:outputText rendered="#{totalScores.allSubmissions != '4' && description.assessmentGradingId == -1}" value="#{evaluationMessages.na}" />
     </h:panelGroup>
    </h:column>

    <h:column rendered="#{totalScores.anonymous eq 'true' && totalScores.sortType eq 'assessmentGradingId' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortSubmissionId}" action="totalScores">
          <h:outputText value="#{evaluationMessages.sub_id}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortSubmissionIdDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
     <h:panelGroup>
       <h:commandLink title="#{evaluationMessages.t_student}" action="studentScores" immediate="true" rendered="#{totalScores.allSubmissions != '4' && description.assessmentGradingId != -1}">
         <h:outputText value="#{description.assessmentGradingId}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.StudentScoreListener" />
         <f:param name="studentid" value="#{description.idString}" />
         <f:param name="studentName" value="#{description.assessmentGradingId}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
       <h:outputText rendered="#{totalScores.allSubmissions eq '4' && description.assessmentGradingId != -1}" value="#{description.assessmentGradingId}" />
       <h:outputText rendered="#{totalScores.allSubmissions != '4' && description.assessmentGradingId == -1}" value="#{evaluationMessages.na}" />
     </h:panelGroup>
    </h:column>
    
    <h:column rendered="#{totalScores.anonymous eq 'true' && totalScores.sortType eq 'assessmentGradingId' && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortSubmissionId}" action="totalScores">
        <h:outputText value="#{evaluationMessages.sub_id}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortSubmissionIdAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
     <h:panelGroup>
       <h:commandLink title="#{evaluationMessages.t_student}" action="studentScores" immediate="true" rendered="#{totalScores.allSubmissions != '4' && description.assessmentGradingId != -1}">
         <h:outputText value="#{description.assessmentGradingId}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.StudentScoreListener" />
         <f:param name="studentid" value="#{description.idString}" />
         <f:param name="studentName" value="#{description.assessmentGradingId}" />
         <f:param name="publishedIdd" value="#{totalScores.publishedId}" />
         <f:param name="gradingData" value="#{description.assessmentGradingId}" />
       </h:commandLink>
       <h:outputText rendered="#{totalScores.allSubmissions eq '4' && description.assessmentGradingId != -1}" value="#{description.assessmentGradingId}" />
       <h:outputText rendered="#{totalScores.allSubmissions != '4' && description.assessmentGradingId == -1}" value="#{evaluationMessages.na}" />
     </h:panelGroup>
    </h:column>
 

   <!-- STUDENT ID -->
    <h:column rendered="#{totalScores.anonymous eq 'false' && totalScores.sortType!='agentDisplayId'}" >
     <f:facet name="header">
       <h:commandLink title="#{evaluationMessages.t_sortUserId}" id="agentDisplayId" action="totalScores" >
          <h:outputText value="#{evaluationMessages.uid}" />
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="agentDisplayId" />
        <f:param name="sortAscending" value="true"/>
        </h:commandLink>
     </f:facet>
        <h:outputText value="#{description.agentDisplayId}" />
    </h:column>

    <h:column rendered="#{totalScores.anonymous eq 'false' && totalScores.sortType eq 'agentDisplayId' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortUserId}" action="totalScores">
          <h:outputText value="#{evaluationMessages.uid}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortUserIdDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
        <h:outputText value="#{description.agentDisplayId}" />
    </h:column>
    
    <h:column rendered="#{totalScores.anonymous eq 'false' && totalScores.sortType eq 'agentDisplayId' && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortUserId}" action="totalScores">
        <h:outputText value="#{evaluationMessages.uid}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortUserIdAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
        <h:outputText value="#{description.agentDisplayId}" />
    </h:column>
 

    <!-- ROLE -->
    <h:column rendered="#{totalScores.sortType ne 'role'}">
     <f:facet name="header" >
        <h:commandLink title="#{evaluationMessages.t_sortRole}" id="role" action="totalScores">
          <h:outputText value="#{evaluationMessages.role}" />
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="role" />
        <f:param name="sortAscending" value="true"/>
        </h:commandLink>
     </f:facet>
        <h:outputText value="#{description.role}" />
    </h:column>

    <h:column rendered="#{totalScores.sortType=='role' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortRole}" action="totalScores">
          <h:outputText value="#{evaluationMessages.role}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortRoleDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
       <h:outputText value="#{description.role}" />
    </h:column>
    
    <h:column rendered="#{totalScores.sortType=='role'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortRole}" action="totalScores">
        <h:outputText value="#{evaluationMessages.role}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortRoleAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
       <h:outputText value="#{description.role}" />
    </h:column>
    

    <!-- DATE -->
    <h:column rendered="#{totalScores.sortType!='submittedDate' && totalScores.allSubmissions!='4'}">
     <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortSubmittedDate}" id="submittedDate" action="totalScores">
          <h:outputText value="#{evaluationMessages.submit_date}" />
        <f:actionListener
          type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="submittedDate" />
        <f:param name="sortAscending" value="true"/>
        </h:commandLink>
     </f:facet>
        <h:outputText value="#{description.submittedDate}" rendered="#{description.attemptDate != null}" >
          <f:convertDateTime dateStyle="medium" timeStyle="short" timeZone="#{author.userTimeZone}" />
        </h:outputText>
        <h:panelGroup rendered="#{description.attemptDate != null}">
          <h:panelGroup rendered="#{description.isLate == 'true' && ((description.isAutoSubmitted == 'false' && !(totalScores.isTimedAssessment eq 'true' && totalScores.acceptLateSubmission eq 'false'))
                                      || (description.isAutoSubmitted == 'true' && totalScores.acceptLateSubmission eq 'true' && totalScores.isTimedAssessment ne 'true'))}">
            <f:verbatim><br/></f:verbatim>
            <h:outputText style="color:red" value="#{evaluationMessages.late}"/>
          </h:panelGroup>
          <h:panelGroup rendered="#{description.isAutoSubmitted == 'true' && totalScores.isTimedAssessment ne 'true' && (description.isLate == 'false' || totalScores.acceptLateSubmission eq 'true')}">
            <f:verbatim><br/></f:verbatim>
            <h:outputText style="color:red" value="#{evaluationMessages.auto_submit}"/>
          </h:panelGroup>
        </h:panelGroup>

      <h:outputText value="#{evaluationMessages.no_submission}" rendered="#{description.attemptDate == null}"/>
    </h:column>

    <h:column rendered="#{totalScores.sortType=='submittedDate' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortSubmittedDate}" action="totalScores">
          <h:outputText value="#{evaluationMessages.submit_date}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortSubmittedDateDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
        <h:outputText value="#{description.submittedDate}" rendered="#{description.attemptDate != null}" >
          <f:convertDateTime dateStyle="medium" timeStyle="short" timeZone="#{author.userTimeZone}" />
        </h:outputText>
        <h:panelGroup rendered="#{description.attemptDate != null}">
          <h:panelGroup rendered="#{description.isLate == 'true' && ((description.isAutoSubmitted == 'false' && !(totalScores.isTimedAssessment eq 'true' && totalScores.acceptLateSubmission eq 'false'))
                                      || (description.isAutoSubmitted == 'true' && totalScores.acceptLateSubmission eq 'true' && totalScores.isTimedAssessment ne 'true'))}">
            <f:verbatim><br/></f:verbatim>
            <h:outputText style="color:red" value="#{evaluationMessages.late}"/>
          </h:panelGroup>
          <h:panelGroup rendered="#{description.isAutoSubmitted == 'true' && totalScores.isTimedAssessment ne 'true' && (description.isLate == 'false' || totalScores.acceptLateSubmission eq 'true')}">
            <f:verbatim><br/></f:verbatim>
            <h:outputText style="color:red" value="#{evaluationMessages.auto_submit}"/>
          </h:panelGroup>
        </h:panelGroup>

        <h:outputText value="#{evaluationMessages.no_submission}" rendered="#{description.attemptDate == null}"/>
    </h:column>
    
    <h:column rendered="#{totalScores.sortType=='submittedDate'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortSubmittedDate}" action="totalScores">
        <h:outputText value="#{evaluationMessages.submit_date}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortSubmittedDateAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
        <h:outputText value="#{description.submittedDate}" rendered="#{description.attemptDate != null}" >
          <f:convertDateTime dateStyle="medium" timeStyle="short" timeZone="#{author.userTimeZone}" />
        </h:outputText>
        <h:panelGroup rendered="#{description.attemptDate != null}">
          <h:panelGroup rendered="#{description.isLate == 'true' && ((description.isAutoSubmitted == 'false' && !(totalScores.isTimedAssessment eq 'true' && totalScores.acceptLateSubmission eq 'false'))
                                      || (description.isAutoSubmitted == 'true' && totalScores.acceptLateSubmission eq 'true' && totalScores.isTimedAssessment ne 'true'))}">
            <f:verbatim><br/></f:verbatim>
            <h:outputText style="color:red" value="#{evaluationMessages.late}"/>
          </h:panelGroup>
          <h:panelGroup rendered="#{description.isAutoSubmitted == 'true' && totalScores.isTimedAssessment ne 'true' && (description.isLate == 'false' || totalScores.acceptLateSubmission eq 'true')}">
            <f:verbatim><br/></f:verbatim>
            <h:outputText style="color:red" value="#{evaluationMessages.auto_submit}"/>
          </h:panelGroup>
        </h:panelGroup>

        <h:outputText value="#{evaluationMessages.no_submission}" rendered="#{description.attemptDate == null}"/>
    </h:column>

    <!-- ANSWERS SUMMARY FOR ONE SELECTION TYPE -->
    <h:column rendered="#{totalScores.isOneSelectionType}">
      <f:facet name="header">
        <h:outputText value="#{evaluationMessages.answers_title}" escape="false"/>
      </f:facet>
      <h:panelGroup rendered="#{description.attemptDate != null}">
        <div>
          <h:outputText value="#{totalScores.results[description.assessmentGradingId][0]}"/>&nbsp;/&nbsp;
          <h:outputText value="#{totalScores.results[description.assessmentGradingId][1]}"/>&nbsp;/&nbsp;
          <h:outputText value="#{totalScores.results[description.assessmentGradingId][2]}"/>
        </div>
      </h:panelGroup>
    </h:column>

    <!-- TIME -->
    <h:column rendered="#{totalScores.isTimedAssessment && totalScores.sortType!='timeElapsed'}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortTime}" id="time" action="totalScores">
          <h:outputText value="#{evaluationMessages.time}" />
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="timeElapsed" />
        <f:param name="sortAscending" value="true"/>
        </h:commandLink>
      </f:facet>
      <h:outputText value="#{description.formattedTimeElapsed}" />
    </h:column>

	<h:column rendered="#{totalScores.isTimedAssessment && totalScores.sortType=='timeElapsed' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortTime}" action="totalScores">
          <h:outputText value="#{evaluationMessages.time}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortTimeDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
      <h:outputText value="#{description.formattedTimeElapsed}" />
    </h:column>
    
    <h:column rendered="#{totalScores.isTimedAssessment && totalScores.sortType=='timeElapsed'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortTime}" action="totalScores">
        <h:outputText value="#{evaluationMessages.time}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortTimeAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
      <h:outputText value="#{description.formattedTimeElapsed}" />
    </h:column>

    <!-- TOTAL -->
    <h:column rendered="#{totalScores.sortType!='totalAutoScore' && totalScores.allSubmissions!='4'}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortScore}" id="totalAutoScore" action="totalScores">
          <h:outputText value="#{evaluationMessages.score}" />
          <f:param name="sortBy" value="totalAutoScore" />
          <f:param name="sortAscending" value="true"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        </h:commandLink>
      </f:facet>
      <h:outputText value="#{description.roundedTotalAutoScore}" />
    </h:column>

    <h:column rendered="#{totalScores.sortType=='totalAutoScore' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortScore}" action="totalScores">
          <h:outputText value="#{evaluationMessages.score}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortAdjustScoreDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
      <h:outputText value="#{description.roundedTotalAutoScore}" />
    </h:column>
    
    <h:column rendered="#{totalScores.sortType=='totalAutoScore'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortScore}" action="totalScores">
        <h:outputText value="#{evaluationMessages.score}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortAdjustScoreAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
      <h:outputText value="#{description.roundedTotalAutoScore}" />
    </h:column>
    
    <!-- ADJUSTMENT -->
    <h:column rendered="#{totalScores.sortType!='totalOverrideScore' && totalScores.allSubmissions!='4'}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortAdjustScore}" id="totalOverrideScore" action="totalScores">
    	    <h:outputText value="#{evaluationMessages.adjustment}" />
        	<f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
	        <f:param name="sortBy" value="totalOverrideScore" />
	        <f:param name="sortAscending" value="true"/>
        </h:commandLink>
      </f:facet>
      <h:inputText value="#{description.totalOverrideScore}" size="5" id="adjustTotal" required="false" onchange="toPoint(this.id);" />
   </h:column>


    <h:column rendered="#{totalScores.sortType=='totalOverrideScore' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortAdjustScore}" action="totalScores">
          <h:outputText value="#{evaluationMessages.adjustment}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortScoreDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
      <h:inputText value="#{description.totalOverrideScore}" size="5" id="adjustTotal2" required="false" onchange="toPoint(this.id);" />
   </h:column>
    
    <h:column rendered="#{totalScores.sortType=='totalOverrideScore'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortAdjustScore}" action="totalScores">
        <h:outputText value="#{evaluationMessages.adjustment}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortScoreAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
      <h:inputText value="#{description.totalOverrideScore}" size="5" id="adjustTotal3" required="false" onchange="toPoint(this.id);" />
    </h:column>

    <!-- SUBMISSION COUNT (AVERAGE SCORE VIEW) -->
    <h:column rendered="#{totalScores.allSubmissions eq '4' && totalScores.sortType!='submissionCount'}">
     <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortSubmissionCount}" id="submissionCount" action="totalScores" >
        <h:outputText value="#{evaluationMessages.sub_count}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="submissionCount" />
        <f:param name="sortAscending" value="true"/>
      </h:commandLink>
     </f:facet>
        <h:outputText value="#{description.submissionCount}" />
    </h:column>

    <h:column rendered="#{totalScores.allSubmissions eq '4' && totalScores.sortType=='submissionCount' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortSubmissionCount}" action="totalScores">
          <h:outputText value="#{evaluationMessages.sub_count}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortSubmissionCountDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>
      </f:facet>
      <h:outputText value="#{description.submissionCount}" />
    </h:column>

    <h:column rendered="#{totalScores.allSubmissions eq '4' && totalScores.sortType=='submissionCount'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortSubmissionCount}" action="totalScores">
        <h:outputText value="#{evaluationMessages.sub_count}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortSubmissionCountAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink>
      </f:facet>
      <h:outputText value="#{description.submissionCount}" />
    </h:column>

    <!-- FINAL SCORE -->
    <h:column rendered="#{totalScores.sortType!='finalScore'}">
     <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortFinalScore}" id="finalScore" action="totalScores" >
        <h:outputText value="#{evaluationMessages.tot}" />
         <f:actionListener
            type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
        <f:param name="sortBy" value="finalScore" />
        <f:param name="sortAscending" value="true"/>
      </h:commandLink>
     </f:facet>
        <h:outputText value="#{description.roundedFinalScore}" />
    </h:column>

    <h:column rendered="#{totalScores.sortType=='finalScore' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:commandLink title="#{evaluationMessages.t_sortFinalScore}" action="totalScores">
          <h:outputText value="#{evaluationMessages.tot}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortFinalScoreDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
          </h:commandLink>    
      </f:facet>
      <h:outputText value="#{description.roundedFinalScore}" />
    </h:column>
    
    <h:column rendered="#{totalScores.sortType=='finalScore'  && !totalScores.sortAscending}">
      <f:facet name="header">
      <h:commandLink title="#{evaluationMessages.t_sortFinalScore}" action="totalScores">
        <h:outputText value="#{evaluationMessages.tot}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortFinalScoreAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
      </h:commandLink> 
      </f:facet>
      <h:outputText value="#{description.roundedFinalScore}" />
    </h:column>


    <!-- COMMENT -->
    <h:column rendered="#{totalScores.sortType!='comments' && totalScores.allSubmissions!='4'}">
     <f:facet name="header">
      <h:panelGroup>
	  <h:commandLink title="#{evaluationMessages.t_sortCommentsForStudent}" id="comments" action="totalScores">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />    
        <h:outputText value="#{evaluationMessages.comment_for_student}"/>
        <f:param name="sortBy" value="comments" />
        <f:param name="sortAscending" value="true"/>
      </h:commandLink>
	  
	  <h:outputText value="&nbsp;&nbsp;" escape="false"/>
	  
	  <h:outputLink title="#{evaluationMessages.whats_this_link}" value="#" onclick="javascript:window.open('../evaluation/totalScoresCommentPopUp.faces','CommentForStudent','width=510,height=515,scrollbars=yes, resizable=yes');" onkeypress="javascript:window.open('../evaluation/totalScoresCommentPopUp.faces','CommentForStudent','width=510,height=515,scrollbars=yes, resizable=yes');" >
            <h:outputText  value="#{evaluationMessages.whats_this_link}"/>
      </h:outputLink>
	  </h:panelGroup>
     </f:facet>

   <h:inputTextarea value="#{description.comments}" rows="3" cols="30" rendered="#{description.attemptDate != null}" styleClass="awesomplete" />
   <h:inputTextarea value="#{evaluationMessages.requires_student_submission}" rows="3" styleClass="disabled awesomplete" disabled="true" cols="30" rendered="#{description.attemptDate == null}"/>
   <h:panelGroup rendered="#{description.attemptDate != null}">
   		<%@ include file="/jsf/evaluation/totalScoresAttachment.jsp" %>
   </h:panelGroup>
    </h:column>

    <h:column rendered="#{totalScores.sortType=='comments' && totalScores.sortAscending}">
      <f:facet name="header">
        <h:panelGroup>
        <h:commandLink title="#{evaluationMessages.t_sortCommentsForStudent}" action="totalScores">
          <h:outputText value="#{evaluationMessages.comment_for_student}" />
          <f:param name="sortAscending" value="false" />
          <h:graphicImage alt="#{evaluationMessages.alt_sortCommentDescending}" rendered="#{totalScores.sortAscending}" url="/images/sortascending.gif"/>
          <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
  	    </h:commandLink>   
		<h:outputText value="&nbsp;&nbsp;" escape="false"/>
	  
        <h:outputLink title="#{evaluationMessages.whats_this_link}" value="#" onclick="javascript:window.open('../evaluation/totalScoresCommentPopUp.faces','CommentForStudent','width=510,height=515,scrollbars=yes, resizable=yes');" onkeypress="javascript:window.open('../evaluation/totalScoresCommentPopUp.faces','CommentForStudent','width=510,height=515,scrollbars=yes, resizable=yes');" >
            <h:outputText  value="#{evaluationMessages.whats_this_link}"/>
        </h:outputLink>
	  </h:panelGroup>
      </f:facet>
   <h:inputTextarea value="#{description.comments}" rows="3" cols="30" rendered="#{description.attemptDate != null}"/>
   <h:inputTextarea value="#{evaluationMessages.requires_student_submission}" rows="3" styleClass="disabled" disabled="true" cols="30" rendered="#{description.attemptDate == null}"/>
   <h:panelGroup rendered="#{description.attemptDate != null}">
   		<%@ include file="/jsf/evaluation/totalScoresAttachment.jsp" %>
   </h:panelGroup>
    </h:column>
    
    <h:column rendered="#{totalScores.sortType=='comments'  && !totalScores.sortAscending}">
      <f:facet name="header">
     <h:panelGroup>
      <h:commandLink title="#{evaluationMessages.t_sortCommentsForStudent}" action="totalScores">
        <h:outputText value="#{evaluationMessages.comment_for_student}" />
        <f:param name="sortAscending" value="true"/>
        <h:graphicImage alt="#{evaluationMessages.alt_sortCommentAscending}" rendered="#{!totalScores.sortAscending}" url="/images/sortdescending.gif"/>
        <f:actionListener
             type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />              
      </h:commandLink> 
	  <h:outputText value="&nbsp;&nbsp;" escape="false"/>
	  
	  <h:outputLink title="#{evaluationMessages.whats_this_link}" value="#" onclick="javascript:window.open('../evaluation/totalScoresCommentPopUp.faces','CommentForStudent','width=510,height=515,scrollbars=yes, resizable=yes');" onkeypress="javascript:window.open('../evaluation/totalScoresCommentPopUp.faces','CommentForStudent','width=510,height=515,scrollbars=yes, resizable=yes');" >
            <h:outputText  value="#{evaluationMessages.whats_this_link}"/>
      </h:outputLink>
	  </h:panelGroup>
      </f:facet>
   <h:inputTextarea value="#{description.comments}" rows="3" cols="30" rendered="#{description.attemptDate != null}"/>
   <h:inputTextarea value="#{evaluationMessages.requires_student_submission}" rows="3" styleClass="disabled" disabled="true" cols="30" rendered="#{description.attemptDate == null}"/>
   <h:panelGroup rendered="#{description.attemptDate != null}" >
   		<%@ include file="/jsf/evaluation/totalScoresAttachment.jsp" %>
   </h:panelGroup>
    </h:column>
  </h:dataTable>

<h:outputText value="#{evaluationMessages.mult_sub_highest}" rendered="#{totalScores.scoringOption eq '1'&& totalScores.multipleSubmissionsAllowed eq 'true' }"/>
<h:outputText value="#{evaluationMessages.mult_sub_last}" rendered="#{totalScores.scoringOption eq '2' && totalScores.multipleSubmissionsAllowed eq 'true' }"/>
<h:outputText value="#{evaluationMessages.mult_sub_average}" rendered="#{totalScores.scoringOption eq '4' && totalScores.multipleSubmissionsAllowed eq 'true' }"/>
</div>
<p class="act">

   <%-- <h:commandButton value="#{evaluationMessages.save_exit}" action="author"/> --%>
   <h:commandButton styleClass="active" value="#{evaluationMessages.save_cont}" action="totalScores" type="submit" rendered="#{totalScores.allSubmissions!='4'}">
      <f:actionListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreUpdateListener" />
      <f:actionListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetTotalScoreListener" />
      <f:actionListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.TotalScoreListener" />
   </h:commandButton>
   <h:commandButton value="#{commonMessages.cancel_action}" action="author">
      <f:actionListener
         type="org.sakaiproject.tool.assessment.ui.listener.evaluation.ResetResultsCalculatedListener" />
   </h:commandButton>

</p>
</div>
</h:form>

</div>
  <!-- end content -->
      </body>
    </html>
  </f:view>
