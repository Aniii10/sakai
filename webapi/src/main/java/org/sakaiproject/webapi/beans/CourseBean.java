package org.sakaiproject.webapi.beans;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class CourseBean {
    private String courseGuid;
    private String uniqueCourseCode;
    private String courseCategory;
    private String courseType;
    private String courseTitle;
    private String courseDescription;
    private boolean isMandatory;
    private boolean isExam;
    private double numberOfExamCredits;
    private boolean isTrainingBook;
    private LocalDateTime courseStartDate;
    private LocalDateTime courseEndDate;
    private List<LessonItemRestBean> lessons;
    private CourseCloseBean courseClose;
}
