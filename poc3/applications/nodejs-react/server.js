const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'nodejs-hello-world'
  });
});

// Hello World API endpoint
app.get('/api/hello', (req, res) => {
  res.json({ 
    message: 'Hello World from Node.js!',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    technology: 'Node.js + Express'
  });
});

// Hello with name parameter
app.get('/api/hello/:name', (req, res) => {
  const { name } = req.params;
  res.json({ 
    message: `Hello ${name} from Node.js!`,
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'Node.js Hello World API',
    version: '1.0.0',
    endpoints: [
      'GET /health - Health check',
      'GET /api/hello - Hello World message',
      'GET /api/hello/:name - Personalized hello message'
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

app.listen(PORT, () => {
  console.log(`Node.js Hello World API server running on port ${PORT}`);
  console.log(`Visit http://localhost:${PORT}/api/hello to test the API`);
});

module.exports = app;