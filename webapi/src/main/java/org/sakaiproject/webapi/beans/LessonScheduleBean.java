package org.sakaiproject.webapi.beans;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LessonScheduleBean {

    private String lessonGuid;
    private int scheduleDayNo;
    private String scheduleDurationHhMm;
}
