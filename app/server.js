const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || '1.0.0';

const server = http.createServer((req, res) => {
  const path = req.url;
  
  // Health check endpoint
  if (path === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'healthy', 
      version: VERSION 
    }));
    return;
  }
  
  // Readiness check endpoint
  if (path === '/ready') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'ready', 
      version: VERSION 
    }));
    return;
  }
  
  // Main API endpoint
  if (path === '/' || path === '/api') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      message: 'Estafen API - Running on Kubernetes',
      version: VERSION,
      hostname: os.hostname(),
      uptime: Math.floor(process.uptime()),
      timestamp: new Date().toISOString()
    }));
    return;
  }
  
  // 404 Not Found
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(PORT, () => {
  console.log(`🚀 Estafen API v${VERSION} listening on port ${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/health`);
  console.log(`✅ Ready: http://localhost:${PORT}/ready`);
  console.log(`🌐 API: http://localhost:${PORT}/api`);
});
