const express = require('express');
const cors = require('cors');
const path = require('path');
const admin = require('firebase-admin');

const serviceAccountPath = path.join(__dirname, 'service-account.json');

let db = null;
let messaging = null;

try {
  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
  });
  db = admin.firestore();
  messaging = admin.messaging();
  console.log('[NELFund Admin] Firebase Admin SDK initialized successfully.');
} catch (error) {
  console.error('[NELFund Admin] Failed to initialize Firebase Admin SDK:', error);
}

const app = express();
const PORT = process.env.PORT || 4040;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Default statutory FAQs dataset
const STATUTORY_FAQS = [
  {
    id: 'app_1',
    category: 'applying',
    question: 'How do I apply for the student loan?',
    questionHa: 'Ta yaya zan nemi bashin dalibai?',
    answer: 'Applications are submitted strictly through the official portal at nelf.gov.ng. Verify your NIN, BVN, and matriculation number via the Student Verification System (SVS).',
    answerHa: 'Ana cika takardar neman bashi ne kawai ta hanyar shafin yanar gizo na nelf.gov.ng. Tabbatar da NIN, BVN, da lambar shiga makaranta ta Tsarin Tabbatar da Dalibai (SVS).',
    statutoryReference: 'Students Loans (Access to Higher Education) (Repeal and Re-enactment) Act 2024, Section 3',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 3'
  },
  {
    id: 'app_2',
    category: 'applying',
    question: 'What are the core eligibility requirements?',
    questionHa: 'Wadanne muhimman sharudda ne ake bukata don cancanta?',
    answer: 'Applicants must be admitted into a federal or state-owned university, polytechnic, college of education, or vocational center. Admission must be cleared through JAMB CAPS.',
    answerHa: 'Dole ne mai nema ya sami gurbin karatu a jami\'ar gwamnatin tarayya ko jiha, kwalejin foliteknik, ko kwalejin ilimi. Dole ne a amince da shiga ta hanyar JAMB CAPS.',
    statutoryReference: 'Students Loans Act 2024, Section 2.1',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 2.1'
  },
  {
    id: 'app_3',
    category: 'applying',
    question: 'What constitutes statutory disqualification?',
    questionHa: 'Wadanne abubuwa ne ke hana mutum samun bashi a doka?',
    answer: 'Conviction for fraud or dishonesty, past default on loan facilities, suspension/expulsion from school, or submission of forged documentation.',
    answerHa: 'Yanke hukunci saboda zamba, rashin biyan wani bashi a baya, kora ko dakatarwa daga makaranta, ko mika takardun bogi.',
    statutoryReference: 'Students Loans Act 2024, Section 5.1 & Criminal Code',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 5.1'
  },
  {
    id: 'disb_1',
    category: 'disbursement',
    question: 'How are institutional fees disbursed?',
    questionHa: 'Ta yaya ake biyan kudin makaranta?',
    answer: 'Institutional fees (tuition and mandatory charges) are paid 100% directly into the verified account of the tertiary institution after clearance.',
    answerHa: 'Kudaden makaranta ana tura su kai-tsaye 100% zuwa asusun banki na makarantar gaba da sakandare bayan an kammala tantancewa.',
    statutoryReference: 'Students Loans Act 2024, Section 4.2',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 4.2'
  },
  {
    id: 'disb_2',
    category: 'disbursement',
    question: 'How is student upkeep paid to beneficiaries?',
    questionHa: 'Ta yaya ake biyan alawus na tallafin rayuwa ga dalibai?',
    answer: 'Upkeep is disbursed at the rate of N20,000 per collected month directly into the student verified personal bank account linked to their BVN.',
    answerHa: 'Ana tura kudin tallafin rayuwa N20,000 a kowane wata kai-tsaye zuwa asusun banki na dalibi da ke da alaka da lambar BVN dinsa.',
    statutoryReference: 'NELFUND Operational Guidelines 2024, Section 4.3',
    statutoryReferenceHa: 'Ka\'idojin Gudanarwa na NELFUND 2024, Sashe na 4.3'
  },
  {
    id: 'disb_3',
    category: 'disbursement',
    question: 'What happens if my institution changes fees after approval?',
    questionHa: 'Me zai faru idan makarantata ta canza kudin makaranta bayan an amince?',
    answer: 'Reconciliation must be executed by the institution desk officer through the SVS portal prior to fund release.',
    answerHa: 'Dole ne jami\'in makarantar ya gyara bayanan ta shafin SVS kafin a fitar da kudaden.',
    statutoryReference: 'Financial Regulations S. 12',
    statutoryReferenceHa: 'Ka\'idojin Kudi Sashe na 12'
  },
  {
    id: 'disb_4',
    category: 'disbursement',
    question: 'What is the refund policy for institutional overpayments?',
    questionHa: 'Menene ka\'idar mayar da kudi idan an biya makaranta sama da kima?',
    answer: 'Under Section 4.1.2 of the Operational Guidelines, tertiary institutions must refund any unearned or overpaid fees back to NELFUND within 30 calendar days.',
    answerHa: 'Karkashin Sashe na 4.1.2 na Ka\'idoji, dole ne makarantu su mayar da kudin da aka biya sama da kima ga NELFUND a cikin kwanaki 30.',
    statutoryReference: 'NELFUND Operational Guidelines, Section 4.1.2',
    statutoryReferenceHa: 'Ka\'idojin Gudanarwa na NELFUND, Sashe na 4.1.2'
  },
  {
    id: 'rep_1',
    category: 'repayment',
    question: 'When does mandatory repayment begin?',
    questionHa: 'A wane lokaci ne doka ta tanadi fara biyan bashi?',
    answer: 'Repayment commences exactly 2 years following the completion of the National Youth Service Corps (NYSC) program or mandatory exemption.',
    answerHa: 'Biyan bashi yana farawa ne daidai shekaru 2 bayan kammala aikin yi wa kasa (NYSC) ko kuma samun takardar yaye.',
    statutoryReference: 'Students Loans Act 2024, Section 6.1',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 6.1'
  },
  {
    id: 'rep_2',
    category: 'repayment',
    question: 'What percentage is deducted from salary?',
    questionHa: 'Kashi nawa ne za a rika cirewa daga albashi?',
    answer: 'For formally employed beneficiaries, 10% is deducted monthly from gross salary at source by the employer under PAYE remittance.',
    answerHa: 'Ga masu aikin gwamnati ko kamfani, ana cire kashi 10% a kowane wata daga albashinsu ta hannun ma\'aikata.',
    statutoryReference: 'Students Loans Act 2024, Section 6.2a',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 6.2a'
  },
  {
    id: 'rep_3',
    category: 'repayment',
    question: 'How do self-employed or entrepreneurs repay?',
    questionHa: 'Ta yaya masu sana\'ar hannu ko kasuwanci ke biyan bashi?',
    answer: 'Self-employed beneficiaries remit 10% of their monthly business profit or voluntary equal installments through the designated NELFUND portal.',
    answerHa: 'Masu zaman kansu suna biyan kashi 10% ne daga ribar kasuwancinsu ta wata ko kuma biyan wani adadi ta dandalin NELFUND.',
    statutoryReference: 'Students Loans Act 2024, Section 6.2b',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 6.2b'
  },
  {
    id: 'rep_4',
    category: 'repayment',
    question: 'Is there any interest charged on the loan?',
    questionHa: 'Akwai kudin ruwa a kan wannan lamuni?',
    answer: 'Zero percent (0%). Under Section 15 of the 2024 Act, the loan is strictly interest-free. Beneficiaries repay only the exact principal disbursed.',
    answerHa: 'Kashi sifili (0%). Karkashin Sashe na 15 na Dokar 2024, bashin ba shi da kudin ruwa ko kadan. Ainihin kudin da aka ba ka shi kadai za ka mayar.',
    statutoryReference: 'Students Loans Act 2024, Section 15',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 15'
  },
  {
    id: 'rep_5',
    category: 'repayment',
    question: 'What if I am still unemployed after the 2-year grace period?',
    questionHa: 'Idan har yanzu ban sami aiki ba bayan cikar shekaru 2 na sassauci?',
    answer: 'You are protected under Section 5.1(c). Submitting a statutory declaration or sworn affidavit of unemployment suspends deduction without interest or penalties.',
    answerHa: 'Doka ta kare ka a Sashe na 5.1(c). Mika takardar rantsuwa ta rashin aikin yi zai sa a dakatar da biyan bashi ba tare da tara ko ruwa ba har ka sami aiki.',
    statutoryReference: 'Students Loans Act 2024, Section 5.1c',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 5.1c'
  },
  {
    id: 'rec_1',
    category: 'defaultRecovery',
    question: 'What is the Global Standing Instruction (GSI)?',
    questionHa: 'Menene Umarnin Karbar Bashi na Bankuna (GSI)?',
    answer: 'GSI is a CBN-mandated electronic recovery mandate that debits linked bank accounts across all Nigerian commercial banks in the event of persistent default.',
    answerHa: 'GSI tsari ne na Babban Bankin Najeriya (CBN) da ke cire kudi ta hanyar lantarki daga kowane asusun bankin da mutum yake da shi idan ya ki biyan bashi da gangan.',
    statutoryReference: 'CBN Global Standing Instruction (GSI) Guidelines 2020',
    statutoryReferenceHa: 'Ka\'idojin GSI na Babban Bankin Najeriya (CBN) 2020'
  },
  {
    id: 'rec_2',
    category: 'defaultRecovery',
    question: 'Can employers be penalized for failing to remit deductions?',
    questionHa: 'Za a iya hukunta ma\'aikata idan ba su tura kudin da aka cire ba?',
    answer: 'Yes. Employers who fail to remit the 10% monthly deduction within 30 days commit a statutory offense punishable by fines and liability for arrears.',
    answerHa: 'Kwarai kuwa. Duk ma\'aikacin da ya ki tura kashi 10% a cikin kwanaki 30 ya aikata laifi da za a iya ci tararsa a doka.',
    statutoryReference: 'Students Loans Act 2024, Section 8.3',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 8.3'
  },
  {
    id: 'rec_3',
    category: 'defaultRecovery',
    question: 'What are the penalties for providing false loan information?',
    questionHa: 'Wane hukunci ne ke jiran wanda ya bada bayanan karya?',
    answer: 'Submission of false claims, fraudulent admission documents, or forged affidavits carries up to 3 years imprisonment or heavy statutory fines.',
    answerHa: 'Bada bayanan karya, takardun bogi ko rantsuwar karya zai iya kai mutum gidan yari na tsawon shekaru 3 ko tarar kudi mai yawa.',
    statutoryReference: 'Students Loans Act 2024, Section 14 & Penal Code',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024, Sashe na 14'
  }
];

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    timestamp: new Date().toISOString(),
    firebaseReady: Boolean(db && messaging),
  });
});

// --- FAQ Endpoints ---

// Get all FAQs
app.get('/api/faqs', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const snapshot = await db.collection('faqs').get();
    const faqs = [];
    snapshot.forEach((doc) => {
      faqs.push({ id: doc.id, ...doc.data() });
    });
    res.json({ success: true, count: faqs.length, data: faqs });
  } catch (error) {
    console.error('[API] Error fetching FAQs:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create FAQ
app.post('/api/faqs', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const {
      id,
      category,
      question,
      questionHa,
      answer,
      answerHa,
      statutoryReference,
      statutoryReferenceHa,
    } = req.body;

    if (!question || !answer) {
      return res.status(400).json({ error: 'Question and answer are required' });
    }

    const docId = id && id.trim().length > 0 ? id.trim() : `faq_${Date.now()}`;
    const payload = {
      id: docId,
      category: category || 'applying',
      question: question.trim(),
      questionHa: (questionHa || question).trim(),
      answer: answer.trim(),
      answerHa: (answerHa || answer).trim(),
      statutoryReference: (statutoryReference || 'Students Loans Act 2024').trim(),
      statutoryReferenceHa: (statutoryReferenceHa || statutoryReference || 'Dokar Lamunin Dalibai ta 2024').trim(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('faqs').doc(docId).set(payload, { merge: true });
    console.log(`[API] Saved FAQ: ${docId}`);
    res.json({ success: true, id: docId, data: payload });
  } catch (error) {
    console.error('[API] Error saving FAQ:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update FAQ
app.put('/api/faqs/:id', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const { id } = req.params;
    const body = req.body;
    body.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    await db.collection('faqs').doc(id).set(body, { merge: true });
    res.json({ success: true, id, message: 'FAQ updated successfully' });
  } catch (error) {
    console.error('[API] Error updating FAQ:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete FAQ
app.delete('/api/faqs/:id', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const { id } = req.params;
    await db.collection('faqs').doc(id).delete();
    console.log(`[API] Deleted FAQ: ${id}`);
    res.json({ success: true, message: `FAQ ${id} deleted successfully` });
  } catch (error) {
    console.error('[API] Error deleting FAQ:', error);
    res.status(500).json({ error: error.message });
  }
});

// Seed Statutory FAQs
app.post('/api/faqs/seed', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const batch = db.batch();
    for (const item of STATUTORY_FAQS) {
      const docRef = db.collection('faqs').doc(item.id);
      batch.set(docRef, {
        ...item,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    console.log(`[API] Seeded ${STATUTORY_FAQS.length} statutory FAQs into Firestore.`);
    res.json({
      success: true,
      message: `Seeded ${STATUTORY_FAQS.length} statutory FAQs successfully`,
      count: STATUTORY_FAQS.length,
    });
  } catch (error) {
    console.error('[API] Error seeding FAQs:', error);
    res.status(500).json({ error: error.message });
  }
});

// --- Notification Endpoints ---

// Get all notifications
app.get('/api/notifications', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const snapshot = await db.collection('notifications').orderBy('createdAt', 'desc').get();
    const notifications = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      notifications.push({
        id: doc.id,
        ...data,
        createdAt: data.createdAt && data.createdAt.toDate ? data.createdAt.toDate().toISOString() : data.createdAt,
      });
    });
    res.json({ success: true, count: notifications.length, data: notifications });
  } catch (error) {
    console.error('[API] Error fetching notifications:', error);
    res.status(500).json({ error: error.message });
  }
});

// Dispatch High-Priority Push Notification & Record in Firestore
app.post('/api/notifications/send', async (req, res) => {
  if (!db || !messaging) {
    return res.status(503).json({ error: 'Firebase is not connected' });
  }

  try {
    const {
      title,
      body,
      badge = 'Advisory',
      badgeColorHex = '#0D5C3A',
      topic = 'all',
      actionUrl = '',
    } = req.body;

    if (!title || !body) {
      return res.status(400).json({ error: 'Title and body are required' });
    }

    const docId = `notif_${Date.now()}`;
    const timestampFormatted = new Date().toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    });

    const notificationRecord = {
      id: docId,
      title: title.trim(),
      body: body.trim(),
      badge: badge.trim(),
      badgeColorHex: badgeColorHex.trim(),
      timestamp: timestampFormatted,
      actionUrl: actionUrl.trim(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // 1. Save to Firestore 'notifications' collection so app users see it in-app forever
    await db.collection('notifications').doc(docId).set(notificationRecord);

    // 2. Dispatch High-Importance Push to FCM topic
    // Configured specifically for heads-up display, sound, vibration on both Android & iOS
    const pushPayload = {
      topic: topic.trim() || 'all',
      notification: {
        title: title.trim(),
        body: body.trim(),
      },
      data: {
        id: docId,
        title: title.trim(),
        body: body.trim(),
        badge: badge.trim(),
        badgeColorHex: badgeColorHex.trim(),
        timestamp: timestampFormatted,
        actionUrl: actionUrl.trim(),
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'max',
          defaultSound: true,
          defaultVibrateTimings: true,
          visibility: 'public',
          notificationCount: 1,
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            alert: {
              title: title.trim(),
              body: body.trim(),
            },
          },
        },
      },
    };

    const fcmResponse = await messaging.send(pushPayload);
    console.log(`[API] Push notification dispatched successfully. FCM Message ID: ${fcmResponse}`);

    res.json({
      success: true,
      messageId: fcmResponse,
      docId,
      notification: notificationRecord,
    });
  } catch (error) {
    console.error('[API] Error sending push notification:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete Notification
app.delete('/api/notifications/:id', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const { id } = req.params;
    await db.collection('notifications').doc(id).delete();
    console.log(`[API] Deleted Notification: ${id}`);
    res.json({ success: true, message: `Notification ${id} deleted successfully` });
  } catch (error) {
    console.error('[API] Error deleting notification:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start Express Server
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🇳🇬 My NELFund Official Enterprise Admin Console`);
  console.log(`   Running locally on: http://localhost:${PORT}`);
  console.log(`   Status: Ready for Real-Time FAQ & Push Management`);
  console.log(`====================================================`);
});
