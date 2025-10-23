const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const db = require('../database/db');

const MINECRAFT_DIR = '/minecraft';

// List all servers
exports.getServers = async (req, res) => {
  try {
    const servers = await db.query('SELECT * FROM servers ORDER BY created_at DESC');
    
    // Add runtime stats to each server
    for (const server of servers) {
      if (server.status === 'online') {
        // Get real-time stats
        server.stats = await getServerStats(server.id);
      } else {
        server.stats = { cpu: 0, memory: 0, players: { online: 0, max: server.max_players } };
      }
    }
    
    res.json(servers);
  } catch (error) {
    console.error('Error fetching servers:', error);
    res.status(500).json({ error: 'Failed to fetch servers' });
  }
};

// Create a new server
exports.createServer = async (req, res) => {
  const {
    name,
    version,
    memory,
    port,
    maxPlayers,
    gamemode,
    difficulty,
    enableCommandBlocks
  } = req.body;
  
  if (!name || !version || !memory || !port) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  
  try {
    // Create server directory
    const serverId = Date.now().toString();
    const serverDir = path.join(MINECRAFT_DIR, serverId);
    await fs.mkdir(serverDir, { recursive: true });
    
    // Download server jar
    await downloadServerJar(version, serverDir);
    
    // Create server.properties file
    await createServerProperties({
      serverId,
      port,
      maxPlayers,
      gamemode,
      difficulty,
      enableCommandBlocks
    });
    
    // Insert server into database
    const server = await db.query(
      'INSERT INTO servers (id, name, version, memory, port, status, max_players) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [serverId, name, version, memory, port, 'offline', maxPlayers || 20]
    );
    
    res.status(201).json(server[0]);
  } catch (error) {
    console.error('Error creating server:', error);
    res.status(500).json({ error: 'Failed to create server' });
  }
};

// Start a server
exports.startServer = async (req, res) => {
  const { id } = req.params;
  
  try {
    const server = await getServerById(id);
    if (!server) {
      return res.status(404).json({ error: 'Server not found' });
    }
    
    if (server.status === 'online' || server.status === 'starting') {
      return res.status(400).json({ error: 'Server is already running or starting' });
    }
    
    // Update status
    await db.query('UPDATE servers SET status = $1 WHERE id = $2', ['starting', id]);
    
    // Start server in Docker container
    const containerName = `minecraft-server-${id}`;
    const serverDir = path.join(MINECRAFT_DIR, id);
    const jarFile = await findJarFile(serverDir);
    
    exec(`docker run -d --name ${containerName} \
          -v ${serverDir}:/data \
          -e EULA=TRUE \
          -e MEMORY="${server.memory}M" \
          -p ${server.port}:25565 \
          -e TYPE=VANILLA \
          -e MINECRAFT_VERSION=${server.version} \
          -e SERVER_NAME="${server.name}" \
          itzg/minecraft-server`, async (error) => {
      if (error) {
        console.error(`Failed to start server ${id}:`, error);
        await db.query('UPDATE servers SET status = $1 WHERE id = $2', ['offline', id]);
        return;
      }
      
      // Update status after container is running
      await db.query('UPDATE servers SET status = $1 WHERE id = $2', ['online', id]);
    });
    
    res.json({ message: 'Server starting' });
  } catch (error) {
    console.error(`Error starting server ${id}:`, error);
    res.status(500).json({ error: 'Failed to start server' });
  }
};

// Stop a server
exports.stopServer = async (req, res) => {
  const { id } = req.params;
  
  try {
    const server = await getServerById(id);
    if (!server) {
      return res.status(404).json({ error: 'Server not found' });
    }
    
    if (server.status === 'offline' || server.status === 'stopping') {
      return res.status(400).json({ error: 'Server is already stopped or stopping' });
    }
    
    // Update status
    await db.query('UPDATE servers SET status = $1 WHERE id = $2', ['stopping', id]);
    
    // Stop server container
    const containerName = `minecraft-server-${id}`;
    exec(`docker stop ${containerName} && docker rm ${containerName}`, async (error) => {
      if (error) {
        console.error(`Failed to stop server ${id}:`, error);
        return;
      }
      
      await db.query('UPDATE servers SET status = $1 WHERE id = $2', ['offline', id]);
    });
    
    res.json({ message: 'Server stopping' });
  } catch (error) {
    console.error(`Error stopping server ${id}:`, error);
    res.status(500).json({ error: 'Failed to stop server' });
  }
};

// Helper functions
async function getServerById(id) {
  const servers = await db.query('SELECT * FROM servers WHERE id = $1', [id]);
  return servers.length > 0 ? servers[0] : null;
}

async function downloadServerJar(version, serverDir) {
  // Implementation to download server.jar for specified version
}

async function createServerProperties(options) {
  // Implementation to create server.properties file
}

async function findJarFile(serverDir) {
  // Implementation to find server jar file
}

async function getServerStats(serverId) {
  // Implementation to get real-time server stats
}