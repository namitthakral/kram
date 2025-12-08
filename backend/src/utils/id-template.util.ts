/**
 * ID Template Parser Utility
 *
 * Parses and generates IDs based on customizable templates.
 * Each institution can define their own ID formats.
 *
 * Available Placeholders:
 * - {YEAR}    - Full year (e.g., 2025)
 * - {YY}      - 2-digit year (e.g., 25)
 * - {MONTH}   - Full month (e.g., 01-12)
 * - {MM}      - 2-digit month (e.g., 01-12)
 * - {INST}    - Institution code (e.g., DPS, IITD)
 * - {COURSE}  - Course/Branch code (e.g., CS, ECE)
 * - {BRANCH}  - Alias for COURSE
 * - {SECTION} - Section letter (e.g., A, B)
 * - {SEQ:N}   - Sequence number padded to N digits (e.g., {SEQ:5} -> 00042)
 *
 * Example Templates:
 * - "{YEAR}/{COURSE}/{SEQ:5}"         -> "2025/CS/00042"
 * - "{INST}-{YEAR}-{SEQ:4}"           -> "DPS-2025-0042"
 * - "{YY}{COURSE}{SEQ:4}"             -> "25CS0042"
 * - "ADM/{INST}/{BRANCH}/{YEAR}-{SEQ:3}" -> "ADM/DPS/CS/2025-042"
 */

export interface TemplateContext {
  year?: number
  month?: number
  institutionCode?: string
  courseCode?: string
  section?: string
  sequence: number
}

/**
 * Parse a template string and generate an ID
 *
 * @param template - The template string with placeholders
 * @param context - The context values for placeholders
 * @returns Generated ID string
 *
 * @example
 * parseTemplate("{YEAR}/{COURSE}/{SEQ:5}", {
 *   year: 2025,
 *   courseCode: "CS",
 *   sequence: 42
 * })
 * // Returns: "2025/CS/00042"
 */
export function parseTemplate(
  template: string,
  context: TemplateContext
): string {
  const now = new Date()
  const year = context.year || now.getFullYear()
  const month = context.month || now.getMonth() + 1

  let result = template

  // Replace simple placeholders
  result = result.replace(/{YEAR}/g, year.toString())
  result = result.replace(/{YY}/g, year.toString().slice(-2))
  result = result.replace(/{MONTH}/g, month.toString().padStart(2, '0'))
  result = result.replace(/{MM}/g, month.toString().padStart(2, '0'))
  result = result.replace(/{INST}/g, context.institutionCode || 'GEN')
  result = result.replace(/{COURSE}/g, context.courseCode || 'GEN')
  result = result.replace(/{BRANCH}/g, context.courseCode || 'GEN')
  result = result.replace(/{SECTION}/g, context.section || 'X')

  // Replace sequence placeholder with padding
  // Pattern: {SEQ:N} where N is the padding length
  result = result.replace(/{SEQ:(\d+)}/g, (_, paddingStr) => {
    const padding = parseInt(paddingStr, 10)
    return context.sequence.toString().padStart(padding, '0')
  })

  // Handle simple {SEQ} without padding (default to 5)
  result = result.replace(
    /{SEQ}/g,
    context.sequence.toString().padStart(5, '0')
  )

  return result
}

/**
 * Validate a template string
 *
 * @param template - The template string to validate
 * @returns Object with isValid flag and any error messages
 */
export function validateTemplate(template: string): {
  isValid: boolean
  errors: string[]
} {
  const errors: string[] = []

  // Check for required sequence placeholder
  if (!/{SEQ(:\d+)?}/.test(template)) {
    errors.push('Template must contain {SEQ} or {SEQ:N} placeholder')
  }

  // Check for invalid placeholders
  const validPlaceholders = [
    'YEAR',
    'YY',
    'MONTH',
    'MM',
    'INST',
    'COURSE',
    'BRANCH',
    'SECTION',
  ]
  const placeholderRegex = /{([A-Z]+)(:\d+)?}/g
  let match

  while ((match = placeholderRegex.exec(template)) !== null) {
    const placeholder = match[1]
    if (placeholder !== 'SEQ' && !validPlaceholders.includes(placeholder)) {
      errors.push(`Invalid placeholder: {${placeholder}}`)
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  }
}

/**
 * Get the next sequence number based on reset policy
 *
 * @param currentSeq - Current sequence counter
 * @param seqYear - Year when sequence was last used
 * @param seqMonth - Month when sequence was last used (for MONTHLY policy)
 * @param policy - Reset policy (YEARLY, MONTHLY, NEVER)
 * @returns Object with next sequence and updated year/month
 */
export function getNextSequence(
  currentSeq: number,
  seqYear: number,
  policy: 'YEARLY' | 'MONTHLY' | 'NEVER',
  seqMonth?: number
): {
  nextSequence: number
  newYear: number
  newMonth: number
} {
  const now = new Date()
  const currentYear = now.getFullYear()
  const currentMonth = now.getMonth() + 1

  let nextSequence = currentSeq + 1
  let newYear = seqYear
  let newMonth = seqMonth || 0

  switch (policy) {
    case 'YEARLY':
      if (currentYear !== seqYear) {
        // New year - reset sequence
        nextSequence = 1
        newYear = currentYear
      }
      break

    case 'MONTHLY':
      if (currentYear !== seqYear || currentMonth !== seqMonth) {
        // New month - reset sequence
        nextSequence = 1
        newYear = currentYear
        newMonth = currentMonth
      }
      break

    case 'NEVER':
      // Never reset, just increment
      newYear = currentYear
      break
  }

  return {
    nextSequence,
    newYear,
    newMonth,
  }
}

/**
 * Default templates for different ID types
 */
export const DEFAULT_TEMPLATES = {
  admissionNumber: '{YEAR}/{COURSE}/{SEQ:5}',
  rollNumber: '{COURSE}-{SECTION}-{SEQ:3}',
  teacherEmployeeId: 'EMP-{YEAR}-{SEQ:5}',
  staffEmployeeId: 'STF-{YEAR}-{SEQ:5}',
}

/**
 * Example templates for different institutions
 */
export const EXAMPLE_TEMPLATES = {
  // Standard format
  standard: {
    admissionNumber: '{YEAR}/{COURSE}/{SEQ:5}',
    rollNumber: '{COURSE}-{SECTION}-{SEQ:3}',
    teacherEmployeeId: 'EMP-{YEAR}-{SEQ:5}',
    staffEmployeeId: 'STF-{YEAR}-{SEQ:5}',
  },

  // Compact format (no separators)
  compact: {
    admissionNumber: '{YY}{COURSE}{SEQ:4}',
    rollNumber: '{COURSE}{SECTION}{SEQ:3}',
    teacherEmployeeId: 'E{YY}{SEQ:4}',
    staffEmployeeId: 'S{YY}{SEQ:4}',
  },

  // Institution-prefixed format
  institutionPrefixed: {
    admissionNumber: '{INST}/{YEAR}/{COURSE}/{SEQ:4}',
    rollNumber: '{INST}-{COURSE}-{SECTION}-{SEQ:3}',
    teacherEmployeeId: '{INST}-EMP-{YEAR}-{SEQ:4}',
    staffEmployeeId: '{INST}-STF-{YEAR}-{SEQ:4}',
  },

  // Legacy format (simple sequential)
  legacy: {
    admissionNumber: 'ADM{SEQ:6}',
    rollNumber: 'ROLL{SEQ:5}',
    teacherEmployeeId: 'EMP{SEQ:5}',
    staffEmployeeId: 'STF{SEQ:5}',
  },
}
