# 🩺 GitHub Project Doctor

Diagnoses why a student developer's GitHub repository is difficult for a stranger to understand, run, or evaluate — and provides a prioritized treatment plan.

## Tech Stack

- **Frontend**: React + Vite, TailwindCSS
- **Backend**: Node.js + Express
- **APIs**: GitHub REST API, OpenAI API

## Getting Started

### Prerequisites

- Node.js 18+
- A GitHub Personal Access Token (optional, increases rate limits)
- An OpenAI API key (for diagnosis generation)

### Setup

```bash
# Clone the repo
git clone <repo-url>
cd github-project-doctor

# Backend
cd server
cp .env.example .env
# Edit .env with your API keys
npm install
npm run dev

# Frontend (new terminal)
cd client
npm install
npm run dev
```

Open http://localhost:5173 in your browser.

## How It Works

1. Enter a public GitHub repository URL
2. The backend fetches repo data via GitHub's REST API (metadata, README, file tree, configs)
3. Raw data is analyzed into a "Diagnostic Evidence Object" (boolean flags like `hasReadme`, `hasInstallCommand`, etc.)
4. The evidence is sent to an LLM which generates a structured diagnostic report
5. The frontend displays a health score and prioritized issues with fixes
