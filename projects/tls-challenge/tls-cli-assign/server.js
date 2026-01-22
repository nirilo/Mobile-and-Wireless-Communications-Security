const express = require("express"), 
      https = require("https"),
      fs = require("fs"), 
      path = require("path"),
      port = 4000;

const app = express();
const certDir = path.join(__dirname, 'certificates');
const keyPath = path.join(certDir, 'key.pem');
const certPath = path.join(certDir, 'cert.pem');

// log
if (!fs.existsSync(keyPath) || !fs.existsSync(certPath)) {
  console.error(
    `Missing certificate files. Run:\n\n  tls-cli --out ${certDir} --name localhost\n\nto generate key.pem , cert.pem before starting the server.`
  );
  process.exit(1);
}

const server = https.createServer({
  key:fs.readFileSync(keyPath),
  cert:fs.readFileSync(certPath)
},app);

app.get("/",(request,response)=> response.send('Hello over HTTPS!'));
server.listen(port);
console.log("Server started at localhost :: ", port);
