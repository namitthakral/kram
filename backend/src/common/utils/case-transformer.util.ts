/**
 * Utility functions for converting between snake_case and camelCase
 * Used to ensure consistent API response formatting
 */

/**
 * Convert snake_case string to camelCase
 */
export function toCamelCase(str: string): string {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

/**
 * Convert camelCase string to snake_case
 */
export function toSnakeCase(str: string): string {
  return str.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
}

/**
 * Recursively convert all snake_case keys in an object to camelCase
 */
export function convertKeysToCamelCase(obj: any): any {
  if (obj === null || obj === undefined) {
    return obj;
  }

  if (Array.isArray(obj)) {
    return obj.map(convertKeysToCamelCase);
  }

  if (typeof obj === 'object' && obj.constructor === Object) {
    const converted: any = {};
    
    for (const [key, value] of Object.entries(obj)) {
      const camelKey = toCamelCase(key);
      converted[camelKey] = convertKeysToCamelCase(value);
    }
    
    return converted;
  }

  // For primitive types, dates, etc.
  return obj;
}

/**
 * Recursively convert all camelCase keys in an object to snake_case
 */
export function convertKeysToSnakeCase(obj: any): any {
  if (obj === null || obj === undefined) {
    return obj;
  }

  if (Array.isArray(obj)) {
    return obj.map(convertKeysToSnakeCase);
  }

  if (typeof obj === 'object' && obj.constructor === Object) {
    const converted: any = {};
    
    for (const [key, value] of Object.entries(obj)) {
      const snakeKey = toSnakeCase(key);
      converted[snakeKey] = convertKeysToSnakeCase(value);
    }
    
    return converted;
  }

  // For primitive types, dates, etc.
  return obj;
}