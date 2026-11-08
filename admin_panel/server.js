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

// Default statutory FAQs dataset (Matches exact 19 in-app policies in faq_model.dart)
const STATUTORY_FAQS = [
  // --- Applying & Eligibility ---
  {
    id: 'app_1',
    category: 'applying',
    question: 'Who is eligible to apply for the NELFUND Student Loan?',
    questionHa: 'Su wane ne suka cancanci neman bashin karatun dalibai na NELFUND?',
    answer: 'Under Section 2.0 of the Guidelines, you must be a verified Nigerian citizen (with valid NIN and BVN) who has gained admission or is currently enrolled full-time in an approved Federal or State public tertiary institution (University, Polytechnic, or College of Education). There are no income restrictions or family income ceilings.',
    answerHa: 'Karkashin Sashe na 2.0 na Ka\'idojin, dole ne ka kasance dan Najeriya (mai ingantacciyar lambar NIN da BVN) wanda ya sami shiga ko yake karatu a halin yanzu a jami\'a, kwalejin foliteknik, ko kwalejin ilimi ta gwamnatin tarayya ko jiha. Babu wani sharadi kan iyakar kudin shigar iyaye ko dangi.',
    statutoryReference: 'Section 2.0 & Section 2.1',
    statutoryReferenceHa: 'Sashe na 2.0 & Sashe na 2.1'
  },
  {
    id: 'app_2',
    category: 'applying',
    question: 'Can private university students apply for NELFUND loans?',
    questionHa: 'Shin daliban jami\'o\'i masu zaman kansu za su iya neman bashin?',
    answer: 'No. Under Section 2.2 of the Students Loans Act 2024, only students attending approved Federal and State public tertiary institutions (ETIs) are eligible for funding. Private university students are currently excluded.',
    answerHa: 'A\'a. Karkashin Sashe na 2.2 na Dokar Lamunin Dalibai ta 2024, daliban da suke halartar manyan makarantun gwamnatin tarayya da na jihohi ne kadai suka cancanci samun lamuni a halin yanzu.',
    statutoryReference: 'Section 2.2 (Institutional Criteria)',
    statutoryReferenceHa: 'Sashe na 2.2 (Ka\'idojin Makarantu)'
  },
  {
    id: 'app_3',
    category: 'applying',
    question: 'What is the Student Verification System (SVS) upload requirement?',
    questionHa: 'Menene ma\'anar lodin bayanai a Tsarin Tabbatar da Dalibai (SVS)?',
    answer: 'Before an applicant can complete their loan application, their tertiary institution must upload their academic profile, matriculation/JAMB details, and fee structure directly into the NELFUND Student Verification System (SVS). If your school has not completed this upload, your profile cannot be cleared for evaluation.',
    answerHa: 'Kafin mai neman bashi ya iya kammala aikace-aikacensa, dole ne makarantarsa ta loda bayanan karatunsa, lambar shiga makaranta ko ta JAMB, da tsarin kudaden makaranta kai-tsaye a tsarin SVS na NELFUND. Idan makarantarku ba ta loda bayanan ba, ba za a iya tantance ku ba.',
    statutoryReference: 'Section 4.1 (Institutional Verification)',
    statutoryReferenceHa: 'Sashe na 4.1 (Tantancewar Makaranta)'
  },
  {
    id: 'app_4',
    category: 'applying',
    question: 'Are there any application or processing fees to apply?',
    questionHa: 'Shin akwai wani kudi na cika fom ko na aiki da ake biya?',
    answer: 'Absolutely not. Applying on the official portal (nelf.gov.ng) is 100% free of charge. NELFUND does not charge application fees, processing fees, or commission. Beware of fraudulent agents claiming to expedite applications for a fee.',
    answerHa: 'Sam babu ko kobo. Neman bashi a shafin gwamnati (nelf.gov.ng) kyauta ne 100%. NELFUND ba ta karbar kudin cika fom, kudin aiki, ko wani kason kudi. A kiyaye mutane ko wakilai masu neman kudi da sunan za su taimaka.',
    statutoryReference: 'Students Loans Act 2024',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024'
  },
  {
    id: 'app_5',
    category: 'applying',
    question: 'Can someone who already holds a first degree apply?',
    questionHa: 'Shin wanda ya riga ya kammala digiri na farko zai iya sake neman bashi?',
    answer: 'No. Under Section 4.1.3 of the Guidelines (Attestation Form), applicants must attest under oath that they do not already possess a first degree or equivalent qualification from any Nigerian or foreign tertiary institution.',
    answerHa: 'A\'a. Karkashin Sashe na 4.1.3 na Ka\'idoji (Takardar Rantsuwa), dole ne mai nema ya rantse cewa ba shi da digiri na farko ko makamancinsa daga kowace jami\'a a Najeriya ko kasashen waje.',
    statutoryReference: 'Section 4.1.3 (Attestation Form)',
    statutoryReferenceHa: 'Sashe na 4.1.3 (Takardar Rantsuwa)'
  },

  // --- Disbursement & Fees ---
  {
    id: 'disb_1',
    category: 'disbursement',
    question: 'How are the institutional fees (tuition) paid?',
    questionHa: 'Ta yaya ake biyan kudaden makaranta (Tuition)?',
    answer: 'Institutional fees are never paid in cash or deposited into the student’s personal bank account. 100% of approved tuition and charges are paid electronically and directly into the designated official bank account of your tertiary institution.',
    answerHa: 'Ba a taba biyan kudin makaranta a hannu ko a asusun dalibi na kashin kai. Ana tura 100% na kudin makarantar kai-tsaye ta hanyar na\'ura zuwa asusun bankin hukuma na makarantarku.',
    statutoryReference: 'Section 4.3 (Disbursement Process)',
    statutoryReferenceHa: 'Sashe na 4.3 (Hanyar Biyan Kudi)'
  },
  {
    id: 'disb_2',
    category: 'disbursement',
    question: 'How and when is the ₦20,000 monthly upkeep stipend paid?',
    questionHa: 'Ta yaya kuma yaushe ake biyan alawus na tallafin rayuwa na ₦20,000 na kowanne wata?',
    answer: 'The optional upkeep stipend of ₦20,000 per month is credited directly into the verified commercial bank account of the student on a monthly basis throughout the approved academic session.',
    answerHa: 'Ana tura tallafin alawus na ₦20,000 a kowanne wata kai-tsaye zuwa asusun bankin dalibi na kashin kai wanda aka tantance a duk tsawon zangon karatun da aka amince da shi.',
    statutoryReference: 'Section 4.3 (Upkeep Stipend)',
    statutoryReferenceHa: 'Sashe na 4.3 (Alawus na Wata)'
  },
  {
    id: 'disb_3',
    category: 'disbursement',
    question: 'What happens if I already paid my school fees before the loan was approved?',
    questionHa: 'Menene zai faru idan na riga na biya kudin makaranta da kaina kafin bashi ya fito?',
    answer: 'Under Section 4.1.2 of the Guidelines (Student Refund Policy), if a student pays their institutional charges before NELFUND disburses the approved loan, the tertiary institution is legally mandated to refund the student within 30 calendar days upon receipt of funds from NELFUND.',
    answerHa: 'Karkashin Sashe na 4.1.2 na Ka\'idojin (Tsarin Mayar wa Dalibi Kudinsa), idan dalibi ya biya kudin makarantarsa kafin NELFUND ta tura kudin, doka ta tilasta wa makarantar mayar wa dalibin kudinsa cikin kwanaki 30 da samun kudin daga NELFUND.',
    statutoryReference: 'Section 4.1.2 (Student Refund Policy)',
    statutoryReferenceHa: 'Sashe na 4.1.2 (Mayar wa Dalibi Kudi)'
  },
  {
    id: 'disb_4',
    category: 'disbursement',
    question: 'What are the official turnaround times for evaluation and disbursement?',
    questionHa: 'Menene tsawon wa\'adin tantancewa da fitar da kudi na hukuma?',
    answer: 'The official Service Level Agreements (SLAs) are: (1) Institution verification: up to 20 working days; (2) NELFUND evaluation: 15 calendar days; (3) Approval: up to 10 working days; (4) Fund disbursement: up to 10 working days.',
    answerHa: 'Wa\'adin aiki na hukuma (SLAs) shi ne: (1) Tantancewar makaranta: har zuwa kwanakin aiki 20; (2) Tantancewar NELFUND: kwanaki 15 a kalanda; (3) Amincewa: kwanakin aiki 10; (4) Fitar da kudi: kwanakin aiki 10.',
    statutoryReference: 'Section 4.2 & Section 4.3',
    statutoryReferenceHa: 'Sashe na 4.2 & Sashe na 4.3'
  },

  // --- Repayment & Moratorium ---
  {
    id: 'rep_1',
    category: 'repayment',
    question: 'When does mandatory loan repayment begin?',
    questionHa: 'Yaushe ne dole a fara biyan kudin bashi?',
    answer: 'Under Section 5.1 of the 2024 Act, loan repayment does not begin until exactly two (2) years after the beneficiary completes their National Youth Service Corps (NYSC) service year (or obtains a formal letter of exemption). Zero deductions occur while you are studying or during your service year.',
    answerHa: 'Karkashin Sashe na 5.1 na Dokar 2024, ba za a fara biyan bashi ba sai bayan cikar shekaru biyu (2) cif da kammala hidimar kasa ta NYSC (ko samun takardar yaye ta doka). Ba a rage ko kobo a lokacin da kake karatu ko a lokacin NYSC.',
    statutoryReference: 'Section 5.1 (Commencement of Repayment)',
    statutoryReferenceHa: 'Sashe na 5.1 (Lokacin Fara Biyan Bashi)'
  },
  {
    id: 'rep_2',
    category: 'repayment',
    question: 'Is there any interest charged on the NELFUND loan?',
    questionHa: 'Shin akwai wani kudin ruwa a kan bashin NELFUND?',
    answer: 'No. The loan is strictly 0% interest-free under the Students Loans Act 2024. Beneficiaries only repay the exact principal amount disbursed on their behalf. There are no compounding charges, processing fees, or hidden penalties.',
    answerHa: 'A\'a. Bashin bashi ne mara kudin ruwa ko kobo (0% interest) karkashin Dokar 2024. Ainihin kudin da aka biya ma makaranta ko aka ba ka shi kadai za ka biya. Babu kudin karuwa, caji boyayye, ko tara.',
    statutoryReference: 'Students Loans Act 2024 (Section 5.0)',
    statutoryReferenceHa: 'Dokar Lamunin Dalibai ta 2024 (Sashe na 5.0)'
  },
  {
    id: 'rep_3',
    category: 'repayment',
    question: 'How is the monthly deduction calculated for employed beneficiaries?',
    questionHa: 'Ta yaya ake lissafin rage kudin wata ga masu aikin albashi?',
    answer: 'Repayment is executed through Pay-As-You-Earn (PAYE). Your employer is legally mandated to deduct 10% of your gross monthly salary at source and remit it directly to the NELFUND recovery account.',
    answerHa: 'Ana aiwatar da biyan bashi ta hanyar tsarin PAYE. Doka ta tilasta wa ma\'aikatarka cire kashi 10% na babban albashinka na wata kai-tsaye a tushe tare da tura shi asusun NELFUND.',
    statutoryReference: 'Section 5.1(a) (Employer Obligations)',
    statutoryReferenceHa: 'Sashe na 5.1(a) (Nauyin Ma\'aikata)'
  },
  {
    id: 'rep_4',
    category: 'repayment',
    question: 'How does repayment work for self-employed beneficiaries?',
    questionHa: 'Ta yaya biyan bashi yake aiki ga masu sana\'ar dogaro da kai?',
    answer: 'Under Section 5.2, self-employed beneficiaries must remit 10% of their monthly business profit to NELFUND. Within 60 days of starting enterprise, you must register your business details, bank accounts, and monthly profit statements with NELFUND.',
    answerHa: 'Karkashin Sashe na 5.2, masu sana\'ar dogaro da kai za su rinka tura kashi 10% na ribar kasuwancinsu a wata zuwa NELFUND. Cikin kwanaki 60 da fara sana\'a, dole ne ka yi rajistar bayanan sana\'arka da asusun banki da NELFUND.',
    statutoryReference: 'Section 5.2 (Self-Employed Beneficiaries)',
    statutoryReferenceHa: 'Sashe na 5.2 (Masu Dogaro da Kai)'
  },
  {
    id: 'rep_5',
    category: 'repayment',
    question: 'What happens if I am still unemployed 2 years after NYSC?',
    questionHa: 'Menene zai faru idan har yanzu ban sami aikin yi ba bayan shekaru 2 da NYSC?',
    answer: 'Under Section 5.1(c), if you remain unemployed after the 2-year post-NYSC grace period, you must submit a sworn affidavit of unemployment and periodic statutory declarations to NELFUND. Repayment is suspended without interest or penalties until you secure employment.',
    answerHa: 'Karkashin Sashe na 5.1(c), idan ba ka sami aiki ba bayan wa\'adin shekaru 2 na sassauci, za ka gabatar da takardar rantsuwa ta rashin aikin yi ga NELFUND. Za a dakatar da biyan bashi ba tare da tara ko kudin ruwa ba har sai ka sami aiki.',
    statutoryReference: 'Section 5.1(c) (Unemployment Declaration)',
    statutoryReferenceHa: 'Sashe na 5.1(c) (Sanarwar Rashin Aikin Yi)'
  },
  {
    id: 'rep_6',
    category: 'repayment',
    question: 'What are my reporting duties when I get a job or change employers?',
    questionHa: 'Wane nauyi ya rataya a wuyana idan na sami aiki ko na canza ma\'aikata?',
    answer: 'Under Section 5.1(b), within 30 days of securing employment, you must submit your employer’s name, address, monthly salary, and loan ID to NELFUND. If you switch jobs, you must report the change to NELFUND within 30 days.',
    answerHa: 'Karkashin Sashe na 5.1(b), cikin kwanaki 30 da samun aiki, dole ne ka aike wa NELFUND sunan ma\'aikatarka, adireshinta, albashinka, da lambar bashinka. Idan ka canza aiki ma, dole ne ka sanar cikin kwanaki 30.',
    statutoryReference: 'Section 5.1(b) (Beneficiary Obligations)',
    statutoryReferenceHa: 'Sashe na 5.1(b) (Nauyin Mai Bashi)'
  },

  // --- Default & Legal Recovery ---
  {
    id: 'def_1',
    category: 'defaultRecovery',
    question: 'What is the Global Standing Instruction (GSI) mandate?',
    questionHa: 'Menene ma\'anar umarnin banki na GSI (Global Standing Instruction)?',
    answer: 'The Global Standing Instruction (GSI) is a Central Bank of Nigeria (CBN) financial recovery instrument. Under Section 5.3, willful defaulters will have their outstanding loan amount automatically swept and debited from any and all commercial bank accounts linked to their BVN and NIN nationwide.',
    answerHa: 'Umarnin GSI wata ka\'ida ce ta Babban Bankin Najeriya (CBN). Karkashin Sashe na 5.3, duk wanda ya ki biyan bashi da gangan, za a rinka kwasar kudin bashinsa kai-tsaye daga duk wani asusun bankin kasuwanci da yake da shi da yake hade da BVN ko NIN dinsa a fadin kasar nan.',
    statutoryReference: 'Section 5.3(d) (GSI Auto-Debit)',
    statutoryReferenceHa: 'Sashe na 5.3(d) (Kwasar Kudi ta GSI)'
  },
  {
    id: 'def_2',
    category: 'defaultRecovery',
    question: 'Will defaulting affect my ability to get bank loans or credit cards?',
    questionHa: 'Shin kin biyan bashi zai iya hana ni samun lamunin banki a gaba?',
    answer: 'Yes. Under Section 5.3(b), defaulters are formally reported to the Central Bank’s Credit Risk Management System (CRMS) and private Credit Bureaus. This blacklists you from securing bank loans, car financing, mortgages, or credit cards across all Nigerian financial institutions.',
    answerHa: 'Kwarai kuwa. Karkashin Sashe na 5.3(b), za a kai sunan duk wanda ya ki biya zuwa Tsarin CRMS na Babban Bankin Najeriya da hukumomin binciken bashi. Wannan zai sa a toshe ka daga samun lamunin banki, katin bashi, ko jingina a duk bankunan Najeriya.',
    statutoryReference: 'Section 5.3(b) (CRMS Blacklisting)',
    statutoryReferenceHa: 'Sashe na 5.3(b) (Toshewa a Tsarin CRMS)'
  },
  {
    id: 'def_3',
    category: 'defaultRecovery',
    question: 'Can NELFUND publish the names of defaulters publicly?',
    questionHa: 'Shin NELFUND za ta iya buga sunayen wadanda suka ki biya a jaridu?',
    answer: 'Yes. Section 5.3(c) explicitly empowers NELFUND to publish the names, photographs, institution attended, and outstanding debt balances of chronic loan defaulters in national daily newspapers and public gazettes.',
    answerHa: 'E. Sashe na 5.3(c) ya ba NELFUND cikakken ikon buga sunaye, hotuna, makarantun da suka halarta, da adadin bashin da ake bin duk wadanda suka ki biya a jaridun kasar nan da mujallun gwamnati.',
    statutoryReference: 'Section 5.3(c) (Publication of Defaulters)',
    statutoryReferenceHa: 'Sashe na 5.3(c) (Buga Sunayen Masu Bashi)'
  },
  {
    id: 'def_4',
    category: 'defaultRecovery',
    question: 'Can legal prosecution or court action be taken against defaulters?',
    questionHa: 'Shin za a iya kai mutum kotu idan ya ki biyan bashi?',
    answer: 'Yes. Where warning notices, credit blacklisting, and GSI sweeps fail to recover the debt, NELFUND will institute legal action in the Federal High Court to recover the outstanding balance plus statutory legal recovery costs.',
    answerHa: 'E. Idan duk matakan jan kunne, toshewa a banki, da kwasar kudi ta GSI suka gaza, NELFUND za ta shigar da karar mai bashi a Babbar Kotun Tarayya domin karbar kudaden tare da kudaden shari\'a.',
    statutoryReference: 'Section 5.3(e) (Legal Prosecution)',
    statutoryReferenceHa: 'Sashe na 5.3(e) (Shari\'a a Kotu)'
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

// Helper to build FCM push message payload with max heads-up priority
function buildPushMessage(topic, title, body, docId, timestampFormatted, badge, badgeColorHex, actionUrl) {
  return {
    topic: topic || 'all',
    notification: {
      title,
      body,
    },
    data: {
      id: docId,
      title,
      body,
      badge: badge || 'Advisory',
      badgeColorHex: badgeColorHex || '#0D5C3A',
      timestamp: timestampFormatted || 'Today',
      actionUrl: actionUrl || '',
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
            title,
            body,
          },
        },
      },
    },
  };
}

// Helper to dispatch targeted push notifications on FAQ create or update
async function dispatchFaqPushNotification(isNew, questionText, questionTextHa) {
  if (!messaging || !db) return;
  try {
    const docId = `notif_${Date.now()}`;
    const timestampFormatted = new Date().toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    });

    // Pure English copy
    const titleEn = isNew ? '📢 New FAQ Available' : '📢 FAQ Policy Updated';
    const previewEn = (questionText || '').trim();
    const bodyEn = previewEn.length > 80 ? previewEn.substring(0, 77) + '...' : (previewEn || 'Official FAQ knowledge base has been updated.');

    // Pure Hausa copy
    const titleHa = isNew ? '📢 Sabuwar Tambaya Ta Samu' : '📢 An Sabunta Tambaya';
    const previewHa = (questionTextHa || questionText || '').trim();
    const bodyHa = previewHa.length > 80 ? previewHa.substring(0, 77) + '...' : (previewHa || 'An sabunta rumbun tambayoyin hukumar NELFUND.');

    // 1. Save single bilingual record in Firestore 'notifications' collection
    const notifRecord = {
      id: docId,
      title: titleEn,
      titleHa: titleHa,
      body: bodyEn,
      bodyHa: bodyHa,
      badge: isNew ? 'New Policy' : 'Updated',
      badgeColorHex: '#0D5C3A',
      timestamp: timestampFormatted,
      actionUrl: '',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection('notifications').doc(docId).set(notifRecord);

    // 2. Dispatch pure English push notification to English topic subscribers
    const payloadEn = buildPushMessage('lang_en', titleEn, bodyEn, docId, timestampFormatted, 'New Policy', '#0D5C3A', '');
    const resEn = await messaging.send(payloadEn);
    console.log(`[API] English FAQ Push dispatched to 'lang_en'. FCM ID: ${resEn}`);

    // 3. Dispatch pure Hausa push notification to Hausa topic subscribers
    const payloadHa = buildPushMessage('lang_ha', titleHa, bodyHa, docId, timestampFormatted, 'Sabuntawa', '#0D5C3A', '');
    const resHa = await messaging.send(payloadHa);
    console.log(`[API] Hausa FAQ Push dispatched to 'lang_ha'. FCM ID: ${resHa}`);
  } catch (err) {
    console.error('[API] Error dispatching targeted FAQ push notifications:', err.message);
  }
}

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

    // Automatically send targeted push notifications by language
    dispatchFaqPushNotification(true, payload.question, payload.questionHa);

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
    console.log(`[API] Updated FAQ: ${id}`);

    // Automatically send targeted push notifications by language
    dispatchFaqPushNotification(
      false,
      body.question || 'Updated statutory FAQ policy',
      body.questionHa || body.question || 'An sabunta ka\'idar dokar lamuni',
    );

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

// Seed Statutory 19 In-App FAQs
app.post('/api/faqs/seed', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const validIds = new Set(STATUTORY_FAQS.map((f) => f.id));
    const existingSnap = await db.collection('faqs').get();

    // Purge obsolete/legacy documents not in the active 19 set
    const deleteBatch = db.batch();
    let deletedCount = 0;
    existingSnap.forEach((doc) => {
      if (!validIds.has(doc.id)) {
        deleteBatch.delete(doc.ref);
        deletedCount++;
      }
    });
    if (deletedCount > 0) {
      await deleteBatch.commit();
      console.log(`[API] Purged ${deletedCount} legacy FAQ documents.`);
    }

    // Upsert all 19 official items
    const batch = db.batch();
    for (const item of STATUTORY_FAQS) {
      const docRef = db.collection('faqs').doc(item.id);
      batch.set(docRef, {
        ...item,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    console.log(`[API] Seeded all ${STATUTORY_FAQS.length} official in-app FAQs into Firestore.`);

    res.json({
      success: true,
      message: `Seeded ${STATUTORY_FAQS.length} statutory in-app FAQs successfully (purged ${deletedCount} legacy)`,
      count: STATUTORY_FAQS.length,
      purged: deletedCount,
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
      titleHa,
      body,
      bodyHa,
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
      titleHa: (titleHa || title).trim(),
      body: body.trim(),
      bodyHa: (bodyHa || body).trim(),
      badge: badge.trim(),
      badgeColorHex: badgeColorHex.trim(),
      timestamp: timestampFormatted,
      actionUrl: actionUrl.trim(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // 1. Save to Firestore 'notifications' collection so app users see it in-app
    await db.collection('notifications').doc(docId).set(notificationRecord);

    let fcmResponse = '';

    // 2. Dispatch targeted or broadcast push
    if (topic === 'all' && titleHa && bodyHa && (titleHa !== title || bodyHa !== body)) {
      // Dispatches targeted push notifications per language
      const msgEn = buildPushMessage('lang_en', title.trim(), body.trim(), docId, timestampFormatted, badge, badgeColorHex, actionUrl);
      const msgHa = buildPushMessage('lang_ha', titleHa.trim(), bodyHa.trim(), docId, timestampFormatted, badge, badgeColorHex, actionUrl);
      const [rEn, rHa] = await Promise.all([messaging.send(msgEn), messaging.send(msgHa)]);
      fcmResponse = `En: ${rEn}, Ha: ${rHa}`;
      console.log(`[API] Targeted push notifications dispatched. ${fcmResponse}`);
    } else {
      const msg = buildPushMessage(topic.trim() || 'all', title.trim(), body.trim(), docId, timestampFormatted, badge, badgeColorHex, actionUrl);
      fcmResponse = await messaging.send(msg);
      console.log(`[API] Push notification dispatched to topic "${topic}". FCM Message ID: ${fcmResponse}`);
    }

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

// Device stats and language breakdown endpoint
app.get('/api/user-stats', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const snap = await db.collection('user_preferences').get();
    let totalDevices = 0;
    let englishCount = 0;
    let hausaCount = 0;

    snap.forEach((doc) => {
      totalDevices++;
      const data = doc.data();
      if (data.language === 'ha') {
        hausaCount++;
      } else {
        englishCount++;
      }
    });

    res.json({
      success: true,
      totalDevices,
      englishCount,
      hausaCount,
    });
  } catch (err) {
    console.error('[API] Error getting user stats:', err);
    res.status(500).json({ error: err.message });
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

// --- Sauki Go Promo Configuration Endpoints ---

const DEFAULT_SAUKI_PROMO = {
  enabled: true,
  modalEnabled: true,
  cooldownDays: 7,
  appName: 'Sauki Go',
  headlineEn: 'Get affordable data and airtime from our trusted app',
  headlineHa: 'Samu data da katin waya mai sauƙi daga amintacciyar manhajarmu',
  subtitleEn: 'Stay connected for lectures, research & NELFUND portal updates.',
  subtitleHa: 'Kasance cikin haɗin yanar gizo don karatu da sabuntawar shafin NELFUND.',
  plan1Data: '1GB',
  plan1Price: '₦400',
  plan2Data: '5GB',
  plan2Price: '₦1,500',
  cycleEn: 'All Monthly',
  cycleHa: 'Duka na Wata-Wata',
  appStoreUrl: 'https://apps.apple.com/app/id6815456102',
  playStoreUrl: 'https://play.google.com/store/apps/details?id=com.saukimart.go',
};

// Get current Sauki Go promo config
app.get('/api/promo', async (req, res) => {
  if (!db) {
    return res.json({ success: true, data: DEFAULT_SAUKI_PROMO, source: 'default_offline' });
  }

  try {
    const doc = await db.collection('app_config').doc('sauki_promo').get();
    if (!doc.exists) {
      return res.json({ success: true, data: DEFAULT_SAUKI_PROMO, source: 'default' });
    }
    const data = doc.data() || {};
    res.json({
      success: true,
      source: 'firestore',
      data: {
        ...DEFAULT_SAUKI_PROMO,
        ...data,
        updatedAt: data.updatedAt && data.updatedAt.toDate
          ? data.updatedAt.toDate().toISOString()
          : data.updatedAt,
      },
    });
  } catch (error) {
    console.error('[API] Error fetching Sauki Go promo config:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update Sauki Go promo config
app.put('/api/promo', async (req, res) => {
  if (!db) {
    return res.status(503).json({ error: 'Firestore is not connected' });
  }

  try {
    const body = req.body || {};
    const parsedCooldown = parseInt(body.cooldownDays, 10);
    const payload = {
      enabled: body.enabled !== undefined ? Boolean(body.enabled) : DEFAULT_SAUKI_PROMO.enabled,
      modalEnabled: body.modalEnabled !== undefined ? Boolean(body.modalEnabled) : DEFAULT_SAUKI_PROMO.modalEnabled,
      cooldownDays: Number.isFinite(parsedCooldown) && parsedCooldown >= 0
        ? parsedCooldown
        : DEFAULT_SAUKI_PROMO.cooldownDays,
      appName: (body.appName || DEFAULT_SAUKI_PROMO.appName).toString().trim(),
      headlineEn: (body.headlineEn || DEFAULT_SAUKI_PROMO.headlineEn).toString().trim(),
      headlineHa: (body.headlineHa || DEFAULT_SAUKI_PROMO.headlineHa).toString().trim(),
      subtitleEn: (body.subtitleEn || DEFAULT_SAUKI_PROMO.subtitleEn).toString().trim(),
      subtitleHa: (body.subtitleHa || DEFAULT_SAUKI_PROMO.subtitleHa).toString().trim(),
      plan1Data: (body.plan1Data || DEFAULT_SAUKI_PROMO.plan1Data).toString().trim(),
      plan1Price: (body.plan1Price || DEFAULT_SAUKI_PROMO.plan1Price).toString().trim(),
      plan2Data: (body.plan2Data || DEFAULT_SAUKI_PROMO.plan2Data).toString().trim(),
      plan2Price: (body.plan2Price || DEFAULT_SAUKI_PROMO.plan2Price).toString().trim(),
      cycleEn: (body.cycleEn || DEFAULT_SAUKI_PROMO.cycleEn).toString().trim(),
      cycleHa: (body.cycleHa || DEFAULT_SAUKI_PROMO.cycleHa).toString().trim(),
      appStoreUrl: (body.appStoreUrl || DEFAULT_SAUKI_PROMO.appStoreUrl).toString().trim(),
      playStoreUrl: (body.playStoreUrl || DEFAULT_SAUKI_PROMO.playStoreUrl).toString().trim(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('app_config').doc('sauki_promo').set(payload, { merge: true });
    console.log('[API] Updated Sauki Go promo config in app_config/sauki_promo');
    res.json({ success: true, data: payload, message: 'Sauki Go promo configuration saved to Firestore' });
  } catch (error) {
    console.error('[API] Error updating Sauki Go promo config:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start Express Server
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🇳🇬 My NELFund Official Enterprise Admin Console`);
  console.log(`   Running locally on: http://localhost:${PORT}`);
  console.log(`   Status: Ready for Real-Time FAQ, Push & Promo Management`);
  console.log(`====================================================`);
});
