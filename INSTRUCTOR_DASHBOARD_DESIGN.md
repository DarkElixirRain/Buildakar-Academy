# Instructor Dashboard Design

Based on the backend capability analysis, this document outlines the design for an enhanced instructor dashboard that leverages existing APIs and follows the application patterns.

## Design Principles

1. **Leverage Existing Infrastructure**: Use only APIs and data models identified in the capability report
2. **Consistency**: Match existing UI patterns, components, and navigation styles
3. **Role-Appropriate**: Only show data and actions the authenticated instructor is authorized to access
4. **Progressive Disclosure**: Provide overview information with drill-down capabilities to detailed screens
5. **Performance**: Minimize API calls and optimize data fetching

## Current State Assessment

The current instructor dashboard (`instructor_dashboard_screens.dart`) shows:
- Basic stats (courses, students, revenue)
- Course list with actions
- Create course button

It uses:
- `getMyInstructorCourses()` for course list
- `getMyInstructorStats()` for basic stats

## Enhanced Dashboard Design

### Overall Structure

The enhanced dashboard will maintain the current structure but enhance the content areas with additional widgets that utilize available APIs.

### Layout Options

Option 1: Tabbed Interface (within the dashboard screen)
- Overview Tab
- Courses Tab  
- Live Classes Tab
- Students Tab
- Analytics Tab

Option 2: Sectioned Single Page (Recommended for consistency with current design)
- Stats Section (enhanced)
- Quick Actions Section
- Recent Activity Section
- Course Overview Section
- Live Courses Section
- Student Overview Section

I recommend Option 2 to maintain consistency with the current single-page approach while enhancing the information density.

### Component Breakdown

#### 1. Enhanced Stats Section
Expand beyond the current 4 stats to include key metrics from available APIs:

**Primary Stats Row (4 items - maintain current width):**
- Total Courses (from `getMyInstructorStats()`)
- Published Courses (from `getMyInstructorStats()`)
- Total Students (from `getMyInstructorStats()`)
- Total Revenue (from `getMyInstructorStats()`)

**Secondary Stats Row (4 items):**
- Average Rating (from `getMyInstructorStats()`)
- Total Reviews (from `getMyInstructorStats()`)
- Upcoming Live Classes (from `getInstructorLiveClasses()` - count where status=SCHEDULED && scheduledAt > now)
- Current Month Earnings (from `getInstructorEarnings()` with timeRange='month')

#### 2. Quick Actions Section
Provide shortcuts to common tasks:
- [+] New Course (navigates to CourseCreationScreen)
- [+] New Live Class (navigates to CreateLiveClassScreen)
- [+] New Section (disabled - requires course context)
- [+] New Lesson (disabled - requires course context)
- [ ] Pending Actions (if any - e.g., courses awaiting review)

#### 3. Recent Activity Section
Show recent activities across different areas:
- Recently updated courses (from `getMyInstructorCourses()` sorted by updatedAt)
- Recent live sessions (from `getInstructorLiveClasses()` sorted by createdAt)
- New student enrollments (would need specific API - but we can show recent activity from course enrollments)
- Recent reviews (would need to fetch per course - might be too expensive)

Given API limitations, this could show:
- Recently updated courses (title, date, action taken)
- Upcoming/ongoing live classes

#### 4. Course Overview Section
Enhanced version of current course list with:
- Course cards showing: title, status, student count, revenue, last updated
- Visual indicators for: needs attention (drafts), publishing status, student activity
- Actions: View Details, Edit, Delete, Publish/Unpublish
- Empty state: "No courses yet. Create your first course to get started."

#### 5. Live Courses Section
Show upcoming and current live classes:
- Header: "Live Classes" with count badges (Upcoming: X, Live: Y)
- Cards for each live class showing: title, date/time, status, course (if applicable), duration
- Status indicators with color coding: Scheduled (blue), Live (green), Ended (gray), Cancelled (red)
- Actions: Join (if live/upcoming), Edit, Delete, Start/End/Cancel as appropriate
- Empty state: "No live classes scheduled. Create your first live class to connect with students in real-time."

#### 6. Student Overview Section
Show key student metrics:
- Header: "Your Students" with total count
- Summary stats: Active this month, completed courses, average progress
- Recent activity: Recently enrolled students (name, course, date)
- Empty state: "No students enrolled yet. Students will appear here as they enroll in your courses."

## Implementation Approach

### Data Fetching Strategy
To minimize API calls while providing rich information:

1. **Initial Load** (on dashboard appearance):
   - `getMyInstructorStats()` - for primary stats
   - `getMyInstructorCourses(limit: 10)` - for course overview and recent activity
   - `getInstructorLiveClasses()` - for live classes section
   - `getInstructorStudents(limit: 10)` - for student overview
   - `getInstructorEarnings(timeRange: 'month')` - for monthly earnings

2. **Refresh Strategy**:
   - Pull-to-refresh on entire dashboard
   - Individual section refresh buttons (optional)
   - Automatic refresh when returning to dashboard from detail screens

### Component Implementation Details

#### Stats Cards
Reuse the existing `_StatCard` widget from the current dashboard but enhance with:
- Icon variations for different metric types
- Subtitle showing trend or additional context
- Color coding based on performance (e.g., red for low engagement, green for growth)

#### Course Cards
Enhance current course card implementation with:
- Status badges (Draft, Pending Review, Published)
- Student count visualization
- Last updated timestamp
- Action menu (more_vert) with Edit, Delete, Publish/Unpublish

#### Live Class Cards
Create new card component showing:
- Title and time/date
- Status indicator with color-coded dot
- Course name (if associated)
- Duration (scheduled or actual)
- Action buttons based on state:
  - SCHEDULED: [Edit] [Delete] [Start]
  - LIVE: [Join] [End]
  - ENDED: [View Recording] [Delete]
  - CANCELLED: [Delete]

#### Student Summary
Create component showing:
- Total student count
- Key metrics: active learners, course completers
- Recent enrollments (avatar, name, course, date)
- Link to full student management (would need to be created)

### Navigation Flow
From dashboard sections, tapping on items should navigate to appropriate detail screens:
- Course card → InstructorCourseDetailScreen (existing)
- Live class card → LiveClassDetailScreen (would need to be created or use existing LiveScreen with context)
- "See all" links → Dedicated screens for each category (Courses, Live Classes, Students)

### Empty States
Each section should have meaningful empty states that guide the user to take action:
- No courses: Prompt to create first course
- No live classes: Prompt to schedule first live class  
- No students: Explain that students appear when they enroll
- No recent activity: Suggest creating content to get started

### Error Handling & Loading
- Use existing error and loading patterns from the application
- Show skeleton loaders during data fetching
- Display retry buttons for failed requests
- Handle partial data gracefully (show what's available)

## Files to Modify/Create

1. **Primary**: `frontend/lib/screens/instructor-dashboard/instructor_dashboard_screens.dart` - Enhance existing dashboard
2. **Potential New Components** (if needed):
   - `frontend/lib/widgets/instructor/dashboard_stats.dart`
   - `frontend/lib/widgets/instructor/course_card_enhanced.dart` 
   - `frontend/lib/widgets/instructor/live_class_card.dart`
   - `frontend/lib/widgets/instructor/student_summary.dart`
3. **Potential New Screens** (for "See all" functionality):
   - `frontend/lib/screens/instructor/instructor_courses_screen.dart`
   - `frontend/lib/screens/instructor/instructor_live_classes_screen.dart`
   - `frontend/lib/screens/instructor/instructor_students_screen.dart`

## Integration with Existing Navigation

The dashboard is already accessible via:
- Bottom navigation tab 3 (Profile) when user is instructor
- No changes needed to routing or navigation

## Backward Compatibility
- All existing functionality will be preserved
- Current course list and stats will be enhanced, not removed
- No breaking changes to existing APIs or data formats

## Next Steps
1. Implement the enhanced dashboard in `instructor_dashboard_screens.dart`
2. Create any needed reusable components
3. Test with real data to ensure all API integrations work correctly
4. Verify that the dashboard maintains good performance with realistic data volumes