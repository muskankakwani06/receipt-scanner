const http = require('http');
const https = require('https');

const PORT = 3001;

const server = http.createServer((req, res) => {
  // Allow requests from the local web server
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'OPTIONS, POST');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, x-api-key, anthropic-version, anthropic-dangerously-allow-browser');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  if (req.method === 'POST') {
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', () => {
      const buffer = Buffer.concat(body);
      
      const options = {
        hostname: 'api.anthropic.com',
        path: '/v1/messages',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': req.headers['x-api-key'],
          'anthropic-version': req.headers['anthropic-version']
        }
      };

      const proxyReq = https.request(options, proxyRes => {
        // We do not need to forward all headers, just the response
        res.writeHead(proxyRes.statusCode, {
          'Content-Type': proxyRes.headers['content-type'] || 'application/json',
          'Access-Control-Allow-Origin': '*'
        });
        proxyRes.pipe(res, { end: true });
      });

      proxyReq.on('error', e => {
        console.error('Proxy Request Error:', e);
        res.writeHead(500);
        res.end(JSON.stringify({ error: { message: e.message } }));
      });

      proxyReq.write(buffer);
      proxyReq.end();
    });
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.listen(PORT, () => {
  console.log(`CORS Proxy running on http://localhost:${PORT}`);
});
