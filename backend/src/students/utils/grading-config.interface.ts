/**
 * Interface for institution-specific grading configuration
 */
export interface GradingConfig {
  // Weights (should sum to 100)
  attendanceWeight: number;
  assignmentWeight: number;
  examWeight: number;
  participationWeight: number;

  // Grade boundaries (percentage scores)
  gradeAPlusThreshold: number;
  gradeAThreshold: number;
  gradeBPlusThreshold: number;
  gradeBThreshold: number;
  gradeCThreshold: number;

  // Grade points mapping
  gradeAPlusPoints: number;
  gradeAPoints: number;
  gradeBPlusPoints: number;
  gradeBPoints: number;
  gradeCPoints: number;
  gradeDPoints: number;

  // Risk status thresholds
  atRiskAttendance: number;
  atRiskAssignment: number;
  atRiskExam: number;
  atRiskGradePoints: number;

  needsImprovementAttendance: number;
  needsImprovementAssignment: number;
  needsImprovementExam: number;
  needsImprovementGradePoints: number;

  excellentAttendance: number;
  excellentAssignment: number;
  excellentExam: number;
  excellentGradePoints: number;

  goodAttendance: number;
  goodAssignment: number;
  goodExam: number;
  goodGradePoints: number;
}

