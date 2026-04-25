const sql = require("mssql");
require("dotenv").config();

const poolPromise = new sql.ConnectionPool(process.env.DB_CONNECTION)
    .connect()
    .then(pool => {
        console.log("Connected to DB ✅");
        return pool;
    })
    .catch(err => {
        console.log("DB Connection Failed ❌", err);
        throw err;
    });

module.exports = {
    sql,
    poolPromise
};