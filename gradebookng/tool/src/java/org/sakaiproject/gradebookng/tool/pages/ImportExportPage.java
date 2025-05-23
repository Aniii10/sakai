/**
 * Copyright (c) 2003-2017 The Apereo Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://opensource.org/licenses/ecl2
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sakaiproject.gradebookng.tool.pages;

import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.feedback.ExactLevelFeedbackMessageFilter;
import org.apache.wicket.feedback.FeedbackMessage;
import org.apache.wicket.feedback.IFeedbackMessageFilter;
import org.apache.wicket.markup.head.IHeaderResponse;
import org.apache.wicket.markup.html.WebMarkupContainer;

import org.sakaiproject.gradebookng.tool.component.GbFeedbackPanel;
import org.sakaiproject.gradebookng.tool.panels.importExport.GradeImportUploadStep;
import org.sakaiproject.portal.util.PortalUtils;

/**
 * Import Export page
 *
 * @author Steve Swinsburg (steve.swinsburg@gmail.com)
 *
 */
public class ImportExportPage extends BasePage {

	private static final long serialVersionUID = 1L;

	public WebMarkupContainer container;

	private String gradebookUid;
	private String siteId;

	// Confirmation page displays both SUCCESS and ERROR messages.
	// GbFeedbackPanels are styled with a single uniform background colour to represent a single 'error level' state.
	// Since multiple 'error level' states are present, it looks best separated as two different panels
	public final GbFeedbackPanel nonErrorFeedbackPanel = (GbFeedbackPanel) new GbFeedbackPanel("nonErrorFeedbackPanel").setFilter(new IFeedbackMessageFilter() {
		@Override
		public boolean accept(FeedbackMessage message) {
			return FeedbackMessage.ERROR != message.getLevel();
		}
	});

	public final GbFeedbackPanel errorFeedbackPanel = (GbFeedbackPanel) new GbFeedbackPanel("errorFeedbackPanel").setFilter(new ExactLevelFeedbackMessageFilter(FeedbackMessage.ERROR));

	public ImportExportPage() {

		defaultRoleChecksForInstructorOnlyPage();

		disableLink(this.importExportPageLink);

		gradebookUid = getCurrentGradebookUid();
		siteId = getCurrentSiteId();

		container = new WebMarkupContainer("gradebookImportExportContainer");
		container.setOutputMarkupId(true);
		GradeImportUploadStep gius = new GradeImportUploadStep("wizard");
		gius.setCurrentGradebookAndSite(gradebookUid, siteId);
		container.add(gius);
		add(container);

		// hide BasePage's feedback panel and use the error/nonError filtered feedback panels
		feedbackPanel.setVisibilityAllowed(false);
		add(nonErrorFeedbackPanel);
		add(errorFeedbackPanel);
	}

	@Override
	public void clearFeedback() {
		feedbackPanel.clear();
		nonErrorFeedbackPanel.clear();
		errorFeedbackPanel.clear();
	}

	public void updateFeedback(AjaxRequestTarget target) {
		target.add(nonErrorFeedbackPanel);
		target.add(errorFeedbackPanel);
	}
}
