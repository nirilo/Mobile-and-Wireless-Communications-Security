# TLS / HTTPS Challenge (Node.js)

Coursework mini-project for the **Mobile and Wireless Communications Security** syllabus.
Includes a small Node.js setup that generates a self-signed TLS certificate and starts an HTTPS server for testing.

## Contents
- `index.js` — generates TLS cert/key (self-signed) and writes them to disk.
- `server.js` — HTTPS server that loads the cert/key and serves a simple response.
- `package.json` — dependencies/scripts.
- `TLS_Challenge.pdf*` — report.

## Quick run (optional)
```bash
npm install
node index.js
node server.js
```

🟇
