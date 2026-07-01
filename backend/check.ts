import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
prisma.category.findMany().then(c => console.log(JSON.stringify(c))).catch(console.error).finally(() => prisma.$disconnect());
