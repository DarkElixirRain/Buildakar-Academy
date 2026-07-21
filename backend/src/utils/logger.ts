type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LEVELS: Record<LogLevel, number> = { debug: 0, info: 1, warn: 2, error: 3 };
const currentLevel: LogLevel = process.env.NODE_ENV === 'production' ? 'info' : 'debug';

const shouldLog = (level: LogLevel): boolean => LEVELS[level] >= LEVELS[currentLevel];

const sensitiveKeys = ['password', 'token', 'secret', 'authorization', 'creditcard', 'ssn'];

const sanitize = (data: unknown, depth = 0): unknown => {
  if (depth > 5 || typeof data !== 'object' || data === null) return data;
  if (Array.isArray(data)) return data.map(item => sanitize(item, depth + 1));
  const obj = { ...data as Record<string, unknown> };
  for (const key of Object.keys(obj)) {
    if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk))) {
      obj[key] = '[REDACTED]';
    } else if (typeof obj[key] === 'object' && obj[key] !== null) {
      obj[key] = sanitize(obj[key], depth + 1);
    }
  }
  return obj;
};

const formatTimestamp = (): string =>
  new Date().toISOString();

const createLogFn = (level: LogLevel) => {
  const label = level.toUpperCase().padEnd(5);
  const logFn = level === 'error' ? console.error : level === 'warn' ? console.warn : console.log;
  return (message: string, ...args: unknown[]) => {
    if (!shouldLog(level)) return;
    const prefix = `[${formatTimestamp()}] [${label}]`;
    if (args.length > 0) {
      logFn(`${prefix} ${message}`, ...args.map(a => sanitize(a)));
    } else {
      logFn(`${prefix} ${message}`);
    }
  };
};

export const logger = {
  debug: createLogFn('debug'),
  info: createLogFn('info'),
  warn: createLogFn('warn'),
  error: createLogFn('error'),
};
