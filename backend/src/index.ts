// server.ts or index.ts
import app from './app';
import { config } from './config';

const PORT = config.port || 8081;

// Listen on all network interfaces (0.0.0.0)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  });