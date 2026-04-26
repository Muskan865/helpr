const express = require('express');
const cors = require('cors');

const workerRoutes = require('./routes/workerRoutes');
const chatRoutes = require('./routes/chatRoutes');
const requesterRoutes = require('./routes/requesterRoutes');

const app = express();

// logger first
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url} - Origin: ${req.headers.origin}`);
  next();
});

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

app.use('/api/worker', workerRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/requester', requesterRoutes);

module.exports = app;