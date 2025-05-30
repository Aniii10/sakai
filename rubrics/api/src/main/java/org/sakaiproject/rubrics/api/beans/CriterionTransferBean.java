/******************************************************************************
 * Copyright 2015 sakaiproject.org Licensed under the Educational
 * Community License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 * http://opensource.org/licenses/ECL-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 ******************************************************************************/
package org.sakaiproject.rubrics.api.beans;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.sakaiproject.rubrics.api.model.Criterion;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CriterionTransferBean {

    private Long id;
    private String title;
    private String description;
    private Float weight;
    private List<RatingTransferBean> ratings = new ArrayList<>();
    private String ownerId;
    private boolean isNew;

    public CriterionTransferBean(Criterion criterion) {

        Objects.requireNonNull(criterion, "criterion must not be null in constructor");
        id = criterion.getId();
        title = criterion.getTitle();
        description = criterion.getDescription();
        weight = criterion.getWeight();
        ratings = criterion.getRatings().stream()
                .filter(Objects::nonNull)
                .map(RatingTransferBean::new)
                .collect(Collectors.toList());
    }

    @Override
    public boolean equals(Object o) {

        if (o == null || ((CriterionTransferBean) o).getId() == null || id == null) {
            return false;
        } else if (o == this) {
            return true;
        }
        return (this.id.equals(((CriterionTransferBean) o).getId()) && ((CriterionTransferBean) o).getRatings().size() == this.ratings.size());
    }
}
