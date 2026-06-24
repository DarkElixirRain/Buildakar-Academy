import app from './app';
import { config } from './config';

const startServer = async () => {
  try {
    app.listen(config.port, () => {
      console.log(`🚀 Server running on http://localhost:${config.port}`);
      console.log(`📖 Environment: ${config.nodeEnv}`);
      console.log(`🔐 JWT Secret: ${config.jwt.secret ? '✅ Set' : '❌ Not set'}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();