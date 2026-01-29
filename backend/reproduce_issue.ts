import { GoogleGenerativeAI } from '@google/generative-ai';
import * as fs from 'fs';
import * as path from 'path';

// Simple .env loader
function loadEnv() {
    try {
        const envPath = path.resolve(__dirname, '.env');
        if (fs.existsSync(envPath)) {
            const envConfig = fs.readFileSync(envPath, 'utf-8');
            envConfig.split('\n').forEach(line => {
                const match = line.match(/^([^#=]+)=(.*)$/);
                if (match) {
                    const key = match[1].trim();
                    const value = match[2].trim().replace(/^['"]|['"]$/g, '');
                    process.env[key] = value;
                }
            });
        }
    } catch (e) {
        console.error('Error loading .env file', e);
    }
}

loadEnv();

// API Key from .env (using GEMINI_API_KEY as seen in .env)
const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;

if (!apiKey) {
    throw new Error("GEMINI_API_KEY or GOOGLE_API_KEY is not defined in the environment variables.");
}

async function testGemini() {
    console.log('Testing Gemini connection...');
    try {
        const genAI = new GoogleGenerativeAI(apiKey);
        // Using gemini-pro for testing connectivity
        const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

        console.log('Model initialized. Sending prompt...');
        const result = await model.generateContent('Hello, are you there?');
        const response = await result.response;
        console.log('Response received:', response.text());
    } catch (error) {
        console.error('Error connecting to Gemini:', error);
    }
}

testGemini();
