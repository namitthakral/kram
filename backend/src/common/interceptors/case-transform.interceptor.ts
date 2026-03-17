import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { convertKeysToCamelCase } from '../utils/case-transformer.util';

/**
 * Global interceptor that converts all response keys from snake_case to camelCase
 * This ensures consistent API response formatting regardless of database column naming
 */
@Injectable()
export class CaseTransformInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map((data) => {
        // Skip transformation for certain response types
        if (this.shouldSkipTransformation(context, data)) {
          return data;
        }

        // Convert all snake_case keys to camelCase
        return convertKeysToCamelCase(data);
      }),
    );
  }

  /**
   * Determine if transformation should be skipped for certain endpoints or data types
   */
  private shouldSkipTransformation(context: ExecutionContext, data: any): boolean {
    const request = context.switchToHttp().getRequest();
    const path = request.url;

    // Skip transformation for:
    // 1. File uploads/downloads
    // 2. Health check endpoints
    // 3. Already transformed data (has camelCase keys)
    
    if (path.includes('/health') || path.includes('/files')) {
      return true;
    }

    // If data is null, undefined, or primitive type
    if (!data || typeof data !== 'object') {
      return true;
    }

    // Skip the camelCase check for now - let the transformer handle it
    // The transformer is smart enough to handle mixed case scenarios

    return false;
  }

  /**
   * Check if object already has camelCase keys (to avoid double transformation)
   */
  private hasOnlyCamelCaseKeys(obj: any): boolean {
    if (!obj || typeof obj !== 'object' || Array.isArray(obj)) {
      return false;
    }

    const keys = Object.keys(obj);
    if (keys.length === 0) return false;

    // Check if all keys are camelCase (no underscores)
    return keys.every(key => !key.includes('_'));
  }
}