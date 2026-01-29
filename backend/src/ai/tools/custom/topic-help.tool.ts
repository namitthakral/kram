import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { UserWithRelations } from '../../../types/auth.types'
import { AiProvider } from '../../interfaces/ai-provider.interface'
import { BaseTool } from '../base.tool'

@Injectable()
export class TopicHelpTool extends BaseTool {
    private readonly logger = new Logger(TopicHelpTool.name)

    readonly name = 'get_topic_help'
    readonly description =
        'Get help on a specific topic or chapter from an enrolled subject. Can explain concepts, provide examples, generate practice quizzes, or summarize content.'
    readonly allowedRoles = ['student']
    readonly parameters = {
        type: 'object',
        properties: {
            subjectId: {
                type: 'number',
                description: 'The ID of the subject.',
            },
            topic: {
                type: 'string',
                description: 'The topic or chapter to get help with.',
            },
            helpType: {
                type: 'string',
                enum: ['explain', 'examples', 'quiz', 'summary'],
                description: 'Type of help: explain the concept, show examples, generate a practice quiz, or summarize.',
            },
        },
        required: ['subjectId', 'topic', 'helpType'],
    }

    constructor(private readonly prisma: PrismaService) {
        super()
    }

    private aiProvider: AiProvider

    setProvider(provider: AiProvider) {
        this.aiProvider = provider
    }

    async execute(
        params: Record<string, any>,
        user: UserWithRelations,
    ): Promise<string> {
        try {
            const studentId = user.student?.id
            if (!studentId) {
                return JSON.stringify({ error: 'Student profile not found.' })
            }

            // Verify student is enrolled in this subject
            const enrollment = await this.prisma.enrollment.findFirst({
                where: {
                    studentId,
                    subjectId: params.subjectId,
                    enrollmentStatus: 'ENROLLED',
                },
                include: { subject: true },
            })

            if (!enrollment) {
                return JSON.stringify({ error: 'You are not enrolled in this subject or the subject ID is invalid.' })
            }

            const subject = enrollment.subject
            const syllabus = subject.syllabus || 'No syllabus available.'
            const helpType = params.helpType || 'explain'

            const helpInstructions: Record<string, string> = {
                explain: `Explain the topic "${params.topic}" clearly and thoroughly. Break down complex concepts into simple terms. Use analogies where helpful. Structure the explanation with key points and sub-topics.`,
                examples: `Provide clear, practical examples for the topic "${params.topic}". Include at least 3 worked examples of increasing difficulty. Show step-by-step solutions where applicable.`,
                quiz: `Create a practice quiz on "${params.topic}" with 5 questions. Include a mix of question types (multiple choice, short answer, true/false). Provide correct answers and brief explanations at the end.`,
                summary: `Provide a concise summary of the topic "${params.topic}". Include key definitions, important formulas or rules, and main takeaways. Keep it suitable for quick revision.`,
            }

            const prompt = `You are an expert tutor for the subject "${subject.subjectName}" (${subject.subjectCode}).

Topic: ${params.topic}

Subject Syllabus Context:
${syllabus.substring(0, 1000)}

Task: ${helpInstructions[helpType]}

Keep the response focused, educational, and appropriate for a college/school student.`

            if (!this.aiProvider) {
                return JSON.stringify({ error: 'AI provider not available for content generation.' })
            }

            const response = await this.aiProvider.generateResponse(prompt)

            return JSON.stringify({
                subjectName: subject.subjectName,
                topic: params.topic,
                helpType,
                content: response,
            })
        } catch (error) {
            this.logger.error('Error generating topic help:', error)
            return JSON.stringify({ error: `Failed to generate help: ${error.message}` })
        }
    }
}
