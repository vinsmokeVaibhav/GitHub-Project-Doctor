# 🩺 GitHub Project Doctor - Setup Guide

## ✅ What's Been Built

### Backend (Express + Node.js)
- ✅ Express server with CORS configured for frontend
- ✅ GitHub REST API integration (fetches repo metadata, README, file tree, dependencies)
- ✅ Evidence builder that analyzes repo data into diagnostic flags
- ✅ POST /api/diagnose endpoint that accepts GitHub URLs
- ✅ Validation and error handling for invalid URLs and missing repos

**Files:**
- `server/src/index.js` - Main Express server
- `server/src/routes/diagnose.js` - Diagnosis endpoint with URL parsing
- `server/src/services/github.js` - GitHub API client (parallel fetching)
- `server/src/services/evidence.js` - Evidence analysis logic

### Frontend (React + Vite + TailwindCSS)
- ✅ HomeScreen - URL input with validation
- ✅ LoadingScreen - Animated progress with step indicators
- ✅ ReportScreen - Displays health score and categorized issues
- ✅ ScoreGauge - Circular health score visualization (0-100)
- ✅ IssueCard - Shows problem, evidence, impact, fix, and effort
- ✅ Full responsive design with Tailwind utilities

**Files:**
- `client/src/App.jsx` - Main app with 3-screen state management
- `client/src/components/HomeScreen.jsx`
- `client/src/components/LoadingScreen.jsx`
- `client/src/components/ReportScreen.jsx`
- `client/src/components/ScoreGauge.jsx`
- `client/src/components/IssueCard.jsx`

## 🚀 Quick Start

### 1. Install Dependencies (Already Done)
```bash
# Backend
cd server
npm install

# Frontend
cd ../client
npm install
```

### 2. Configure Environment Variables
Edit `server/.env` and add your API keys:
```
PORT=3001
GITHUB_TOKEN=your_github_token_here     # Optional but recommended for higher rate limits
OPENAI_API_KEY=your_openai_key_here     # Required for LLM diagnosis (next step)
```

Get a GitHub token at: https://github.com/settings/tokens

### 3. Start the Backend
```bash
cd server
npm run dev
```

You should see: `🩺 GitHub Project Doctor server running on port 3001`

### 4. Start the Frontend (New Terminal)
```bash
cd client
npm run dev
```

Open http://localhost:5173

### 5. Test It Out
Try analyzing a repository:
- Example: `https://github.com/facebook/react`
- Example: `https://github.com/vercel/next.js`

**Current behavior:** The backend returns raw evidence data. The LLM integration (next step) will transform this into a diagnosis report.

## 🔧 What's Next: LLM Integration

The current `/api/diagnose` endpoint returns evidence like this:
```json
{
  "evidence": {
    "hasReadme": true,
    "hasInstallCommand": true,
    "readmeLength": 5432,
    "hasEnvExample": false,
    ...
  }
}
```

### Next Step: Add LLM Service

Create `server/src/services/llm.js`:

```javascript
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const SYSTEM_PROMPT = `You are the "GitHub Project Doctor," an expert developer experience (DX) engineer. Your job is to analyze the provided raw evidence from a student developer's GitHub repository and diagnose why it might be difficult for a stranger to understand, run, or evaluate.

You are NOT a code reviewer. Do not review the logic of the code, judge the developer's ability, or evaluate production readiness. Your strictly defined scope is: Repository context, setup requirements, documentation, and demonstration.

Rules for Diagnosis:
1. ONLY rely on the evidence provided in the JSON input. Do not hallucinate missing files or assume standard practices exist if they are not in the evidence.
2. Focus on the "Stranger Test": Can a stranger clone, install, configure, run, and understand this project without asking the author questions?
3. Prioritize issues strictly into three categories:
   - "Critical" (🔴): The app cannot be started or understood (e.g., missing install steps, missing environment variables, missing database seed instructions).
   - "Important" (🟠): The app can be started but lacks context (e.g., missing node version, missing architecture overview, no screenshots).
   - "Improvement" (🟡): Best practices for a portfolio (e.g., missing license, missing contribution guidelines).

Output format MUST be a strict JSON object with the following structure:
{
  "score": <integer 0-100 based on the severity of issues>,
  "repoName": "<repository name>",
  "summary": "<one-sentence overall assessment>",
  "critical": [
    {
      "problem": "<concise issue statement>",
      "evidence": "<directly observable fact>",
      "impact": "<why this matters to a stranger>",
      "fix": "<actionable steps with code snippets if applicable>",
      "effort": "<time estimate like '~5 minutes'>"
    }
  ],
  "important": [...],
  "improvements": [...]
}`;

export async function generateDiagnosis(evidence) {
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: `Analyze this repository evidence:\n\n${JSON.stringify(evidence, null, 2)}` }
    ],
    response_format: { type: 'json_object' },
    temperature: 0.7,
  });

  return JSON.parse(completion.choices[0].message.content);
}
```

Then update `server/src/routes/diagnose.js`:

```javascript
import { generateDiagnosis } from '../services/llm.js';

// ... in the POST / handler, after building evidence:
const evidence = buildEvidence(repoData);
const diagnosis = await generateDiagnosis(evidence);  // Add this line
res.json(diagnosis);  // Change from res.json({ evidence })
```

Install the OpenAI SDK:
```bash
cd server
npm install openai
```

Restart the server and test again!

## 📊 Expected Report Structure

After LLM integration, the frontend will receive:
```json
{
  "score": 65,
  "repoName": "my-cool-app",
  "summary": "The project is runnable but lacks clear setup instructions and environment configuration guidance.",
  "critical": [
    {
      "problem": "No installation instructions in README",
      "evidence": "README exists (2,341 chars) but contains no 'npm install', 'pip install', or similar commands",
      "impact": "A stranger cannot install dependencies without guessing the package manager",
      "fix": "Add a '## Installation' section:\n```bash\nnpm install\n# or\nyarn install\n```",
      "effort": "~3 minutes"
    }
  ],
  "important": [...],
  "improvements": [...]
}
```

## 🧪 Testing Tips

1. **Test with various repo types:**
   - Well-documented repos (should score 80-100)
   - Bare-bones repos (should score 20-40)
   - Medium repos (should score 40-70)

2. **Test error cases:**
   - Invalid URLs
   - Private repos (should return 404)
   - Non-existent repos

3. **Check rate limits:**
   - Without GITHUB_TOKEN: 60 requests/hour
   - With GITHUB_TOKEN: 5,000 requests/hour

## 🎨 UI Features

- **Health Score Gauge**: Color-coded (red <40, orange 40-70, green >70)
- **Collapsible Sections**: Click to expand/collapse issue categories
- **Responsive Design**: Works on mobile and desktop
- **Smooth Animations**: Loading states, transitions, progress bars

## 📝 Architecture Notes

- **Stateless**: No database, each request is independent
- **Parallel Fetching**: GitHub API calls run concurrently for speed
- **Error Handling**: Graceful fallbacks for missing files (404s)
- **Rate Limit Awareness**: Uses GitHub token when available
- **Proxy Configuration**: Vite proxies `/api` to avoid CORS issues

## 🐛 Known Limitations

1. Only analyzes public repositories
2. Fetches only root-level file tree (not nested directories)
3. README truncated to 3,000 chars for LLM context
4. No caching (each request hits GitHub API fresh)

## 🚀 Future Enhancements

- Add support for GitLab/Bitbucket
- Cache GitHub responses (Redis/memory)
- Generate automated PRs with fixes
- Support for monorepos
- Export report as PDF/markdown
- CLI version of the tool

---

**Current Status:** MVP backend + frontend ready. Add LLM integration to complete the flow!