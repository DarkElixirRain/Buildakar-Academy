
import bcrypt from "bcrypt";

export async function hashCode(code: string) {
    return bcrypt.hash(code, 10);
}

export async function compareCode(
    code: string,
    hash: string
) {
    return bcrypt.compare(code, hash);
}