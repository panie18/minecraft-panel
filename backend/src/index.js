const express = require('express');
const cors = require('cors');
const axios = require('axios');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs').promises;

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Grundlegende Serverstatistiken
const serverStats = {
  cpuUsage: () => Math.floor(Math.random() * 100),
  memoryUsage: () => Math.floor(Math.random() * 100),
  diskUsage: () => Math.floor(Math.random() * 100)
};

// Demo-Server-Daten
const demoServers = [
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
    name: 'Creative Build',
    status: 'offline',
    version: '1.20.2',
    players: { online: 0, max: 10 },
    cpu: 0,
    memory: 0,
    uptime: 0
  },
  {
    id: '3',
    name: 'Skyblock Adventure',
    status: 'starting',
    version: '1.20.4',
    players: { online: 0, max: 30 },
    cpu: 87,
    memory: 62,
    uptime: 0
  }
];

// API-Routen
// Versions API - Return available Minecraft versions
app.get('/api/minecraft/versions', async (req, res) => {
  try {
    // Fetch the latest version manifest from Mojang
    const response = await axios.get('https://launchermeta.mojang.com/mc/game/version_manifest.json');
    const data = response.data;
    
    // Format the response
    const versions = data.versions.map(version => ({
      id: version.id,
      type: version.type,
      url: version.url,
      latest: version.id === data.latest.release || version.id === data.latest.snapshot
    }));
    
    res.json({
      latest: {
        release: data.latest.release,
        snapshot: data.latest.snapshot
      },
      versions: versions.slice(0, 20) // Only return the 20 most recent for demo
    });
  } catch (error) {
    console.error('Error fetching Minecraft versions:', error);
    res.status(500).json({ error: 'Failed to fetch Minecraft versions' });
  }
});

// Servers API - Liste aller Server
app.get('/api/servers', (req, res) => {
  res.json(demoServers);
});

// Server details - Details eines Servers
app.get('/api/servers/:id', (req, res) => {
  const { id } = req.params;
  const server = demoServers.find(s => s.id === id);
  
  if (!server) {
    return res.status(404).json({ error: 'Server not found' });
  }
  
  // Zusätzliche Details hinzufügen
  const serverWithDetails = {
    ...server,
    stats: {
      cpu: server.cpu,
      memory: server.memory,
      disk: Math.floor(Math.random() * 80) + 10,
      uptime: server.uptime
    },
    properties: {
      gamemode: 'survival',
      difficulty: 'normal',
      pvp: true,
      commandBlocks: true,
      maxPlayers: server.players.max,
      viewDistance: 10,
      motd: 'Welcome to My Minecraft Server!'
    }
  };
  
  res.json(serverWithDetails);
});

// Server starten
app.post('/api/servers/:id/start', (req, res) => {
  const { id } = req.params;
  const server = demoServers.find(s => s.id === id);
  
  if (!server) {
    return res.status(404).json({ error: 'Server not found' });
  }
  
  if (server.status === 'online' || server.status === 'starting') {
    return res.status(400).json({ error: 'Server is already running or starting' });
  }
  
  // Status auf "starting" setzen
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
  const server = demoServers.find(s => s.id === id);
  
  if (!server) {
    return res.status(404).json({ error: 'Server not found' });
  }
  
  if (server.status === 'offline' || server.status === 'stopping') {
    return res.status(400).json({ error: 'Server is already stopped or stopping' });
  }
  
  // Status auf "stopping" setzen
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
  
  const newServer = {
    id: Date.now().toString(),
    name,
    version,
    status: 'offline',
    players: { online: 0, max: maxPlayers || 20 },
    cpu: 0,
    memory: 0,
    uptime: 0
  };
  
  demoServers.push(newServer);
  
  res.status(201).json(newServer);
});

// Plugins API
app.get('/api/plugins', (req, res) => {
  const plugins = [
    { id: '1', name: 'EssentialsX', version: '2.20.0', description: 'Essential commands and features' },
    { id: '2', name: 'WorldEdit', version: '7.2.15', description: 'In-game map editor' },
    { id: '3', name: 'LuckPerms', version: '5.4.98', description: 'Permission management' },
    { id: '4', name: 'CoreProtect', version: '21.3', description: 'Block logging and rollbacks' },
    { id: '5', name: 'Vault', version: '1.7.3', description: 'Economy API' }
  ];
  
  res.json(plugins);
});

// Server-Plugins API
app.get('/api/servers/:id/plugins', (req, res) => {
  const { id } = req.params;
  
  // Demo plugins für jeden Server
  const plugins = [
    { id: '1', name: 'EssentialsX', version: '2.20.0', enabled: true },
    { id: '3', name: 'LuckPerms', version: '5.4.98', enabled: true }
  ];
  
  res.json(plugins);
});

// System-Status-API
app.get('/api/system/status', (req, res) => {
  res.json({
    cpu: serverStats.cpuUsage(),
    memory: serverStats.memoryUsage(),
    disk: serverStats.diskUsage(),
    uptime: Math.floor(process.uptime())
  });
});

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', version: '1.0.0' });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Minecraft Panel Backend running on http://0.0.0.0:${port}`);
  console.log('Made with ❤️ by Pauli');
});