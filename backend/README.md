# Backend Starter — Node.js + Express + TypeScript + Prisma + Neon

## Stack
- **Runtime**: Node.js
- **Framework**: Express
- **Language**: TypeScript
- **ORM**: Prisma
- **Database**: PostgreSQL via Neon

## Project Structure
```
src/
├── controllers/     # Request handlers
├── middleware/      # Error & 404 handlers
├── routes/          # Express routers
├── types/           # Shared TypeScript types
├── lib/
│   └── prisma.ts   # Prisma client singleton
├── app.ts           # Express app setup
└── index.ts         # Entry point
prisma/
└── schema.prisma    # DB schema
```

## Getting Started

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment
Copy `.env.example` to `.env` and fill in your values (already pre-filled with Neon connection string).

### 3. Push schema to database
```bash
npm run prisma:push
# or for migrations:
npm run prisma:migrate
```

### 4. Generate Prisma client
```bash
npm run prisma:generate
```

### 5. Start dev server
```bash
npm run dev
```

## API Endpoints

| Method | Path            | Description       |
|--------|-----------------|-------------------|
| GET    | /health         | Health check      |
| GET    | /api/users      | List all users    |
| GET    | /api/users/:id  | Get user by ID    |
| POST   | /api/users      | Create user       |
| PATCH  | /api/users/:id  | Update user       |
| DELETE | /api/users/:id  | Delete user       |

## Scripts
| Command                  | Description                        |
|--------------------------|------------------------------------|
| `npm run dev`            | Start dev server with hot-reload   |
| `npm run build`          | Compile TypeScript to `dist/`      |
| `npm start`              | Run compiled production build      |
| `npm run prisma:push`    | Push schema changes to DB          |
| `npm run prisma:migrate` | Run migrations                     |
| `npm run prisma:studio`  | Open Prisma Studio (DB GUI)        |
| `npm run prisma:generate`| Regenerate Prisma client           |
