// server.ts or index.ts
import app from './app';
import { config } from './config';

const PORT = config.port || 8081;

// Listen on all network interfaces (0.0.0.0)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\x1b[32m✅ Server is running!\x1b[0m`);
  console.log(`\x1b[36m📍 Local:\x1b[0m http://localhost:${PORT}`);
  console.log(`\x1b[36m📍 Network:\x1b[0m http://YOUR_IP:${PORT}`);
  console.log(`\x1b[33m⚠️  CORS is wide open (development mode)\x1b[0m`);
  console.log(`\x1b[33m📱 Access from any device on the same network\x1b[0m`);
});