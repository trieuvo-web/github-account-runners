# GitHub Account-Level Self-Hosted Runners

Self-hosted GitHub Actions runners deployed with Docker Compose, registered at the account level to serve all repositories in your GitHub account.

## Features

- **Account-Level Registration**: Runners are registered at the account level, serving all repositories without requiring workflow modifications
- **Docker Support**: Runners have Docker CLI and can execute Docker jobs in workflows
- **Auto-scaling**: Easily scale to multiple runner containers
- **Auto-registration**: Runners automatically register on container start
- **Auto-cleanup**: Runners automatically deregister when containers stop

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/trieuvo-web/github-account-runners.git
cd github-account-runners
cp .env.example .env
```

### 2. Update .env File

Edit `.env` and set your GitHub account details:

```bash
GITHUB_ACCOUNT=YOUR_USERNAME
GITHUB_TOKEN=your_github_personal_access_token
RUNNER_NAME_PREFIX=docker-runner
RUNNER_LABELS=self-hosted,docker,linux
RUNNER_WORKDIR=/runner/_work
```

### 3. Get GitHub Token

Create a Personal Access Token (PAT) with these permissions:
- `repo` (full control of private repositories)
- `workflow` (update workflow files)
- `admin:repo_hook` (manage repository hooks)

### 4. Start the Runner

```bash
docker compose up -d
```

### 5. Verify

Check your runners at: https://github.com/settings/actions/runners

## Scale Runners

To run multiple runners in parallel:

```bash
docker compose up -d --scale github-runner=5
```

To check status:

```bash
docker compose ps
docker compose logs -f
```

## Stop Runners

```bash
docker compose down
```

When containers stop, runners are automatically deregistered from your GitHub account.

## Project Structure

```
github-account-runners/
├── docker-compose.yml      # Docker Compose configuration
├── .env.example            # Environment variables template
├── .gitignore
├── runner/
│   ├── Dockerfile          # Runner image definition
│   └── entrypoint.sh       # Runner startup script
└── scripts/
    ├── get-runner-token.sh # Get registration token
    ├── register-runner.sh  # Register runner
    └── remove-runner.sh    # Remove runner
```

## Workflow Usage

To use these runners in any repository, add `self-hosted` label to your workflow:

```yaml
jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Build with Docker
        run: docker build .
```

Or specify the labels:

```yaml
jobs:
  build:
    runs-on: self-hosted,docker,linux
    steps:
      - uses: actions/checkout@v4
```

## Requirements

- Docker Engine
- Docker Compose
- GitHub account with sufficient permissions
- Personal Access Token with required scopes
