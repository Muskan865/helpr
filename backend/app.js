const express = require('express');
const cors = require('cors');

const workerRoutes = require('./routes/workerRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/worker', workerRoutes);

module.exports = app;