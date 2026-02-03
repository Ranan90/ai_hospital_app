import 'dotenv/config';
import fs from 'fs';
try {
    const key = process.env.GEMINI_API_KEY;
    console.log("Checking key...");
    fs.writeFileSync('check_key.log', key ? 'KEY_EXISTS' : 'KEY_MISSING');
} catch (e) {
    fs.writeFileSync('check_key.log', 'ERROR: ' + e.message);
}
