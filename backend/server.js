const express = require("express");
const { poolPromise } = require("./config/db");

const app = express();

app.get("/test-db", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query("SELECT * FROM users");

        res.json({
            message: "DB connected",
            data: result.recordset
        });

    } catch (err) {
        res.status(500).json({
            message: "DB connection failed",
            error: err.message
        });
    }
});

app.listen(5000, () => {
    console.log("Server running on port 5000");
});