import { prisma } from './src/lib/prisma';
prisma.category.findMany().then(c => console.log(JSON.stringify(c))).catch(console.error).finally(() => prisma.$disconnect());
