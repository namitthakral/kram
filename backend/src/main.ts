import { NestFactory } from '@nestjs/core'
import { ValidationPipe } from '@nestjs/common'
import helmet from 'helmet'
import * as compression from 'compression'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // Security middleware
  app.use(helmet())
  app.use(compression())

  // Enable CORS
  app.enableCors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true,
  })

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    })
  )

  // Global prefix for all routes
  app.setGlobalPrefix('api')

  // Health check endpoint
  app.getHttpAdapter().get('/health', (req, res) => {
    res.json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      service: 'ed-verse-backend',
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
    })
  })

  const port = process.env.PORT || 3000
  await app.listen(port)

  console.log(`🚀 Ed-verse NestJS server running on port ${port}`)
  console.log(`📊 Health check: http://localhost:${port}/health`)
  console.log(`🔌 API endpoint: http://localhost:${port}/api`)
  console.log(`📚 API docs: http://localhost:${port}/api/docs`)
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`)
}

bootstrap()
