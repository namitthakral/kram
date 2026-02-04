import { ValidationPipe } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'
import * as compression from 'compression'
import helmet from 'helmet'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // Security middleware with Flutter-compatible CSP
  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: [
            "'self'",
            "'unsafe-inline'",
            "'unsafe-eval'",
            'https://static.cloudflareinsights.com',
            'https://www.gstatic.com',
          ],
          styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
          fontSrc: ["'self'", 'https://fonts.gstatic.com', 'data:'],
          imgSrc: ["'self'", 'data:', 'https:', 'blob:'],
        connectSrc: [
            "'self'",
            'https://fonts.googleapis.com',
            'https://fonts.gstatic.com',
            'https://www.gstatic.com',
            'https://static.cloudflareinsights.com',
          'https://*.cloudfront.net',      // CloudFront domains
            'https://api.kramedu.in',        // Allow API calls
            'https://dashboard.kramedu.in',  // Allow self-reference
            'https://kramedu.in',            // Allow main domain
          ],
          workerSrc: ["'self'", 'blob:'],
          childSrc: ["'self'", 'blob:'],
          frameSrc: ["'self'"],
        },
      },
      crossOriginEmbedderPolicy: false, // Required for Flutter web
      crossOriginOpenerPolicy: { policy: 'same-origin-allow-popups' },
    })
  )
  app.use(compression())

  // Enable CORS
  app.enableCors({
    origin: [
      'http://localhost:3000',
      /^http:\/\/localhost:\d+$/, // Allow any localhost port
      /^http:\/\/127\.0\.0\.1:\d+$/, // Allow any 127.0.0.1 port
      /^http:\/\/10\.0\.2\.2:\d+$/, // Allow Android emulator
      /^http:\/\/192\.168\.\d+\.\d+:\d+$/, // Allow local network IPs
      /^https?:\/\/.*\.cloudfront\.net$/, // CloudFront distribution
      'https://kramedu.in', // Production domain
      'https://dashboard.kramedu.in', // Dashboard subdomain
      'https://api.kramedu.in', // API subdomain
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

  // No global prefix - routes are at root level (e.g., /auth/login, /students)

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
  console.log(`🔌 API endpoints: http://localhost:${port}/auth/login, /students, etc.`)
  console.log(`🎨 Dashboard: http://localhost:${port}/`)
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`)
}

bootstrap()
