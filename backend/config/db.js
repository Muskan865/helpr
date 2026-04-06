// const config = {
//     user: "helprUser",
//     password: "dummy",
//     server: "DESKTOP-4DIK8GO\MUSKAN",
//     database: "helprData",
//     options: {
//         trustServerCertificate: true
//     }
// };

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
    });

module.exports = {
    sql,
    poolPromise
};