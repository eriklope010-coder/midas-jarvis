import 'dotenv/config';
import express from 'express';
import OpenAI from 'openai';

const app = express();
app.use(express.json({ limit: '1mb' }));
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const conversations = new Map();

const MIDAS_PROMPT = `Eres MIDAS, un asistente personal de voz para iPhone inspirado en la idea de un mayordomo tecnológico, pero con identidad propia. Hablas en español de España por defecto. Eres rápido, inteligente, claro y útil. Puedes resolver matemáticas y problemas paso a paso cuando haga falta, explicar ciencia, estudiar, programar, redactar, razonar y ayudar con preguntas generales. Para información que cambia con el tiempo (hora actual, clima, noticias, resultados, precios, horarios, datos recientes), usa búsqueda web cuando sea necesario. Si no sabes algo, dilo y compruébalo en vez de inventar. Como estás en una conversación por voz, responde normalmente en 1-5 frases salvo que el usuario pida detalle. Tienes humor seco y elegante: de vez en cuando puedes soltar un chiste breve, una curiosidad graciosa o una observación ingeniosa, sin forzarlo. Nunca afirmes haber controlado el iPhone o una app si no has ejecutado una herramienta real. No finjas capacidades.`;

app.get('/health', (_, res) => res.json({ ok: true, name: 'MIDAS' }));

app.post('/chat', async (req, res) => {
  try {
    const { sessionId = 'default', message } = req.body ?? {};
    if (!message || typeof message !== 'string') return res.status(400).json({ error: 'message required' });

    let conversationId = conversations.get(sessionId);
    if (!conversationId) {
      const conv = await client.conversations.create();
      conversationId = conv.id;
      conversations.set(sessionId, conversationId);
    }

    const response = await client.responses.create({
      model: 'gpt-6.1-terra',
      instructions: MIDAS_PROMPT,
      conversation: conversationId,
      input: [{ role: 'user', content: message }],
      tools: [{ type: 'web_search' }]
    });

    res.json({ reply: response.output_text || 'No he encontrado una respuesta útil.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'AI request failed' });
  }
});

app.listen(Number(process.env.PORT || 8787), '0.0.0.0', () => console.log('MIDAS backend ready'));
