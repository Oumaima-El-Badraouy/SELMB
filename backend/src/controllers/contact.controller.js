import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_FILE = path.join(__dirname, '../../data/contact-messages.json');

/** POST /contact — public, append message to JSON array file */
export async function submitContact(req, res) {
  try {
    const body = req.body || {};
    const name = String(body.name || '').trim();
    const email = String(body.email || '').trim();
    const message = String(body.message || body.msg || '').trim();

    if (name.length < 2) {
      return res.status(400).json({ error: 'الاسم مطلوب (حرفان على الأقل)' });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ error: 'البريد الإلكتروني غير صالح' });
    }
    if (message.length < 5) {
      return res.status(400).json({ error: 'الرسالة قصيرة جداً' });
    }
    if (message.length > 8000) {
      return res.status(400).json({ error: 'الرسالة طويلة جداً' });
    }

    await fs.mkdir(path.dirname(DATA_FILE), { recursive: true });

    let list = [];
    try {
      const raw = await fs.readFile(DATA_FILE, 'utf8');
      const parsed = JSON.parse(raw);
      list = Array.isArray(parsed) ? parsed : [];
    } catch {
      list = [];
    }

    const entry = {
      id: `c_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`,
      name,
      email,
      message,
      createdAt: new Date().toISOString(),
    };
    list.push(entry);
    await fs.writeFile(DATA_FILE, JSON.stringify(list, null, 2), 'utf8');

    return res.status(201).json({ ok: true, id: entry.id });
  } catch (err) {
    console.error('[contact]', err);
    return res.status(500).json({ error: 'تعذر حفظ الرسالة' });
  }
}
