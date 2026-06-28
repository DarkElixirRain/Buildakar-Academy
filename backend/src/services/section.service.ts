// backend/src/services/section.service.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface CreateSectionData {
  title: string;
  description?: string;
  order?: number;
  courseId: string;
}

interface UpdateSectionData {
  title?: string;
  description?: string;
  order?: number;
}

interface ReorderSectionItem {
  id: string;
  order: number;
}

export class SectionService {
  // Create a new section
  async createSection(data: CreateSectionData) {
    // Verify course exists
    const course = await prisma.course.findUnique({
      where: { id: data.courseId },
    });

    if (!course) {
      throw new Error('Course not found');
    }

    // Get the next order if not provided
    let order = data.order;
    if (order === undefined) {
      const lastSection = await prisma.section.findFirst({
        where: { courseId: data.courseId },
        orderBy: { order: 'desc' },
      });
      order = (lastSection?.order || 0) + 1;
    }

    const section = await prisma.section.create({
      data: {
        title: data.title,
        description: data.description,
        order,
        courseId: data.courseId,
      },
      include: {
        lessons: {
          orderBy: { order: 'asc' },
        },
      },
    });

    return section;
  }

  // Get sections for a course
  async getSectionsByCourse(courseId: string) {
    const sections = await prisma.section.findMany({
      where: { courseId },
      include: {
        lessons: {
          orderBy: { order: 'asc' },
        },
        _count: {
          select: { lessons: true },
        },
      },
      orderBy: { order: 'asc' },
    });

    return sections;
  }

  // Get section by ID
  async getSectionById(id: string) {
    const section = await prisma.section.findUnique({
      where: { id },
      include: {
        lessons: {
          orderBy: { order: 'asc' },
        },
        course: {
          select: { id: true, title: true, instructorId: true, status: true },
        },
      },
    });

    return section;
  }

  // Update section
  async updateSection(id: string, data: UpdateSectionData, userId: string, userRole: any) {
    const section = await prisma.section.findUnique({
      where: { id },
      include: { course: true },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    // Check ownership
    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('Not authorized to update this section');
    }

    const updatedSection = await prisma.section.update({
      where: { id },
      data,
      include: {
        lessons: {
          orderBy: { order: 'asc' },
        },
      },
    });

    return updatedSection;
  }

  // Delete section
  async deleteSection(id: string, userId: string, userRole: any) {
    const section = await prisma.section.findUnique({
      where: { id },
      include: { 
        course: true,
        lessons: true,
      },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    // Check ownership
    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('Not authorized to delete this section');
    }

    // Delete section (cascade will delete lessons)
    await prisma.section.delete({
      where: { id },
    });

    // Reorder remaining sections
    await this.reorderAfterDelete(section.courseId, section.order);

    return { success: true, message: 'Section deleted successfully' };
  }

  // Reorder sections
  async reorderSections(courseId: string, sections: ReorderSectionItem[], userId: string, userRole: any) {
    const course = await prisma.course.findUnique({
      where: { id: courseId },
    });

    if (!course) {
      throw new Error('Course not found');
    }

    if (userRole !== 'ADMIN' && course.instructorId !== userId) {
      throw new Error('Not authorized to reorder sections');
    }

    // Verify all sections belong to this course
    const sectionIds = sections.map(s => s.id);
    const existingSections = await prisma.section.findMany({
      where: { id: { in: sectionIds }, courseId },
    });

    if (existingSections.length !== sectionIds.length) {
      throw new Error('One or more sections not found or do not belong to this course');
    }

    // Update all sections in a transaction
    await prisma.$transaction(
      sections.map(section =>
        prisma.section.update({
          where: { id: section.id },
          data: { order: section.order },
        })
      )
    );

    // Return updated sections
    return this.getSectionsByCourse(courseId);
  }

  // Helper: Reorder sections after deletion
  private async reorderAfterDelete(courseId: string, deletedOrder: number) {
    const sections = await prisma.section.findMany({
      where: {
        courseId,
        order: { gt: deletedOrder },
      },
      orderBy: { order: 'asc' },
    });

    await prisma.$transaction(
      sections.map((section, index) =>
        prisma.section.update({
          where: { id: section.id },
          data: { order: deletedOrder + index },
        })
      )
    );
  }

  // Move section to a specific position
  async moveSection(sectionId: string, newOrder: number, userId: string, userRole: any) {
    const section = await prisma.section.findUnique({
      where: { id: sectionId },
      include: { course: true },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('Not authorized to move this section');
    }

    const currentOrder = section.order;
    const courseId = section.courseId;

    if (newOrder === currentOrder) {
      return this.getSectionsByCourse(courseId);
    }

    // Get all sections in the course
    const allSections = await prisma.section.findMany({
      where: { courseId },
      orderBy: { order: 'asc' },
    });

    // Remove the moving section
    const otherSections = allSections.filter(s => s.id !== sectionId);

    // Insert at new position
    otherSections.splice(newOrder - 1, 0, section);

    // Update orders
    await prisma.$transaction(
      otherSections.map((s, index) =>
        prisma.section.update({
          where: { id: s.id },
          data: { order: index + 1 },
        })
      )
    );

    return this.getSectionsByCourse(courseId);
  }
}

export default new SectionService();