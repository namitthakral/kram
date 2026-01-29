import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { UserWithRelations } from '../../../types/auth.types'
import { AiProvider } from '../../interfaces/ai-provider.interface'
import { BaseTool } from '../base.tool'

@Injectable()
export class AssignmentGeneratorTool extends BaseTool {
    private readonly logger = new Logger(AssignmentGeneratorTool.name)

    readonly name = 'generate_assignment'
    readonly description =
        'Generate assignment content for a subject the teacher teaches. Returns a draft with questions/tasks, instructions, and marking scheme. Does NOT save to database.'
    readonly allowedRoles = ['teacher']
    readonly parameters = {
        type: 'object',
        properties: {
            subjectId: {
                type: 'number',
                description: 'The ID of the subject to generate the assignment for.',
            },
            topic: {
                type: 'string',
                description: 'The specific topic or chapter for the assignment.',
            },
            type: {
                type: 'string',
                enum: ['quiz', 'essay', 'problem_set', 'practical', 'project'],
                description: 'Type of assignment to generate.',
            },
            difficulty: {
                type: 'string',
                enum: ['easy', 'medium', 'hard'],
                description: 'Difficulty level.',
            },
            numberOfQuestions: {
                type: 'number',
                description: 'Number of questions to generate (default 5).',
            },
        },
        required: ['subjectId', 'topic', 'type'],
    }

    constructor(private readonly prisma: PrismaService) {
        super()
    }

    /** Set dynamically by the module after initialization */
    private aiProvider: AiProvider

    setProvider(provider: AiProvider) {
        this.aiProvider = provider
    }

    async execute(
        params: Record<string, any>,
        user: UserWithRelations,
    ): Promise<string> {
        try {
            const teacherId = user.teacher?.id
            if (!teacherId) {
                return JSON.stringify({ error: 'Teacher profile not found.' })
            }

            // Verify teacher teaches this subject
            const section = await this.prisma.classSection.findFirst({
                where: { teacherId, subjectId: params.subjectId },
                include: { subject: true },
            })

            if (!section) {
                return JSON.stringify({ error: 'You do not teach this subject or the subject ID is invalid.' })
            }

            const subject = section.subject
            const syllabus = subject.syllabus || 'No syllabus available.'

            const numQuestions = params.numberOfQuestions || 5
            const difficulty = params.difficulty || 'medium'
            const type = params.type

            const prompt = `Generate an academic assignment for the following:
Subject: ${subject.subjectName} (${subject.subjectCode})
Topic: ${params.topic}
Assignment Type: ${type}
Difficulty: ${difficulty}
Number of Questions: ${numQuestions}

Subject Syllabus Context:
${syllabus.substring(0, 1000)}

Requirements:
- Create ${numQuestions} clear, well-structured questions appropriate for the difficulty level.
- Include a brief instruction section for students.
- Include a marking scheme (marks per question, total marks).
- Format as a clean, ready-to-use assignment document.
- For ${type === 'quiz' ? 'quiz: include multiple choice options' : type === 'essay' ? 'essay: provide clear prompts and expected word count' : type === 'problem_set' ? 'problem set: include numerical/analytical problems' : type === 'practical' ? 'practical: include lab/hands-on tasks' : 'project: include project scope, deliverables, and evaluation criteria'}.`

            if (!this.aiProvider) {
                return JSON.stringify({ error: 'AI provider not available for content generation.' })
            }

            const response = await this.aiProvider.generateResponse(prompt)

            return JSON.stringify({
                draft: true,
                subjectName: subject.subjectName,
                subjectCode: subject.subjectCode,
                topic: params.topic,
                type,
                difficulty,
                content: response,
                note: 'This is a draft. Review and modify before publishing.',
            })
        } catch (error) {
            this.logger.error('Error generating assignment:', error)
            return JSON.stringify({ error: `Failed to generate assignment: ${error.message}` })
        }
    }
}
