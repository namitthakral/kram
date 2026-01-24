#!/bin/bash
set -e

echo "===== Starting prebuild hook ====="
cd /var/app/staging

echo "===== Running npm install ====="
npm install --production=false

echo "===== Building schema ====="
npm run build:schema

echo "===== Generating Prisma client ====="
npx prisma generate

echo "===== Building NestJS app ====="
npm run build

echo "===== Prebuild hook completed successfully ====="

