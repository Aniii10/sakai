/**********************************************************************************
 * $URL$
 * $Id$
 ***********************************************************************************
 *
 * Copyright (c) 2003, 2004, 2005, 2006, 2007, 2008 The Sakai Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.osedu.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

package org.sakaiproject.search.elasticsearch;

import static org.opensearch.index.query.QueryBuilders.boolQuery;
import static org.opensearch.index.query.QueryBuilders.termQuery;
import static org.opensearch.index.query.QueryBuilders.termsQuery;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimerTask;
import java.util.stream.Collectors;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.opensearch.action.bulk.BulkRequest;
import org.opensearch.action.delete.DeleteRequest;
import org.opensearch.action.index.IndexRequest;
import org.opensearch.action.search.SearchRequest;
import org.opensearch.action.search.SearchResponse;
import org.opensearch.action.search.SearchType;
import org.opensearch.client.RequestOptions;
import org.opensearch.index.query.BoolQueryBuilder;
import org.opensearch.index.query.QueryBuilder;
import org.opensearch.search.SearchHit;
import org.opensearch.search.SearchHits;
import org.opensearch.search.builder.SearchSourceBuilder;
import org.opensearch.core.xcontent.XContentBuilder;
import org.sakaiproject.entity.api.Entity;
import org.sakaiproject.event.api.Event;
import org.sakaiproject.exception.IdUnusedException;
import org.sakaiproject.search.api.EntityContentProducer;
import org.sakaiproject.search.api.SearchConstants;
import org.sakaiproject.search.api.SearchService;
import org.sakaiproject.search.api.SiteSearchIndexBuilder;
import org.sakaiproject.search.model.SearchBuilderItem;
import org.sakaiproject.site.api.Site;
import org.sakaiproject.site.api.SiteService;
import org.sakaiproject.site.api.ToolConfiguration;
import org.sakaiproject.user.api.User;
import org.sakaiproject.user.api.UserDirectoryService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class SiteElasticSearchIndexBuilder extends BaseElasticSearchIndexBuilder implements SiteSearchIndexBuilder {

    protected static final String ADD_RESOURCE_VALIDATION_KEY_SITE_ID = "SITE_ID";
    protected static final String DELETE_RESOURCE_KEY_SITE_ID = "SITE_ID";

    private SiteService siteService;
    private UserDirectoryService userDirectoryService;

    private boolean useSiteFilters = false;

    /**
     * set to false if you want to index all content, not just sites that have the search tool placed
     */
    private boolean onlyIndexSearchToolSites = true;

    /**
     * set to false to include user site content in index
     */
    private boolean excludeUserSites = true;

    /**
     * comma separated list of sites to always ignore when indexing.  Defaults to ~admin, !admin
     * use injection to set this value.
     */
    private String ignoredSites = null;

    /**
     * parsed list of ignoredSites configuration. If you wish to change this use the ignoredSites field not this
     * one to avoid having to change Spring xml
     */
    private List<String> ignoredSitesList = new ArrayList<>();

    public void init() {
        onlyIndexSearchToolSites = serverConfigurationService.getBoolean("search.onlyIndexSearchToolSites", true);
    }

    @Override
    protected void beforeElasticSearchConfigInitialization() {
        if (ArrayUtils.isEmpty(this.suggestionResultFieldNames)) {
            this.suggestionResultFieldNames = new String[] {
                    SearchService.FIELD_TYPE,
                    SearchService.FIELD_REFERENCE,
                    SearchService.FIELD_SITEID,
                    SearchService.FIELD_CREATOR_DISPLAY_NAME,
                    SearchService.FIELD_CREATOR_ID,
                    SearchService.FIELD_CREATOR_USER_NAME,
                    SearchService.FIELD_TITLE
            };
        }
        if ( ArrayUtils.isEmpty(this.searchResultFieldNames)) {
            this.searchResultFieldNames = new String[] {
                    SearchService.FIELD_TYPE,
                    SearchService.FIELD_REFERENCE,
                    SearchService.FIELD_SITEID,
                    SearchService.FIELD_CREATOR_DISPLAY_NAME,
                    SearchService.FIELD_CREATOR_ID,
                    SearchService.FIELD_CREATOR_USER_NAME,
                    SearchService.FIELD_TITLE,
                    SearchService.FIELD_URL,
                    SearchService.FIELD_TOOL
            };
        }
    }

    @Override
    protected void beforeBackgroundSchedulerInitialization() {
        if (ignoredSites != null) {
            ignoredSitesList = Arrays.asList(ignoredSites.split(","));
        } else {
            ignoredSitesList.add("~admin");
            ignoredSitesList.add("!admin");
        }
    }

    @Override
    protected void completeAddResourceEventValidations(Event event, Map<String, Object> validationContext)
            throws IllegalArgumentException, IllegalStateException {
        final String resourceName = (String)validationContext.get(ADD_RESOURCE_VALIDATION_KEY_RESOURCE_NAME);
        final EntityContentProducer ecp = (EntityContentProducer)validationContext.get(ADD_RESOURCE_VALIDATION_KEY_CONTENT_PRODUCER);

        String siteId = ecp.getSiteId(resourceName);

        if (onlyIndexSearchToolSites) {
            try {
                Site s = siteService.getSite(siteId);
                ToolConfiguration t = s.getToolForCommonId(SearchConstants.TOOL_ID);
                if (t == null) {
                    throw new IllegalArgumentException("Resource name [" + resourceName + "] for event [" + event
                            + "] not indexable because it is not associated with a site that has the search tool");
                }
            } catch (Exception ex) {
                throw new IllegalArgumentException("Event [" + event
                        + "] not indexable because it is not associated with a site");
            }
        }
        validationContext.put(ADD_RESOURCE_VALIDATION_KEY_SITE_ID, siteId);
    }

    @Override
    protected Map<String, Object> extractDeleteDocumentParams(Map<String, Object> validationContext) {
        Map<String,Object> params = super.extractDeleteDocumentParams(validationContext);
        params.put(DELETE_RESOURCE_KEY_SITE_ID, validationContext.get(ADD_RESOURCE_VALIDATION_KEY_SITE_ID));
        return params;
    }

    @Override
    protected Map<String, Object> extractDeleteDocumentParams(NoContentException noContentException) {
        Map<String,Object> params = super.extractDeleteDocumentParams(noContentException);
        params.put(DELETE_RESOURCE_KEY_SITE_ID, noContentException.getSiteId());
        return params;
    }

    @Override
    protected Map<String, Object> extractDeleteDocumentParams(SearchHit searchHit) {
        String siteId = getFieldFromSearchHit(SearchService.FIELD_SITEID, searchHit);
        final Map<String, Object> params = super.extractDeleteDocumentParams(searchHit);
        params.put(DELETE_RESOURCE_KEY_SITE_ID, siteId);
        return params;
    }

    @Override
    protected DeleteRequest completeDeleteRequest(DeleteRequest deleteRequest, Map<String, Object> deleteParams) {
        return deleteRequest.routing((String)deleteParams.get(DELETE_RESOURCE_KEY_SITE_ID));
    }

    protected void deleteDocument(String id, String siteId) {
        final Map<String, Object> params = new HashMap<>();
        params.put(DELETE_RESOURCE_KEY_DOCUMENT_ID, id);
        params.put(DELETE_RESOURCE_KEY_SITE_ID, siteId);
        deleteDocumentWithParams(params);
    }

    @Override
    protected XContentBuilder addFields(XContentBuilder contentSourceBuilder, String resourceName,
                                        EntityContentProducer ecp, boolean includeContent) throws IOException {
        return contentSourceBuilder.field(SearchService.FIELD_SITEID, ecp.getSiteId(resourceName))
                .field(SearchService.FIELD_CREATOR_DISPLAY_NAME, ecp.getCreatorDisplayName(resourceName))
                .field(SearchService.FIELD_CREATOR_ID, ecp.getCreatorId(resourceName))
                .field(SearchService.FIELD_CREATOR_USER_NAME, ecp.getCreatorUserName(resourceName))
                .field(SearchService.FIELD_TITLE, ecp.getTitle(resourceName))
                .field(SearchService.FIELD_REFERENCE, resourceName)
                .field(SearchService.FIELD_URL, ecp.getUrl(resourceName, Entity.UrlType.PORTAL))
                //.field(SearchService.FIELD_ID, ecp.getId(resourceName))
                .field(SearchService.FIELD_TOOL, ecp.getTool())
                .field(SearchService.FIELD_CONTAINER, ecp.getContainer(resourceName))
                .field(SearchService.FIELD_TYPE, ecp.getType(resourceName));
                //.field(SearchService.FIELD_SUBTYPE, ecp.getSubType(resourceName));
    }

    @Override
    protected XContentBuilder noContentForIndexRequest(XContentBuilder contentSourceBuilder, String resourceName,
                                                       EntityContentProducer ecp, boolean includeContent)
            throws NoContentException {
        throw new NoContentException(ecp.getId(resourceName), resourceName, ecp.getSiteId(resourceName));
    }

    @Override
    protected void noContentProducerForContentQueueEntry(SearchHit hit, String reference) throws NoContentException {
        final String siteId = getFieldFromSearchHit(SearchService.FIELD_SITEID, hit);
        throw new NoContentException(hit.getId(), reference, siteId);
    }

    @Override
    protected SearchRequest completeFindContentQueueRequest(SearchRequest searchRequest) {
        return searchRequest;
    }

    protected void rebuildSiteIndex(String siteId)  {
        log.info("Rebuilding the index for '{}'", siteId);

        try {
            enableAzgSecurityAdvisor();
            deleteAllDocumentForSite(siteId);

            long start = System.currentTimeMillis();
            int numberOfDocs = 0;

            BulkRequest bulkRequest = new BulkRequest();

            for (final EntityContentProducer ecp : producers) {
            	Iterator<String> i = ecp.getSiteContentIterator(siteId);

                while ( i != null && i.hasNext() ) {

                    if (bulkRequest.numberOfActions() < bulkRequestSize) {
                        String reference = i.next();

                        if (StringUtils.isNotBlank(ecp.getContent(reference))) {
                            //updating was causing issues without a _source, so doing delete and re-add
                            try {
                                deleteDocument(ecp.getId(reference), ecp.getSiteId(reference));
                                bulkRequest.add(prepareIndex(reference, ecp, true));
                                numberOfDocs++;
                            } catch (Exception e) {
                                log.error(e.getMessage(), e);
                            }
                        }

                    } else {
                        executeBulkRequest(bulkRequest);
                        bulkRequest = new BulkRequest();
                    }
                }

                // execute any remaining bulks requests not executed yet
                if (bulkRequest.numberOfActions() > 0) {
                    executeBulkRequest(bulkRequest);
                }

            }

            log.info("Queued " + numberOfDocs + " docs for indexing from site: " + siteId + " in " + (System.currentTimeMillis() - start) + " ms");

        } catch (Exception e) {
            log.error("An exception occurred while rebuilding the index of '" + siteId + "'", e);
        } finally {
            disableAzgSecurityAdvisor();
        }
    }

    @Override
    protected void rebuildIndexImmediately() {
        // rebuild index
        for (Site s : siteService.getSites(SiteService.SelectionType.ANY, null, null, null, SiteService.SortType.NONE, null)) {
            if (isSiteIndexable(s)) {
                rebuildSiteIndex(s.getId());
            }
        }
    }

    protected class RebuildSiteTask extends TimerTask {
        private final String siteId;

        public RebuildSiteTask(String siteId) {
            this.siteId = siteId;
        }

        /**
         * Rebuild the index from the entities own stored state {@inheritDoc}, for just
         * the supplied siteId
         */
        public void run() {
            try {
                // let's not hog the whole CPU just in case you have lots of sites with lots of data this could take a bit
                Thread.currentThread().setPriority(Thread.NORM_PRIORITY - 1);
                rebuildSiteIndex(siteId);
            } catch (Exception e) {
                log.error("problem queuing content indexing for site: " + siteId + " error: " + e.getMessage());
            }
        }

    }

    /**
     * Check if a site is considered as indexable based on the current server configuration.
     * <p>
     * Not indexable sites are:
     * <ul>
     * <li>Special sites</li>
     * <li>Sites without the search tool (if the option is enabled)</li>
     * <li>User sites (if the option is enabled)</li>
     * <li>Any sites included in the ignoreSitesList (~admin and !admin are the default ignored sites)</li>
     * </ul>
     * </p>
     *
     * @param site site which may be indexable
     * @return true if the site can be index, false otherwise
     */
    protected boolean isSiteIndexable(Site site) {
        log.debug("Check if '" + site + "' is indexable.");
        return !(siteService.isSpecialSite(site.getId()) ||
                (isOnlyIndexSearchToolSites() && site.getToolForCommonId(SearchConstants.TOOL_ID) == null) ||
                (isExcludeUserSites() && siteService.isUserSite(site.getId())) ||
                (ignoredSitesList.contains(site.getId())));
    }

    @Override
    public List<SearchBuilderItem> getSiteMasterSearchItems() {
        return Collections.emptyList();
    }

    /**
     * Rebuild the index from the entities own stored state {@inheritDoc}, for just
     * the supplied siteId
     */
    @Override
    public void rebuildIndex(String siteId) {
        if (testMode) {
            rebuildSiteIndex(siteId);
            return;
        }
        backgroundScheduler.schedule(new RebuildSiteTask(siteId), 0);
    }

    protected void deleteAllDocumentForSite(String siteId) {
        log.debug("removing all documents from search index for siteId: {}", siteId);

        int maxHits = 999;
        long hitCount = maxHits + 1;

        while (hitCount >= maxHits) {
            SearchResponse response = search(null, null, Collections.singletonList(siteId), null, 0, maxHits);
            SearchHits hits = response.getHits();
            hitCount = hits.getTotalHits().value;
            log.info("Deleting {} docs from site {}", hitCount, siteId);
            for (SearchHit hit : hits) {
                deleteDocument(hit);
            }
            refreshIndex();
        }
    }


    /**
     * Refresh the index for the supplied site.  This simply refreshes the docs that ES already knows about.
     * It does not create any new docs.  If you want to reload all site content you need to do a {@see rebuildIndex()}
     */
    @Override
    public void refreshIndex(String siteId) {
        log.info("Refreshing the index for '{}'", siteId);
        //Get the currently indexed resources for this site

        Site site = null;

        try {
            site = siteService.getSite(siteId);
        } catch (IdUnusedException e) {
            log.error("site with siteId=" + siteId + " does not exist can't refresh its index");
           return;
        }

        if (!isSiteIndexable(site)) {
            log.debug("ignoring request to refreshIndex for site:" + siteId + " as its not indexable");
            return;
        }

        Collection<String> resourceNames = getResourceNames(siteId);
        log.debug(resourceNames.size() + " elements will be refreshed");
        for (String resourceName : resourceNames) {
            EntityContentProducer entityContentProducer = newEntityContentProducer(resourceName);

            //If there is no matching entity content producer or no associated site, skip the resource
            //it is either not available anymore, or the corresponding entityContentProducer doesn't exist anymore
            if (entityContentProducer == null || entityContentProducer.getSiteId(resourceName) == null) {
                log.warn("Couldn't either find an entityContentProducer or the resource itself for '" + resourceName + "'");
                continue;
            }

            try {
                prepareIndexAdd(resourceName, entityContentProducer, false);
            } catch (NoContentException e) {
                // ignore we are just queuing here, not looking for content
            }
        }
    }

    /**
     * Get all indexed resources for a site
     *
     * @param siteId Site containing indexed resources
     * @return a collection of resource references or an empty collection if no resource was found
     */
    protected Collection<String> getResourceNames(String siteId) {
        log.debug("Obtaining indexed elements for site: '" + siteId + "'");

        SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder()
                .query(termQuery(SearchService.FIELD_SITEID, siteId))
                .size(Integer.MAX_VALUE)
                .storedField(SearchService.FIELD_REFERENCE);

        SearchRequest searchRequest = new SearchRequest(indexName)
                .searchType(SearchType.QUERY_THEN_FETCH);

        SearchResponse response;
        try {
            response = client.search(searchRequest, RequestOptions.DEFAULT);
        } catch (IOException ioe) {
            log.warn("Search for resources in site [" + siteId + "] encountered an error, " + ioe);
            return Collections.emptyList();
        }

        return Arrays.stream(response.getHits().getHits())
                .map(h -> getFieldFromSearchHit(SearchService.FIELD_REFERENCE, h))
                .collect(Collectors.toList());
    }

    @Override
    protected IndexRequest completeIndexRequest(IndexRequest indexRequest, String resourceName, EntityContentProducer ecp, boolean includeContent) {
        return indexRequest.routing(ecp.getSiteId(resourceName));
    }

    @Override
    protected void addSearchSiteIds(SearchRequest searchRequest, List<String> siteIds) {

        // if we have sites filter results to include only the sites included
        if (siteIds != null && !siteIds.isEmpty()) {
            BoolQueryBuilder queryBuilder = (BoolQueryBuilder) searchRequest.source().query();
            // searchRequest.routing(siteIds.toArray(new String[]{}));

            // creating config whether or not to use filter, there are performance and caching differences that
            // maybe implementation decisions
            if (useSiteFilters) {
                QueryBuilder siteFilter = boolQuery().filter(termsQuery(SearchService.FIELD_SITEID, siteIds));
                searchRequest.source().postFilter(siteFilter);
            } else {
                queryBuilder.must(termsQuery(SearchService.FIELD_SITEID, siteIds));
            }
        }
    }

    @Override
    protected void completeSearchRequestBuilders(SearchRequest searchRequest, String searchTerms, List<String> references, List<String> siteIds) {
    }

    @Override
    protected void addSearchSuggestionsTerms(SearchRequest searchRequest, String searchString) {
        // no-op. taken care of in newSearchSuggestionsRequestAndQueryBuilders() because of the
        // way TermQueryBuilders have to be constructed (no default constructor so have to be
        // given the search field and term at instantiation)
    }

    @Override
    protected void addSearchSuggestionsSites(SearchRequest searchRequest, String currentSite, boolean allMySites) {
        String currentUser = "";
        User user = userDirectoryService.getCurrentUser();
        if (user != null)  {
            currentUser = user.getId();
        }
        String[] sites;
        if (allMySites || currentSite == null) {
            sites = getAllUsersSites(currentUser);
        } else {
            sites = new String[]{currentSite};
        }

        QueryBuilder siteFilter = boolQuery().filter(termsQuery(SearchService.FIELD_SITEID, sites));
        searchRequest.routing(sites).source().postFilter(siteFilter);
    }

    /**
     * Get all the sites a user has access to.
     * @return An array of site IDs.
     */
    protected String[] getAllUsersSites(String currentUser) {
        List<Site> sites = siteService.getSites(
                org.sakaiproject.site.api.SiteService.SelectionType.ACCESS,
                null, null, null, null, null);
        final List<String> siteIds = sites.stream().map(s -> s.getId()).collect(Collectors.toList());
        siteIds.add(siteService.getUserSiteId(currentUser));
        return siteIds.toArray(new String[siteIds.size()]);
    }

    @Override
    protected void completeSearchSuggestionsRequestBuilders(SearchRequest searchRequest, String searchString, String currentSite, boolean allMySites) {
    }

    /**
     * @return the onlyIndexSearchToolSites
     */
    @Override
    public boolean isOnlyIndexSearchToolSites() {
        return onlyIndexSearchToolSites;
    }

    /**
     * @param onlyIndexSearchToolSites the onlyIndexSearchToolSites to set
     */
    public void setOnlyIndexSearchToolSites(boolean onlyIndexSearchToolSites) {
        this.onlyIndexSearchToolSites = onlyIndexSearchToolSites;
    }

    public void setExcludeUserSites(boolean excludeUserSites) {
        this.excludeUserSites = excludeUserSites;
    }

    @Override
    public boolean isExcludeUserSites() {
        return excludeUserSites;
    }

    public void setUseSiteFilters(boolean useSiteFilters) {
        this.useSiteFilters = useSiteFilters;
    }

    public void setSiteService(SiteService siteService) {
        this.siteService = siteService;
    }

    public void setIgnoredSites(String ignoredSites) {
        this.ignoredSites = ignoredSites;
    }

    public void setIgnoredSitesList(List<String> ignoredSitesList) {
        this.ignoredSitesList = ignoredSitesList;
    }

    public void setUserDirectoryService(UserDirectoryService userDirectoryService) {
        this.userDirectoryService = userDirectoryService;
    }

    @Override
    public String getEventResourceFilter() {
        return "/";
    }

}
