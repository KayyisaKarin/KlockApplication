import 'dotenv/config';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import express, { type NextFunction, type Request, type Response } from 'express';

const PORT = 3000;
const DIST_DIR = path.resolve(process.cwd(), 'dist');
const DATA_DIR = path.resolve(process.cwd(), '.data');
const STORE_PATH = path.join(DATA_DIR, 'store.json');

interface StudentUser {
  uid: string;
  email: string;
  displayName: string;
}

interface AttendanceRecord {
  id: string;
  createdAt: string | null;
  status?: 'onTime' | 'late' | 'absent' | 'excused';
  note?: string;
}

interface StoreState {
  attendanceByUid: Record<string, AttendanceRecord[]>;
  photosByKey: Record<string, string>;
  profilePhotoByUid: Record<string, string>;
}

interface SessionEntry {
  user: StudentUser;
  expiresAt: number;
}

const sessions = new Map<string, SessionEntry>();

function loadStore(): StoreState {
  try {
    if (fs.existsSync(STORE_PATH)) {
      const raw = JSON.parse(fs.readFileSync(STORE_PATH, 'utf8')) as Partial<StoreState>;
      return {
        attendanceByUid: raw.attendanceByUid ?? {},
        photosByKey: raw.photosByKey ?? {},
        profilePhotoByUid: raw.profilePhotoByUid ?? {},
      };
    }
  } catch {
    // Fall back to empty store
  }
  return {
    attendanceByUid: {},
    photosByKey: {},
    profilePhotoByUid: {},
  };
}

function saveStore(state: StoreState): void {
  fs.mkdirSync(DATA_DIR, { recursive: true });
  fs.writeFileSync(STORE_PATH, JSON.stringify(state, null, 2), 'utf8');
}

function wibDayKey(isoOrDate: string | Date): string {
  const ms = (typeof isoOrDate === 'string' ? new Date(isoOrDate) : isoOrDate).getTime();
  const wib = new Date(ms + 7 * 60 * 60 * 1000);
  return `${wib.getUTCFullYear()}-${wib.getUTCMonth() + 1}-${wib.getUTCDate()}`;
}

function extractBearer(req: Request): string | null {
  const header = req.header('authorization') ?? '';
  if (!header.toLowerCase().startsWith('bearer ')) return null;
  return header.slice(7).trim() || null;
}

interface AuthenticatedRequest extends Request {
  student?: StudentUser;
  token?: string;
}

function requireAuth(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
  const token = extractBearer(req);
  if (!token) {
    res.status(401).json({ error: 'Authentication required.' });
    return;
  }
  const session = sessions.get(token);
  if (!session || session.expiresAt < Date.now()) {
    if (session) sessions.delete(token);
    res.status(401).json({ error: 'Session expired. Please log in again.' });
    return;
  }
  req.student = session.user;
  req.token = token;
  next();
}

function dataUrlByteSize(dataUrl: string): number {
  const comma = dataUrl.indexOf(',');
  if (comma < 0) return 0;
  const b64 = dataUrl.slice(comma + 1);
  const pad = b64.endsWith('==') ? 2 : b64.endsWith('=') ? 1 : 0;
  return Math.floor((b64.length * 3) / 4) - pad;
}

const app = express();
app.use(express.json({ limit: '512kb' }));

app.post('/api/auth/login', async (req: Request, res: Response) => {
  const email = typeof req.body?.email === 'string' ? req.body.email.trim() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';

  if (!email || !password) {
    res.status(400).json({ error: 'Please enter both email and password.' });
    return;
  }

  const firebaseApiKey = process.env.FIREBASE_WEB_API_KEY?.trim();
  if (!firebaseApiKey) {
    res.status(401).json({
      error: 'Firebase Auth is not configured for the web preview (set FIREBASE_WEB_API_KEY).',
    });
    return;
  }

  try {
    const authRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${encodeURIComponent(firebaseApiKey)}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, returnSecureToken: true }),
      },
    );
    const payload = (await authRes.json()) as {
      localId?: string;
      email?: string;
      displayName?: string;
    };
    if (!authRes.ok || !payload.localId) {
      res.status(401).json({ error: 'Login failed. Check your credentials and try again.' });
      return;
    }

    const user: StudentUser = {
      uid: payload.localId,
      email: payload.email ?? email,
      displayName: payload.displayName || (payload.email ?? email).split('@')[0] || 'Student',
    };
    const token = crypto.randomBytes(32).toString('hex');
    sessions.set(token, { user, expiresAt: Date.now() + 24 * 60 * 60 * 1000 });
    res.json({ token, user });
  } catch {
    res.status(502).json({ error: 'Unable to reach authentication service.' });
  }
});

app.get('/api/auth/me', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  res.json({ user: req.student });
});

app.post('/api/auth/logout', (req: Request, res: Response) => {
  const token = extractBearer(req);
  if (token) sessions.delete(token);
  res.json({ ok: true });
});

app.get('/api/attendance', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  const store = loadStore();
  const records = store.attendanceByUid[req.student!.uid] ?? [];
  res.json({ records });
});

app.post('/api/attendance', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  const photoDataUrl = typeof req.body?.photoDataUrl === 'string' ? req.body.photoDataUrl : '';
  if (!photoDataUrl.startsWith('data:image/') || dataUrlByteSize(photoDataUrl) > 102400) {
    res.status(400).json({ error: 'Photo must be 100 KB or less.' });
    return;
  }

  const uid = req.student!.uid;
  const store = loadStore();
  const existing = store.attendanceByUid[uid] ?? [];
  const todayKey = wibDayKey(new Date());
  if (existing.some((r) => r.createdAt && wibDayKey(r.createdAt) === todayKey)) {
    res.status(409).json({ error: 'You have already logged attendance today.' });
    return;
  }

  const record: AttendanceRecord = {
    id: crypto.randomUUID(),
    createdAt: new Date().toISOString(),
  };
  store.attendanceByUid[uid] = [record, ...existing];
  store.photosByKey[`${uid}:${record.id}`] = photoDataUrl;
  saveStore(store);
  res.status(201).json({ record });
});

app.post('/api/attendance/excuse', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  const reason = typeof req.body?.reason === 'string' ? req.body.reason.trim() : '';
  const note = typeof req.body?.note === 'string' ? req.body.note.trim().slice(0, 120) : '';
  if (!reason) {
    res.status(400).json({ error: 'Please select an excuse reason.' });
    return;
  }

  const uid = req.student!.uid;
  const store = loadStore();
  const existing = store.attendanceByUid[uid] ?? [];
  const todayKey = wibDayKey(new Date());
  if (existing.some((r) => r.createdAt && wibDayKey(r.createdAt) === todayKey)) {
    res.status(409).json({ error: 'Attendance already logged for today.' });
    return;
  }

  const record: AttendanceRecord = {
    id: crypto.randomUUID(),
    createdAt: new Date().toISOString(),
    status: 'excused',
    note: note ? `${reason} — ${note}` : reason,
  };
  store.attendanceByUid[uid] = [record, ...existing];
  saveStore(store);
  res.status(201).json({ record });
});

app.get('/api/attendance/:id/photo', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  const uid = req.student!.uid;
  const store = loadStore();
  const photoDataUrl = store.photosByKey[`${uid}:${req.params.id}`];
  if (!photoDataUrl) {
    res.status(404).json({ error: 'Photo proof not found.' });
    return;
  }
  res.json({ photoDataUrl });
});

app.get('/api/profile/photo', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  const store = loadStore();
  res.json({ photoDataUrl: store.profilePhotoByUid[req.student!.uid] ?? null });
});

app.put('/api/profile/photo', requireAuth, (req: AuthenticatedRequest, res: Response) => {
  const photoDataUrl = typeof req.body?.photoDataUrl === 'string' ? req.body.photoDataUrl : '';
  if (!photoDataUrl.startsWith('data:image/') || dataUrlByteSize(photoDataUrl) > 102400) {
    res.status(400).json({ error: 'Profile photo must be 100 KB or less.' });
    return;
  }
  const store = loadStore();
  store.profilePhotoByUid[req.student!.uid] = photoDataUrl;
  saveStore(store);
  res.json({ photoDataUrl });
});

app.use(express.static(DIST_DIR));
app.get('*', (_req: Request, res: Response) => {
  res.sendFile(path.join(DIST_DIR, 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Punchd'in App server listening on http://localhost:${PORT}`);
});
