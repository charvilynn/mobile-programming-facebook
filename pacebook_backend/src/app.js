const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const postRoutes = require('./routes/post.routes');
const connectionRoutes = require('./routes/connection.routes');
const chatRoutes = require('./routes/chat.routes');
const notificationRoutes = require('./routes/notification.routes');
const communityRoutes = require('./routes/community.routes');
const eventRoutes = require('./routes/event.routes');
const marketRoutes = require('./routes/market.routes');
const storyRoutes = require('./routes/story.routes');

const { errorHandler } = require('./middleware/error.middleware');

const app = express();

// Middleware
app.use(helmet());

// Allow all localhost origins for Flutter web dev (port varies each run).
// In production, restrict to your actual domain.
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') ?? [];
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl, Postman)
    if (!origin) return callback(null, true);
    // Allow any localhost port for Flutter web dev
    if (/^http:\/\/localhost(:\d+)?$/.test(origin)) return callback(null, true);
    if (allowedOrigins.includes(origin)) return callback(null, true);
    callback(new Error(`CORS: origin ${origin} not allowed`));
  },
  credentials: true,
}));

app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Routes
const API = '/api/v1';
app.use(`${API}/auth`,          authRoutes);
app.use(`${API}/users`,         userRoutes);
app.use(`${API}/posts`,         postRoutes);
app.use(`${API}/stories`,       storyRoutes);
app.use(`${API}/connections`,   connectionRoutes);
app.use(`${API}/chat`,          chatRoutes);
app.use(`${API}/notifications`, notificationRoutes);
app.use(`${API}/communities`,   communityRoutes);
app.use(`${API}/events`,        eventRoutes);
app.use(`${API}/marketplace`,   marketRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint tidak ditemukan' });
});

// Error Handler
app.use(errorHandler);

module.exports = app;
