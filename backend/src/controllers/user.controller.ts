import { Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { ApiResponse } from "../types/api.types";

// GET /api/users
export async function getAllUsers(
  _req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const users = await prisma.user.findMany({
      orderBy: { createdAt: "desc" },
    });
    const response: ApiResponse = { success: true, data: users };
    res.json(response);
  } catch (err) {
    next(err);
  }
}

// GET /api/users/:id
export async function getUserById(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const id = Number(req.params.id);
    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) {
      res.status(404).json({ success: false, error: "User not found" });
      return;
    }

    res.json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

// POST /api/users
export async function createUser(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { email, name } = req.body as { email: string; name?: string };

    if (!email) {
      res.status(400).json({ success: false, error: "email is required" });
      return;
    }

    const user = await prisma.user.create({ data: { email, name } });
    res.status(201).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

// PATCH /api/users/:id
export async function updateUser(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const id = Number(req.params.id);
    const { email, name } = req.body as { email?: string; name?: string };

    const user = await prisma.user.update({
      where: { id },
      data: { email, name },
    });

    res.json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

// DELETE /api/users/:id
export async function deleteUser(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const id = Number(req.params.id);
    await prisma.user.delete({ where: { id } });
    res.json({ success: true, message: "User deleted" });
  } catch (err) {
    next(err);
  }
}
