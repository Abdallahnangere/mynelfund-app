const admin = require('firebase-admin');
const path = require('path');
const https = require('https');

const serviceAccount = require(path.join(__dirname, 'service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const rulesContent = `rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /faqs/{faqId} {
      allow read: if true;
      allow write: if false;
    }
    match /notifications/{notifId} {
      allow read: if true;
      allow write: if false;
    }
    match /user_preferences/{deviceId} {
      allow read, write: if true;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}`;

async function deployRules() {
  const tokenObj = await admin.app().options.credential.getAccessToken();
  const token = tokenObj.access_token;
  const projectId = serviceAccount.project_id;

  console.log('Project ID:', projectId);
  console.log('Got access token. Creating ruleset...');

  // 1. Create Ruleset
  const createRulesetPayload = JSON.stringify({
    source: {
      files: [
        {
          name: 'firestore.rules',
          content: rulesContent,
        },
      ],
    },
  });

  const rulesetRes = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    path: `/v1/projects/${projectId}/rulesets`,
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(createRulesetPayload),
    },
  }, createRulesetPayload);

  console.log('Create ruleset response:', rulesetRes);
  const rulesetName = JSON.parse(rulesetRes).name;
  console.log('New ruleset name:', rulesetName);

  // 2. Release Ruleset to cloud.firestore
  const releasePayload = JSON.stringify({
    release: {
      name: `projects/${projectId}/releases/cloud.firestore`,
      rulesetName: rulesetName,
    },
  });

  const releaseRes = await makeRequest({
    hostname: 'firebaserules.googleapis.com',
    path: `/v1/projects/${projectId}/releases/cloud.firestore`,
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(releasePayload),
    },
  }, releasePayload);

  console.log('Release response:', releaseRes);
  console.log('Successfully deployed and activated new Firestore security ruleset!');
  process.exit(0);
}

function makeRequest(options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve(body));
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

deployRules().catch((err) => {
  console.error('Error deploying rules:', err);
  process.exit(1);
});
