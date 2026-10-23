#!/bin/bash

# GitHub Project Doctor - Quick Start Script

echo "🩺 GitHub Project Doctor - Starting Application"
echo ""

# Check if .env exists
if [ ! -f server/.env ]; then
    echo "⚠️  Warning: server/.env not found. Creating from .env.example..."
    cp server/.env.example server/.env
    echo "✅ Created server/.env - Please add your API keys!"
    echo ""
fi

# Start backend
echo "🚀 Starting backend server..."
cd server
npm run dev &
BACKEND_PID=$!
cd ..

# Wait for backend to start
echo "⏳ Waiting for backend to initialize..."
sleep 3

# Start frontend
echo "🚀 Starting frontend..."
cd client
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Application started!"
echo ""
echo "📍 Frontend: http://localhost:5173"
echo "📍 Backend:  http://localhost:3001"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for user interrupt
trap "echo ''; echo '🛑 Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT

wait
