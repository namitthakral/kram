require('dotenv').config();
const url = process.env.DATABASE_URL;
if (url) {
  try {
    const parsed = new URL(url);
    console.log('User:', parsed.username);
  } catch (e) {
    console.log('Could not parse URL');
  }
} else {
  console.log('DATABASE_URL not set');
}
