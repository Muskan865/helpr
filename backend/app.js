const express = require('express');
const cors = require('cors');

const workerRoutes = require('./routes/workerRoutes');
const profileRoutes = require('./routes/profileRoutes');
const profileCompletionRoutes = require('./routes/profileCompletionRoutes');
const chatRoutes = require("./routes/chatRoutes");

const app = express();

// Middleware must come before routes
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/profile', profileRoutes);
app.use('/api/profile-completion', profileCompletionRoutes);
app.use('/api/worker', workerRoutes);
app.use('/api/chat', chatRoutes);

module.exports = app;