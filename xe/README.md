# xe - Web Development Script

A modular Bash script that simplifies web development tasks by automatically detecting your package manager (bun, pnpm, or npm) and running the appropriate commands.

**Features:**
- Automatic package manager detection via lock files
- Universal commands that work across all package managers
- Built-in Prisma and shadcn/ui support
- Clean, colorful terminal output

## Installation

**Prerequisites:** macOS or Linux with Bash

### Quick Install (Recommended)

Run this single command to install xe:

```bash
# If you've cloned the repo:
bash ./xe/install.sh

# Or download and run in one command:
curl -fsSL https://raw.githubusercontent.com/akdevv/micro-utils/main/xe/install.sh | bash

# Or with wget:
wget -qO- https://raw.githubusercontent.com/akdevv/micro-utils/main/xe/install.sh | bash
```

### Manual Installation

If you prefer to install manually:

1. Download the `xe` script
2. Make it executable: `chmod +x xe`
3. Move to your PATH: `sudo mv xe /usr/local/bin/`
4. Verify: `xe --help`

## Commands

### Core Commands

**`xe install` / `xe i`**
```bash
xe install              # Install all dependencies
xe install axios        # Install specific package
xe i react typescript   # Install multiple packages
```

**`xe dev`**
```bash
xe dev                  # Start development server
```
Checks for node_modules and prompts to install if missing.

**`xe dev init`**
```bash
xe dev init             # Full project setup
```
Runs: install → prisma → dev server

**`xe build`**
```bash
xe build                # Build for production
```

**`xe lint`**
```bash
xe lint                 # Run linting
```

### Database (Prisma)

**`xe prisma`**
```bash
xe prisma               # Run: generate + db push + db pull  
```

**`xe prisma migrate`**
```bash
xe prisma migrate --name add_users    # Create named migration
xe prisma migrate                     # Auto-generate name
```

**`xe prisma reset`**
```bash
xe prisma reset         # Reset database
```

### UI Components (shadcn/ui)

**`xe shadcn init`**
```bash
xe shadcn init          # Initialize shadcn/ui
```

**`xe shadcn add`**
```bash
xe shadcn add button    # Add component
```

## Package Manager Detection

xe automatically detects your package manager:

| Lock File | Package Manager |
|-----------|----------------|
| `bun.lock` | bun |
| `pnpm-lock.yaml` | pnpm |
| `package-lock.json` | npm |

## Usage Examples

```bash
# New project setup
xe dev init

# Daily development  
xe dev
xe install lodash
xe shadcn add card

# Database operations
xe prisma migrate --name add_users
xe prisma reset
```