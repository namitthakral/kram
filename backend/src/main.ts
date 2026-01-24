import { ValidationPipe } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'
import * as compression from 'compression'
import helmet from 'helmet'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // Security middleware
  app.use(helmet())
  app.use(compression())

  // Enable CORS
  app.enableCors({
    origin: [
      'http://localhost:3000',
      /^http:\/\/localhost:\d+$/, // Allow any localhost port
      /^http:\/\/127\.0\.0\.1:\d+$/, // Allow any 127.0.0.1 port
      /^http:\/\/10\.0\.2\.2:\d+$/, // Allow Android emulator
      /^http:\/\/192\.168\.\d+\.\d+:\d+$/, // Allow local network IPs
      /^https?:\/\/.*\.elasticbeanstalk\.com$/, // Allow EB domains
      /^https?:\/\/.*\.cloudfront\.net$/, // Allow CloudFront
      'https://kramedu.in', // Production domain
    ],
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
  await app.listen(port, '0.0.0.0')

  console.log(`🚀 Ed-verse NestJS server running on port ${port}`)
  console.log(`🔐 Listening on 0.0.0.0:${port}`)
  console.log(`📊 Health check: http://localhost:${port}/health`)
  console.log(`🔌 API endpoint: http://localhost:${port}/api`)
  console.log(`📚 API docs: http://localhost:${port}/api/docs`)
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`)
}

bootstrap()
