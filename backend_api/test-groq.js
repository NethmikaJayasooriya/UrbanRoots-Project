require('dotenv').config();
const Groq = require('groq-sdk');

async function main() {
  try {
    const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
    const chatCompletion = await groq.chat.completions.create({
      messages: [{ role: 'user', content: 'test' }],
      model: 'llama3-8b-8192',
    });
    console.log(chatCompletion.choices[0]?.message?.content);
  } catch (e) {
    console.error('Groq API Error:', e.message);
  }
}
main();
