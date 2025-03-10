const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Add logging for debugging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

app.get('/callback', (req, res) => {
    const params = new URLSearchParams(req.query).toString();
    console.log(`Redirecting with params: ${params}`);
    res.redirect(`xerotimer://oauth-callback?${params}`);
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.send('OK');
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});