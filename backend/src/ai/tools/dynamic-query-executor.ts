import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import { UserWithRelations } from '../../types/auth.types'
import { ModelAccessEntry } from './model-access.config'

export interface QueryParams {
    filters?: Record<string, any>
    include?: string[]
    orderBy?: string
    limit?: number
    count?: boolean
}

@Injectable()
export class DynamicQueryExecutor {
    private readonly logger = new Logger(DynamicQueryExecutor.name)
    private readonly MAX_RESULTS = 50
    private readonly DEFAULT_LIMIT = 10

    constructor(private readonly prisma: PrismaService) {}

    async execute(
        config: ModelAccessEntry,
        params: QueryParams,
        user: UserWithRelations,
    ): Promise<string> {
        try {
            const roleName = user.role.roleName.toLowerCase()
            const delegate = (this.prisma as any)[config.prismaModel]

            if (!delegate) {
                return JSON.stringify({ error: `Model '${config.prismaModel}' not found` })
            }

            // 1. Resolve role-based scope (required WHERE conditions)
            const scopeResolver = config.scopeByRole[roleName]
            const scopeWhere = scopeResolver
                ? await scopeResolver(user, this.prisma)
                : {}

            // 2. Build user filters (from AI params)
            const userFilters = this.sanitizeFilters(params.filters || {}, config)

            // 3. Merge scope + user filters
            const where = { ...scopeWhere, ...userFilters }

            // 4. Count-only mode
            if (params.count) {
                const count = await delegate.count({ where })
                return JSON.stringify({ count })
            }

            // 5. Build include
            const include = this.buildIncludes(params.include || [], config)

            // 6. Build orderBy
            const orderBy = this.buildOrderBy(params.orderBy)

            // 7. Execute query
            const limit = Math.min(params.limit || this.DEFAULT_LIMIT, this.MAX_RESULTS)

            const results = await delegate.findMany({
                where,
                ...(Object.keys(include).length > 0 && { include }),
                ...(orderBy && { orderBy }),
                take: limit,
            })

            // 8. Strip hidden fields and serialize
            const cleaned = results.map((r: any) => this.stripFields(r, config.hiddenFields))

            return JSON.stringify(cleaned, this.jsonSerializer, 2)
        } catch (error) {
            this.logger.error(`Dynamic query error for ${config.prismaModel}:`, error)
            return JSON.stringify({ error: `Query failed: ${error.message}` })
        }
    }

    private sanitizeFilters(
        filters: Record<string, any>,
        config: ModelAccessEntry,
    ): Record<string, any> {
        const sanitized: Record<string, any> = {}

        for (const [key, value] of Object.entries(filters)) {
            // Only allow declared filterable fields
            if (config.filterableFields.includes(key)) {
                sanitized[key] = value
            }
        }

        return sanitized
    }

    private buildIncludes(
        requested: string[],
        config: ModelAccessEntry,
    ): Record<string, any> {
        const include: Record<string, any> = {}

        for (const rel of requested) {
            if (config.allowedIncludes.includes(rel)) {
                // For user relations, only include safe fields
                if (rel === 'user') {
                    include[rel] = {
                        select: { firstName: true, lastName: true, email: true },
                    }
                } else if (rel === 'student') {
                    include[rel] = {
                        include: {
                            user: { select: { firstName: true, lastName: true } },
                        },
                    }
                } else {
                    include[rel] = true
                }
            }
        }

        return include
    }

    private buildOrderBy(orderByStr?: string): Record<string, string> | undefined {
        if (!orderByStr) return undefined

        const desc = orderByStr.startsWith('-')
        const field = desc ? orderByStr.slice(1) : orderByStr

        // Basic alphanumeric field name validation
        if (!/^[a-zA-Z_]+$/.test(field)) return undefined

        return { [field]: desc ? 'desc' : 'asc' }
    }

    private stripFields(obj: any, hiddenFields: string[]): any {
        if (!obj || typeof obj !== 'object') return obj
        if (Array.isArray(obj)) return obj.map(item => this.stripFields(item, hiddenFields))

        const result: Record<string, any> = {}
        for (const [key, value] of Object.entries(obj)) {
            if (hiddenFields.includes(key)) continue
            if (key === 'passwordHash' || key === 'password') continue

            if (value && typeof value === 'object' && !(value instanceof Date)) {
                result[key] = this.stripFields(value, hiddenFields)
            } else {
                result[key] = value
            }
        }
        return result
    }

    /** Handle BigInt and Decimal serialization */
    private jsonSerializer(_key: string, value: any): any {
        if (typeof value === 'bigint') return value.toString()
        return value
    }
}
