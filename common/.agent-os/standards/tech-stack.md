# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- Language: TypeScript/JavaScript
- Runtime: Node.js 22 LTS
- Package Manager: pnpm (preferred) / yarn
- JavaScript Runtime: Bun (for development/tooling)
- CLI Tool Runtime: tsx
- App Framework: Next.js latest
- Frontend Framework: React latest stable
- Build Tool: Turbo (monorepo)
- Monorepo Structure: Turborepo workspace
- Import Strategy: ES modules
- CSS Framework: TailwindCSS 4.0+
- UI Components: Radix UI / shadcn/ui
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Lucide React components
- Primary Database: PostgreSQL 17+
- ORM: Prisma / Drizzle
- Application Hosting: Vercel / Digital Ocean App Platform
- Hosting Region: Primary region based on user base
- Database Hosting: Digital Ocean Managed PostgreSQL / Supabase
- Database Backups: Daily automated
- Asset Storage: Amazon S3 / Vercel Blob
- CDN: CloudFront / Vercel Edge
- Asset Access: Private with signed URLs
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Tests: Vitest / Jest with React Testing Library
- Production Environment: main branch
- Staging Environment: staging branch
