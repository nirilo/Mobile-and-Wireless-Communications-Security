#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { program, InvalidOptionArgumentError } = require('commander');
const forge = require('node-forge');

function parsePositiveInt(v, flag) {
  const n = parseInt(v, 10);
  if (Number.isNaN(n) || n <= 0) {
    throw new InvalidOptionArgumentError(`${flag} must be a positive integer`);
  }
  return n;
}
program
  .option('-o, --out <dir>', 'output directory', './certificates')
  .option('-n, --name <CN>', 'Common Name', 'localhost')
  .option('-b, --bits <n>', 'RSA key size', parsePositiveInt, 2048)
  .option('-d, --days <n>', 'validity in days', parsePositiveInt, 365)
  .option(
  '-s, --san <list>',
  'SAN list (comma-separated)',
  v => v.split(',').map(h => h.trim()),
  [] 
).parse();

const { out, name, bits, days, san } = program.opts();

let sanEntr = san;
if (sanEntr.length === 0) {
  sanEntr = [ name ];
  if (name !== '127.0.0.1') {
    sanEntr.push('127.0.0.1');
  }
}


try {
  fs.mkdirSync(out, { recursive: true });
} catch (err) {
  console.error(`Could not create output folder "${out}": ${err.message}`);
  process.exit(1);
}

const keys = forge.pki.rsa.generateKeyPair(bits);

const cert = forge.pki.createCertificate();
cert.publicKey = keys.publicKey;

cert.serialNumber = forge.util.bytesToHex(forge.random.getBytesSync(16));
cert.validity.notBefore = new Date();
cert.validity.notAfter = new Date(Date.now() + days * 24 * 60 * 60 * 1000);

const attrs = [{ name: 'commonName', value: name }];
cert.setSubject(attrs);
cert.setIssuer(attrs);

//SAN
const altNames = sanEntr.map(h =>
  /^\d+\.\d+\.\d+\.\d+$/.test(h)
    ? { type: 7, ip: h }           //IP
    : { type: 2, value: h }        //DNS
);
cert.setExtensions([{name:'subjectAltName',altNames}]);
cert.sign(keys.privateKey, forge.md.sha256.create());
try {
  fs.writeFileSync(path.join(out, 'key.pem'), forge.pki.privateKeyToPem(keys.privateKey), { mode: 0o600 });
  fs.writeFileSync(path.join(out, 'cert.pem'), forge.pki.certificateToPem(cert));
} catch (err) {
  console.error(`Could not write PEM files: ${err.message}`);
  process.exit(1);
}
console.log(`Generated cert.pem & key.pem (${bits}-bit, ${days} day${days > 1 ? 's' : ''}) in ${out}`);
