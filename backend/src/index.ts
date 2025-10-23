import express from 'express';
import cors from 'cors';

const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());

app.get('/api/servers', (req, res) => {
  res.json([
    {
      id: '1',
      name: 'Survival Server',
      status: 'online',
      players: { online: 3, max: 20 },
      version: '1.20.1'
    }
  ]);
});

app.listen(port, () => {
  console.log(`Minecraft Panel Backend running on http://localhost:${port}`);
});