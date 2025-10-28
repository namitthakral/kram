/**
 * EdVerse ID Generation Utility
 *
 * Generates unique EdVerse IDs for users based on their role
 * Format: EDV-{ROLE_CODE}-{YEAR}-{SEQUENCE}
 *
 * Examples:
 * - EDV-S-2025-000001 (Student)
 * - EDV-T-2025-000001 (Teacher)
 * - EDV-P-2025-000001 (Parent)
 * - EDV-A-2025-000001 (Admin)
 * - EDV-ST-2025-000001 (Staff)
 */

/**
 * Role code mapping
 */
const ROLE_CODES: Record<string, string> = {
  super_admin: 'SA',
  admin: 'A',
  teacher: 'T',
  student: 'S',
  parent: 'P',
  staff: 'ST',
}

/**
 * Generate EdVerse ID
 * @param roleName - The role name (e.g., 'student', 'teacher')
 * @param sequence - The sequence number for this role/year combination
 * @param year - Optional year (defaults to current year)
 * @returns EdVerse ID string
 */
export function generateEdVerseId(
  roleName: string,
  sequence: number,
  year?: number
): string {
  const roleCode = ROLE_CODES[roleName.toLowerCase()] || 'U' // 'U' for Unknown
  const currentYear = year || new Date().getFullYear()
  const paddedSequence = sequence.toString().padStart(6, '0')

  return `EDV-${roleCode}-${currentYear}-${paddedSequence}`
}

/**
 * Parse EdVerse ID to extract components
 * @param edverseId - The EdVerse ID to parse
 * @returns Object containing role code, year, and sequence
 */
export function parseEdVerseId(edverseId: string): {
  roleCode: string
  year: number
  sequence: number
} | null {
  const pattern = /^EDV-([A-Z]+)-(\d{4})-(\d{6})$/
  const match = edverseId.match(pattern)

  if (!match) {
    return null
  }

  return {
    roleCode: match[1],
    year: parseInt(match[2], 10),
    sequence: parseInt(match[3], 10),
  }
}

/**
 * Validate EdVerse ID format
 * @param edverseId - The EdVerse ID to validate
 * @returns true if valid, false otherwise
 */
export function isValidEdVerseId(edverseId: string): boolean {
  return /^EDV-[A-Z]+-\d{4}-\d{6}$/.test(edverseId)
}

/**
 * Get role name from EdVerse ID
 * @param edverseId - The EdVerse ID
 * @returns Role name or null if invalid
 */
export function getRoleNameFromEdVerseId(edverseId: string): string | null {
  const parsed = parseEdVerseId(edverseId)
  if (!parsed) return null

  const roleEntry = Object.entries(ROLE_CODES).find(
    ([_, code]) => code === parsed.roleCode
  )

  return roleEntry ? roleEntry[0] : null
}

/**
 * Generate temporary password based on user's name and current year
 * Format: First 4 letters of name (uppercase) + current year
 * Example: "Namit Thakral" -> "NAMI2025"
 *
 * @param firstName - User's first name
 * @param lastName - User's last name (optional)
 * @returns Temporary password string
 */
export function generateTemporaryPassword(
  firstName: string,
  lastName?: string
): string {
  const year = new Date().getFullYear()

  // Combine first and last name, remove non-alphabetic characters
  const fullName = `${firstName}${lastName || ''}`.replace(/[^a-zA-Z]/g, '')

  // Get first 4 characters (or less if name is shorter)
  const namePrefix = fullName.substring(0, 4).toUpperCase()

  // Pad with 'X' if name is too short
  const paddedPrefix = namePrefix.padEnd(4, 'X')

  return `${paddedPrefix}${year}`
}
