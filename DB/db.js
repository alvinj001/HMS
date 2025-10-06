import { createPool } from "mysql2/promise"; //initiate mysql-nodejs translator
require("dotenv").config(); //activate dotenv to allow access private informaton saved in the file

//Connect to database
const db = createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME

});
//export the connected database
export default db;