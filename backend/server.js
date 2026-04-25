const express = require('express');
const app = require('./app');

const authRoutes = require('./routes/authRoutes');

// routes
app.use('/auth', authRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});