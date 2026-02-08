import { Injectable, Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Helper to generate a token-efficient schema representation for the AI.
 * It reads the Prisma schema and strips out comments, formatting, and unnecessary details.
 */
@Injectable()
export class SchemaHelper {
    private readonly logger = new Logger(SchemaHelper.name);
    private cachedSchema: string = '';

    getSchemaContext(): string {
        if (this.cachedSchema) return this.cachedSchema;

        try {
            // Path to the merged prisma schema
            // Adjust path relative to dist/src/ai/schema.helper.js -> ../../../prisma/schema.prisma
            // In development (src), it's ../../../prisma/schema.prisma
            const schemaPath = path.resolve(process.cwd(), 'prisma/schema.prisma');

            if (!fs.existsSync(schemaPath)) {
                this.logger.warn(`Schema file not found at ${schemaPath}`);
                return 'Schema not available.';
            }

            const content = fs.readFileSync(schemaPath, 'utf-8');
            this.cachedSchema = this.parseSchema(content);
            return this.cachedSchema;
        } catch (error) {
            this.logger.error('Error generating schema context', error);
            return 'Error reading schema.';
        }
    }

    private parseSchema(content: string): string {
        const lines = content.split('\n');
        let output = 'Database Schema:\n';
        let currentModel = '';
        let inModel = false;

        for (const line of lines) {
            const trimmed = line.trim();

            // Skip comments and empty lines
            if (trimmed.startsWith('//') || trimmed === '') continue;

            // Start of model
            if (trimmed.startsWith('model ')) {
                const parts = trimmed.split(/\s+/);
                if (parts.length >= 2) {
                    currentModel = parts[1];
                    output += `- ${currentModel}(`;
                    inModel = true;
                }
                continue;
            }

            // Capture table mapping
            if (trimmed.startsWith('@@map("')) {
                const mapMatch = trimmed.match(/@@map\("(.+?)"\)/);
                if (mapMatch && mapMatch[1] && currentModel) {
                    // Look back and append Table name to the Model definition
                    const modelDef = `- ${currentModel}(`;
                    const tableInfo = `Table: ${mapMatch[1]}`;
                    if (output.includes(modelDef)) {
                        output = output.replace(modelDef, `- ${currentModel} (${tableInfo}) (`);
                    }
                }
            }

            // End of model
            if (trimmed === '}' && inModel) {
                // Remove trailing comma if exists and add closing parenthesis
                if (output.endsWith(', ')) {
                    output = output.slice(0, -2);
                }
                output += ')\n';
                inModel = false;
                continue;
            }

            // Field definitions
            if (inModel && !trimmed.startsWith('@@')) {
                const parts = trimmed.split(/\s+/);
                if (parts.length >= 2) {
                    const fieldName = parts[0];
                    const fieldType = parts[1];

                    // Exclude common internal fields to save space
                    if (this.isInterestingField(fieldName)) {
                        output += `${fieldName}: ${fieldType}`;

                        // Check for field mapping
                        const mapMatch = trimmed.match(/@map\("(.+?)"\)/);
                        if (mapMatch && mapMatch[1]) {
                            output += ` (Col: "${mapMatch[1]}")`;
                        } else {
                            // Explicitly state the column name even if it matches field name
                            // This prevents AI from halucinating snake_case
                            output += ` (Col: "${fieldName}")`;
                        }

                        output += ', ';
                    }
                }
            }

            // Also capture Enums for context
            if (trimmed.startsWith('enum ')) {
                const parts = trimmed.split(/\s+/);
                if (parts.length >= 2) {
                    output += `Enum ${parts[1]} { `;
                    // We'll capture enum values on subsequent lines, simplified
                }
            }
            // Simple enum value capture (this is a basic parser, might miss some multiline enum details but good enough)
        }

        return output;
    }

    private isInterestingField(field: string): boolean {
        const ignored = [
            'password', 'hash', 'passwordHash', 'createdAt', 'updatedAt',
            'isDeleted', 'deletedAt', 'verifyToken', 'resetToken'
        ];
        return !ignored.includes(field);
    }
}
