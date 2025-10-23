import express from 'express';
import cors from 'cors';
import { Server, VersionManifest, Plugin } from './types';

const app = express();
const port = 3001;

// CORS für alle Ursprünge erlauben
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Demo-Server
const servers: Server[] = [
  {
    id: '1',
    name: 'Survival Server',
    status: 'online',
    version: '1.20.4',
    players: { online: 3, max: 20 },
    cpu: 32,
    memory: 45,
    uptime: 32400 // 9 hours
  },
  {
    id: '2',
    name: 'Creative Server',
    status: 'offline',
    version: '1.20.2',
    players: { online: 0, max: 10 },
    cpu: 0,
    memory: 0,
    uptime: 0
  },
  {
    id: '3',
    name: 'Skyblock Server',
    status: 'starting',
    version: '1.20.4',
    players: { online: 0, max: 30 },
    cpu: 87,
    memory: 62,
    uptime: 0
  }
];

// Demo-Plugins
const plugins: Plugin[] = [
  { id: '1', name: 'EssentialsX', version: '2.20.0', description: 'Essential commands and features' },
  { id: '2', name: 'WorldEdit', version: '7.2.15', description: 'In-game map editor' },
  { id: '3', name: 'LuckPerms', version: '5.4.98', description: 'Permission management' },
  { id: '4', name: 'CoreProtect', version: '21.3', description: 'Block logging and rollbacks' },
  { id: '5', name: 'Vault', version: '1.7.3', description: 'Economy API' }
];

// Demo-Versionen
const versions: VersionManifest = {
  latest: { release: '1.20.4', snapshot: '1.21-pre1' },
  versions: [
    { id: '1.20.4', type: 'release', latest: true },
    { id: '1.20.2', type: 'release', latest: false },
    { id: '1.19.4', type: 'release', latest: false },
    { id: '1.18.2', type: 'release', latest: false },
    { id: '1.17.1', type: 'release', latest: false },
    { id: '1.16.5', type: 'release', latest: false },
    { id: '1.21-pre1', type: 'snapshot', latest: true },
  ]
};

// API-Endpunkte
app.get('/api/servers', (req, res) => {
  console.log('Servers requested');
  res.json(servers);
});

app.get('/api/servers/:id', (req, res) => {
  const { id } = req.params;
  const server = servers.find(s => s.id === id);
  
  if (!server) {
    return res.status(404).json({ error: 'Server not found' });
  }
  
  res.json(server);
});

// Server starten
app.post('/api/servers/:id/start', (req, res) => {
  const { id } = req.params;
  const server = servers.find(s => s.id === id);
  
  if (!server) {
    return res.status(404).json({ error: 'Server not found' });
  }
  
  if (server.status === 'online' || server.status === 'starting') {
    return res.status(400).json({ error: 'Server is already running or starting' });
  }
  
  server.status = 'starting';
  
  // Nach 2 Sekunden auf "online" setzen (Simulation)
  setTimeout(() => {
    server.status = 'online';
    server.cpu = Math.floor(Math.random() * 50) + 20;
    server.memory = Math.floor(Math.random() * 60) + 20;
    server.uptime = 0;
  }, 2000);
  
  res.json({ success: true, message: `Server ${id} is starting` });
});

// Server stoppen
app.post('/api/servers/:id/stop', (req, res) => {
  const { id } = req.params;
  const server = servers.find(s => s.id === id);
  
  if (!server) {
    return res.status(404).json({ error: 'Server not found' });
  }
  
  if (server.status === 'offline' || server.status === 'stopping') {
    return res.status(400).json({ error: 'Server is already stopped or stopping' });
  }
  
  server.status = 'stopping';
  
  // Nach 2 Sekunden auf "offline" setzen (Simulation)
  setTimeout(() => {
    server.status = 'offline';
    server.cpu = 0;
    server.memory = 0;
    server.uptime = 0;
  }, 2000);
  
  res.json({ success: true, message: `Server ${id} is stopping` });
});

// Neuen Server erstellen
app.post('/api/servers', (req, res) => {
  const { name, version, memory, port, maxPlayers, gamemode, difficulty } = req.body;
  
  if (!name || !version) {
    return res.status(400).json({ error: 'Name and version are required' });
  }
  
  const newServer: Server = {
    id: Date.now().toString(),
    name,
    version,
    status: 'offline',
    players: { online: 0, max: maxPlayers || 20 },
    cpu: 0,
    memory: 0,
    uptime: 0
  };
  
  servers.push(newServer);
  
  res.status(201).json(newServer);
});

// Plugin-Endpunkte
app.get('/api/plugins', (req, res) => {
  res.json(plugins);
});

app.get('/api/servers/:id/plugins', (req, res) => {
  const serverId = req.params.id;
  
  // Demo-Plugins für Server
  const serverPlugins = [
    { id: '1', name: 'EssentialsX', version: '2.20.0', enabled: true },
    { id: '3', name: 'LuckPerms', version: '5.4.98', enabled: true }
  ];
  
  res.json(serverPlugins);
});

// Minecraft-Versionen
app.get('/api/minecraft/versions', (req, res) => {
  res.json(versions);
});

// Health-Check-Endpunkt
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Server starten
app.listen(port, '0.0.0.0', () => {
  console.log(`Minecraft Panel Backend running on http://0.0.0.0:${port}`);
  console.log('Made with ❤️ by Pauli');
});