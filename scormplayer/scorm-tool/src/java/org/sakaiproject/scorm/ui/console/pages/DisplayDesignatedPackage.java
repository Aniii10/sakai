package org.sakaiproject.scorm.ui.console.pages;

import java.util.List;
import java.util.Properties;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.wicket.PageMap;
import org.apache.wicket.PageParameters;
import org.apache.wicket.ResourceReference;
import org.apache.wicket.markup.html.IHeaderContributor;
import org.apache.wicket.markup.html.IHeaderResponse;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.link.PageLink;
import org.apache.wicket.markup.html.link.PopupSettings;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.spring.injection.annot.SpringBean;
import org.sakaiproject.component.cover.ComponentManager;
import org.sakaiproject.scorm.api.ScormConstants;
import org.sakaiproject.scorm.model.api.ContentPackage;
import org.sakaiproject.scorm.service.api.LearningManagementSystem;
import org.sakaiproject.scorm.service.api.ScormContentService;
import org.sakaiproject.scorm.service.api.ScormResourceService;
import org.sakaiproject.scorm.ui.player.pages.PlayerPage;
import org.sakaiproject.scorm.ui.reporting.pages.LearnerResultsPage;
import org.sakaiproject.tool.api.ToolManager;
import org.sakaiproject.wicket.markup.html.SakaiPortletWebPage;

public class DisplayDesignatedPackage extends SakaiPortletWebPage implements IHeaderContributor, ScormConstants {
    @Override
    public void renderHead(IHeaderResponse response) {
        super.renderHead(response);
        response.renderCSSReference(new ResourceReference(DisplayDesignatedPackage.class, "DisplayDesignatedPackage.css"));
    }

    private static Log log = LogFactory.getLog(DisplayDesignatedPackage.class);
    
    public static final String CFG_PACKAGE_NAME = "scorm.package";
    public static final String CFG_PACKAGE_NAME_UNDEFINED = "undefined";
    
    @SpringBean
    LearningManagementSystem lms;
    @SpringBean
    ScormContentService contentService;
    ScormResourceService resourceService;
    
    public class ComponentStrings {
        String pageTitle;
    }
    
    private void showPackagesDebugInformation(List<ContentPackage> packages) {
        if( (null != packages) && (!packages.isEmpty()) ) {
            for(ContentPackage pack : packages) {
                log.debug("resource found: [id=" + pack.getResourceId() + ", title=" + pack.getTitle() + ", url=" + pack.getUrl() + "]");
            }
        } else {
            log.debug("No resources have been found by the SCORM content service. Resources are empty.");
        }
    }
    
    private ContentPackage getDesignatedPackage(List<ContentPackage> availablePackages) {
        ContentPackage retval = null;
        String packageFilename = null;
        
        ToolManager toolManager = (ToolManager)ComponentManager.get(ToolManager.class);
        if(null != toolManager) {
            Properties cfgPlacement = toolManager.getCurrentPlacement().getPlacementConfig();
            packageFilename = cfgPlacement.getProperty( CFG_PACKAGE_NAME );
            // check that the property was set in the tool, otherwise show a configuration error
            if( (null != packageFilename) && ( !CFG_PACKAGE_NAME_UNDEFINED.equals(packageFilename) )) {
                log.debug("Package name " + packageFilename + " was found in configuration.");
                // find configured package amongst the packages available in our list of resources
                retval = findDesignatedPackage(availablePackages, packageFilename);
            } else {
                String msg = getLocalizer().getString("designated.resource.notconfigured", this, CFG_PACKAGE_NAME);
                error( msg );
                //log.warn("This SCORM player is NOT YET configured to play a designated package. Please to the tool properties and configure the property named 'scorm.package'");
            }
        } else {
            log.warn("toolManager could not be obtained");
        }
        
        if(null == retval) {
            String msg = getLocalizer().getString("designated.resource.notfound", this, packageFilename);
            error( msg );
            //log.debug("The configured package " +packageFilename+ " is not available as a site resource.");
        }
        
        return retval;
    }
    
    protected PageParameters getParametersForPackage(ContentPackage pkg) {
        PageParameters params = new PageParameters();
        params.add("contentPackageId", ""+pkg.getContentPackageId());
        params.add("resourceId", pkg.getResourceId());
        String title = pkg.getTitle();
        params.add("title", title);        
        return params;
    }
    
    protected PageParameters getParametersForPersonalResults(ContentPackage pkg) {
        PageParameters params = new PageParameters();
        params.add("contentPackageId", ""+pkg.getContentPackageId());
        params.add("learnerId", lms.currentLearnerId());
        params.add("no-toolbar", "true");
        
        return params;
    }
    
    public DisplayDesignatedPackage() {
        log.debug("DisplayDesignatedPackage page entered...");
        ComponentStrings strs = new ComponentStrings();
        strs.pageTitle = "undefined";
        
        // get capabilities
        final String context = lms.currentContext();
        final boolean canConfigure = lms.canConfigure(context);
        final boolean canViewResults = lms.canViewResults(context);
        final boolean canLaunch = lms.canLaunch(context);
        final boolean canDelete = lms.canDelete(context);
        
        List<ContentPackage> contentPackages = contentService.getContentPackages();
        showPackagesDebugInformation(contentPackages);

        ContentPackage match = getDesignatedPackage( contentPackages ); 
        if( null != match ) {
            // if designated package is found then render the page properly
            strs.pageTitle = match.getTitle();
        }

        // add components
        add( new FeedbackPanel("feedback"));
        add( new Label("page.title", match.getTitle()));

        addActionLinksForPackage( match );
    }
    
    /**
     * @param pkg
     */
    protected void addActionLinksForPackage(ContentPackage pkg) {

    	PlayerPage playerPage = new PlayerPage(getParametersForPackage(pkg));
    	Link lnkGo = new PageLink("lnk_go", playerPage);
    	
        //Link lnkGo = new BookmarkablePageLink("lnk_go", PlayerPage.class, getParametersForPackage(pkg) );
        if (StringUtils.isNotBlank(pkg.getTitle())) {
        	
        	String title = pkg.getTitle();
        	
            PopupSettings popupSettings = new PopupSettings(PageMap.forName(title), PopupSettings.RESIZABLE);
            popupSettings.setWidth(1020);
            popupSettings.setHeight(740);
            
            popupSettings.setWindowName(title);
            
            lnkGo.setPopupSettings(popupSettings);
        }
        
        lnkGo.setEnabled(true);
        lnkGo.setVisible(true);
        
        PageParameters params = getParametersForPackage(pkg);
        params.add("no-toolbar", "true");
        
        PackageConfigurationPage packageConfigurationPage = new PackageConfigurationPage(params);
        Link lnkConfigure = new PageLink("lnk_configure", packageConfigurationPage) {
            public boolean isVisible() {
                String context = lms.currentContext();
                return lms.canConfigure(context);
            }
        };
        
        // the following link points to the results page for the designated package
        /*
        if (canViewResults) {
            actionColumn.addAction(new Action(new StringResourceModel("column.action.grade.label", this, null), LearnerResultsPage.class, paramPropertyExpressions));
        }
        */
        LearnerResultsPage learnerResultsPage = new LearnerResultsPage(getParametersForPersonalResults(pkg));
        Link lnkResults = new PageLink("lnk_results", learnerResultsPage) {
            public boolean isVisible() {
                String context = lms.currentContext();
                return lms.canViewResults(context);
            }
        };

        // add links to page
        add( lnkGo );
        add( lnkConfigure );
        add( lnkResults );
    }

    /**
     * Tries to match the designated package name with the Scorm resource, using the Resource ID as matching criterium
     * 
     * @param packages Available SCORM packages
     * @param designated 
     * @return resource id to match
     */
    public ContentPackage findDesignatedPackage(List<ContentPackage> packages, String designated) {
        ContentPackage retval = null;
        
        for(ContentPackage pack : packages) {
            if( designated.equals(pack.getResourceId()) ) {
                retval = pack;
            }
        }
        return retval;
    }
    
    public ScormResourceService getResourceService() {
        return resourceService;
    }

    public void setResourceService(ScormResourceService resourceService) {
        this.resourceService = resourceService;
    }
    
    /**
     * @param contentPackage
     * @return
     */
//    private String getEscapedPackageTitle(ContentPackage contentPackage) {
//    	String title = contentPackage.getTitle();
//    	
//    	if (StringUtils.isNotBlank(title)) {
//    		title = title.replace(":", "-");
//    	}
//    	return title;
//    }

} // class