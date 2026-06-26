import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';

const BOT_URL = __ENV.BOT_URL || 'http://localhost:3000';

// Каждый VU получает свой user_id: VU 1 → 1001, VU 2 → 1002, ...
const USER_BASE_ID = 1000;
const N_VUS = 2;

const SPREADSHEETS = [
  { document_id: '13PVevQPgWe0HMt3DzV2ii5q4o1y2YQHHjen26PSVY-4', alias: 'тест-2' },
  { document_id: '1Pdq3bemOwovZLiFDWoNfb6XO0HJt9RHz8LpwZBjeXJs', alias: 'тест-1' },
];

const CATEGORIES = ['Продукты', 'Транспорт'];
const EXPENSES_PER_SHEET = 100;

const expenseErrors = new Counter('expense_errors');

// 2 VU — по одному на таблицу. Каждый делает ровно 100 итераций.
export const options = {
  scenarios: {
    add_expenses: {
      executor: 'per-vu-iterations',
      vus: N_VUS,
      iterations: EXPENSES_PER_SHEET,
      maxDuration: '10m',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<3000'],
    expense_errors: ['count==0'],
  },
};

// ── Helpers ────────────────────────────────────────────────────────────────────

function webhook(userId, msgId, text) {
  return JSON.stringify({
    message: {
      message_id: msgId,
      text: text,
      from: { id: userId, username: `load_user_${userId}`, is_bot: false },
      chat: { id: userId, type: 'private' },
      date: Math.floor(Date.now() / 1000),
    },
  });
}

function post(userId, msgId, text) {
  return http.post(
    `${BOT_URL}/telegram/webhook`,
    webhook(userId, msgId, text),
    { headers: { 'Content-Type': 'application/json' } }
  );
}

function randomDate() {
  const day = String(Math.floor(Math.random() * 28) + 1).padStart(2, '0');
  return `${day}.05.2026`;
}

function randomAmount() {
  return String(Math.floor(Math.random() * 4900) + 100);
}

function randomCategory() {
  return CATEGORIES[Math.floor(Math.random() * CATEGORIES.length)];
}

// ── Setup: каждый VU создаёт таблицу для своего пользователя ──────────────────
// Запускается один раз в default() при __ITER === 0

function setupUser(userId, sheet) {
  const base = userId * 100000;

  const addRes = post(
    userId, base,
    `/spreadsheets --add --document_id="${sheet.document_id}" --expense_range="Лист1!G29:J110" --rest_balance_cell="Лист1!M7"`
  );
  console.log(`[setup user=${userId}] --add (${addRes.status}): ${addRes.body}`);
  check(addRes, { [`[setup] add ${sheet.alias}`]: (r) => r.status === 200 });

  sleep(0.5);

  const aliasRes = post(
    userId, base + 1,
    `/spreadsheets --set_alias --document_id="${sheet.document_id}" --alias="${sheet.alias}"`
  );
  console.log(`[setup user=${userId}] --set_alias (${aliasRes.status}): ${aliasRes.body}`);
  check(aliasRes, { [`[setup] alias ${sheet.alias}`]: (r) => r.status === 200 });

  sleep(0.5);
}

// ── Основная нагрузка ──────────────────────────────────────────────────────────

export default function () {
  const userId = USER_BASE_ID + __VU;
  const sheet = SPREADSHEETS[(__VU - 1) % SPREADSHEETS.length];

  if (__ITER === 0) {
    setupUser(userId, sheet);
  }

  const msgId = userId * 10000 + __ITER;

  const res = post(
    userId,
    msgId,
    `/spreadsheets --add_expense` +
      ` --alias="${sheet.alias}"` +
      ` --date="${randomDate()}"` +
      ` --amount="${randomAmount()}"` +
      ` --category="${randomCategory()}"`
  );

  const ok = check(res, { 'add expense 200': (r) => r.status === 200 });
  if (!ok) {
    expenseErrors.add(1);
    console.error(`[error] user=${userId} iter=${__ITER} sheet=${sheet.alias} status=${res.status} body=${res.body}`);
  }

  sleep(1);
}
