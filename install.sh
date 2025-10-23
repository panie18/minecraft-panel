#!/bin/bash

# Minecraft Server Panel Installation Script
# Made with ❤️ by Pauli

# Text styling
BOLD="\e[1m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${BOLD}${CYAN}===============================================${RESET}"
echo -e "${BOLD}${CYAN}    Minecraft Server Panel Installation        ${RESET}"
echo -e "${BOLD}${CYAN}===============================================${RESET}"
echo -e "${YELLOW}Made with ❤️ by Pauli${RESET}\n"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root or with sudo${RESET}"
  exit 1
fi

# Function to print progress
progress_msg() {
  echo -e "${BOLD}${CYAN}➤ ${RESET}${BOLD}$1${RESET}"
}

# Function to print success
success_msg() {
  echo -e "${BOLD}${GREEN}✓ ${RESET}${BOLD}$1${RESET}"
}

# Check for required dependencies
progress_msg "Checking for required dependencies..."

# Check and install dependencies
check_dependency() {
  if ! command -v $1 &> /dev/null; then
    echo -e "   ${YELLOW}Installing $1...${RESET}"
    apt-get update &> /dev/null
    apt-get install -y $1 &> /dev/null
    if [ $? -ne 0 ]; then
      echo -e "${RED}Failed to install $1. Please install it manually.${RESET}"
      exit 1
    fi
  fi
}

# Check for Docker
if ! command -v docker &> /dev/null; then
  progress_msg "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  usermod -aG docker $USER
  success_msg "Docker installed successfully"
else
  success_msg "Docker is already installed"
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null; then
  progress_msg "Installing Docker Compose..."
  apt-get update &> /dev/null
  apt-get install -y docker-compose &> /dev/null
  success_msg "Docker Compose installed successfully"
else
  success_msg "Docker Compose is already installed"
fi

# Check for other dependencies
check_dependency "git"
check_dependency "curl"
check_dependency "npm"
check_dependency "node"

# Create project directory
PROJECT_DIR="/opt/minecraft-panel"
progress_msg "Creating project directory at ${PROJECT_DIR}..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Cleanup old versions but preserve server data
progress_msg "Cleaning up old versions while preserving server data..."
if [ -d "$PROJECT_DIR/backend" ] || [ -d "$PROJECT_DIR/frontend" ]; then
  # Stop running containers
  if [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
    docker-compose down 2>/dev/null
  fi
  
  # Backup server data if it exists
  if [ -d "$PROJECT_DIR/data" ]; then
    mkdir -p "$PROJECT_DIR/data_backup"
    cp -r "$PROJECT_DIR/data/minecraft_servers" "$PROJECT_DIR/data_backup/" 2>/dev/null
  fi
  
  # Remove old code but keep volumes
  rm -rf "$PROJECT_DIR/backend" "$PROJECT_DIR/frontend"
  
  # Restore server data
  if [ -d "$PROJECT_DIR/data_backup" ]; then
    mkdir -p "$PROJECT_DIR/data"
    cp -r "$PROJECT_DIR/data_backup/minecraft_servers" "$PROJECT_DIR/data/" 2>/dev/null
    rm -rf "$PROJECT_DIR/data_backup"
  fi
fi

# Create project structure
progress_msg "Setting up project files..."
mkdir -p frontend/src/{routes,components,lib,styles}
mkdir -p backend/{src,data}

# Download Satoshi font
progress_msg "Downloading Satoshi font..."
mkdir -p frontend/static/fonts
curl -s -L https://api.fontshare.com/v2/css?f[]=satoshi@900,700,500,400&display=swap > frontend/static/fonts/satoshi.css

# Modify the CSS to use local fonts
FONT_DIR="frontend/static/fonts/satoshi"
mkdir -p $FONT_DIR
curl -s -L https://api.fontshare.com/v2/fonts/satoshi/woff2 -o satoshi-fonts.zip
unzip -q -o satoshi-fonts.zip -d $FONT_DIR
rm satoshi-fonts.zip

# Create package.json for frontend
cat > frontend/package.json << EOL
{
  "name": "minecraft-panel-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "vite preview"
  },
  "devDependencies": {
    "@sveltejs/adapter-auto": "^2.0.0",
    "@sveltejs/kit": "^1.20.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.23",
    "svelte": "^4.0.0",
    "tailwindcss": "^3.3.2",
    "vite": "^4.3.6"
  },
  "dependencies": {
    "@huntabyte/bits-ui": "latest",
    "svelte-french-toast": "^1.2.0"
  },
  "type": "module"
}
EOL

# Create global CSS with Satoshi font
cat > frontend/src/styles/global.css << EOL
@import '/fonts/satoshi.css';

body {
  font-family: 'Satoshi', sans-serif;
}

.font-satoshi {
  font-family: 'Satoshi', sans-serif;
}

.font-satoshi-medium {
  font-family: 'Satoshi', sans-serif;
  font-weight: 500;
}

.font-satoshi-bold {
  font-family: 'Satoshi', sans-serif;
  font-weight: 700;
}

.font-satoshi-black {
  font-family: 'Satoshi', sans-serif;
  font-weight: 900;
}
EOL

# Create package.json for backend
cat > backend/package.json << EOL
{
  "name": "minecraft-panel-backend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "nodemon src/index.js",
    "start": "node src/index.js"
  },
  "dependencies": {
    "axios": "^1.4.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "pg": "^8.11.0",
    "socket.io": "^4.6.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
EOL

# Create docker-compose.yml
cat > docker-compose.yml << EOL
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    depends_on:
      - backend
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - VITE_API_URL=http://localhost:3001/api

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "3001:3001"
    volumes:
      - ./backend:/app
      - /app/node_modules
      - ./data:/data
      - minecraft_servers:/minecraft
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/minecraft_panel

  db:
    image: postgres:14-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=minecraft_panel
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
  minecraft_servers:
EOL

# Create Dockerfile for frontend
cat > frontend/Dockerfile << EOL
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host"]
EOL

# Create Dockerfile for backend
cat > backend/Dockerfile << EOL
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]
EOL

# Create theme.js file with beige color theme
cat > frontend/src/lib/theme.js << EOL
// Minecraft Panel Color Theme - Beige Collection

export const theme = {
  colors: {
    primary: '#B6AB97',     // Beige-4
    secondary: '#D6CBB3',   // Beige-3
    accent: '#BCB8A7',      // Beige-5
    background: '#E4DCC9',  // Beige-2
    card: '#FFFFFF',
    text: {
      primary: '#5F5B51',   // Darker version of Beige-5
      secondary: '#948C7E', // Slightly darker version of Beige-4
      light: '#E4DCC9',     // Beige-2
    },
    status: {
      online: '#7DAF9C',    // Soft green that complements beige
      offline: '#BCB8A7',   // Beige-5
      starting: '#E6C384',  // Soft amber that complements beige
      stopping: '#D79B8C',  // Soft red that complements beige
      error: '#C96567',     // Bright red that complements beige
    }
  },
  radius: {
    sm: '0.375rem',
    md: '0.5rem',
    lg: '0.75rem',
    xl: '1rem',
    full: '9999px',
  },
  animation: {
    duration: '400ms',
    easing: 'cubic-bezier(0.4, 0, 0.2, 1)',
    transition: 'all 400ms cubic-bezier(0.4, 0, 0.2, 1)',
  }
}
EOL

# Create app.css
cat > frontend/src/app.css << EOL
@import './styles/global.css';
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Create tailwind.config.js with theme colors
cat > frontend/tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      fontFamily: {
        'satoshi': ['Satoshi', 'sans-serif'],
      },
      colors: {
        beige: {
          100: '#E4DCC9', // Beige-2
          200: '#D6D2C5', // Beige-1
          300: '#D6CBB3', // Beige-3
          400: '#BCB8A7', // Beige-5
          500: '#B6AB97', // Beige-4
          600: '#A39A87', // Darker version of Beige-4
          700: '#8A8370', // Even darker
          800: '#716C5C', // Even darker
          900: '#5F5B51', // Very dark beige
        }
      },
      boxShadow: {
        'soft': '0 4px 15px rgba(0, 0, 0, 0.05)',
        'hover': '0 6px 20px rgba(0, 0, 0, 0.08)',
      },
      animation: {
        'fade-in': 'fadeIn 500ms ease-out',
        'slide-up': 'slideUp 400ms ease-out',
        'slide-down': 'slideDown 400ms ease-out',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideDown: {
          '0%': { transform: 'translateY(-20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
EOL

# Create backend/src/index.js file
cat > backend/src/index.js << EOL
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
  
  res.json({ success: true, message: \`Server \${id} is starting\` });
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
  
  res.json({ success: true, message: \`Server \${id} is stopping\` });
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
  console.log(\`Minecraft Panel Backend running on http://0.0.0.0:\${port}\`);
  console.log('Made with ❤️ by Pauli');
});
EOL

# Create frontend routes
cat > frontend/src/routes/+layout.svelte << EOL
<script>
  import { theme } from '\$lib/theme';
  import { navigating } from '\$app/stores';
  import { fade, fly } from 'svelte/transition';
  import { cubicInOut } from 'svelte/easing';
  import { Toaster } from 'svelte-french-toast';
  import '@huntabyte/bits-ui/styles/bits-ui.css';
  import '../app.css';
</script>

<div class="app min-h-screen flex flex-col font-satoshi" style="background-color: {theme.colors.background};">
  <!-- Modern header with subtle beige gradient -->
  <header 
    class="shadow-soft transition-all duration-300"
    style="
      background: linear-gradient(to right, {theme.colors.secondary}, {theme.colors.primary});
      border-bottom-left-radius: {theme.radius.lg}; 
      border-bottom-right-radius: {theme.radius.lg};
    "
  >
    <div class="container mx-auto px-4 py-4 flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-12 h-12 bg-white rounded-lg flex items-center justify-center shadow-sm">
          <!-- Minecraft cube logo with subtle animation -->
          <div class="minecraft-cube"></div>
        </div>
        <div>
          <h1 class="text-xl font-satoshi-bold" style="color: {theme.colors.text.primary};">
            Minecraft Panel
          </h1>
          <p class="text-xs" style="color: {theme.colors.text.secondary};">
            Manage your servers with style
          </p>
        </div>
      </div>
      
      <nav>
        <ul class="flex space-x-6">
          <li><a href="/" class="nav-link">Dashboard</a></li>
          <li><a href="/servers" class="nav-link">Servers</a></li>
          <li><a href="/plugins" class="nav-link">Plugins</a></li>
          <li><a href="/backups" class="nav-link">Backups</a></li>
          <li><a href="/settings" class="nav-link">Settings</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <!-- Page content with smooth animation -->
  <main class="flex-grow container mx-auto px-4 py-6">
    {#if \$navigating}
      <div class="flex justify-center items-center py-20">
        <div class="spinner"></div>
      </div>
    {:else}
      <div in:fade={{ duration: 400, easing: cubicInOut, delay: 100 }}>
        <slot></slot>
      </div>
    {/if}
  </main>

  <!-- Modern footer with attribution -->
  <footer style="
    background-color: {theme.colors.primary}; 
    border-top-left-radius: {theme.radius.lg}; 
    border-top-right-radius: {theme.radius.lg};
  ">
    <div class="container mx-auto px-4 py-6">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <p class="mb-4 md:mb-0" style="color: {theme.colors.text.light};">
          © {new Date().getFullYear()} Minecraft Panel
        </p>
        
        <div class="flex items-center">
          <span class="text-sm" style="color: {theme.colors.text.light};">Made with</span>
          <span class="mx-1 text-red-500">❤️</span>
          <span class="text-sm font-satoshi-bold" style="color: {theme.colors.text.light};">by Pauli</span>
        </div>
      </div>
    </div>
  </footer>

  <!-- Toast notifications -->
  <Toaster position="bottom-right" />
</div>

<style>
  /* Modern nav links with hover effect */
  .nav-link {
    position: relative;
    color: rgba(95, 91, 81, 0.8);
    font-weight: 500;
    padding: 0.5rem 0;
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .nav-link:hover {
    color: rgb(95, 91, 81);
  }
  
  .nav-link::after {
    content: '';
    position: absolute;
    width: 0;
    height: 2px;
    bottom: 0;
    left: 0;
    background-color: rgb(95, 91, 81);
    transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .nav-link:hover::after {
    width: 100%;
  }
  
  /* Spinning cube animation */
  .minecraft-cube {
    width: 28px;
    height: 28px;
    background-color: #B6AB97;
    animation: cube-rotate 12s infinite cubic-bezier(0.4, 0, 0.2, 1);
    transform-style: preserve-3d;
  }
  
  @keyframes cube-rotate {
    0% { transform: rotateX(0) rotateY(0); }
    50% { transform: rotateX(180deg) rotateY(180deg); }
    100% { transform: rotateX(360deg) rotateY(360deg); }
  }
  
  /* Loading spinner */
  .spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(182, 171, 151, 0.2);
    border-radius: 50%;
    border-top-color: #B6AB97;
    animation: spin 1.2s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
EOL

# Create main page route
cat > frontend/src/routes/+page.svelte << EOL
<script>
  import { onMount } from 'svelte';
  import { theme } from '\$lib/theme';
  import { fly, fade } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
  
  // Import Bits UI components
  import * as Card from '@huntabyte/bits-ui/card';
  import * as Button from '@huntabyte/bits-ui/button';
  
  let servers = [];
  let loading = true;
  let error = null;
  
  onMount(async () => {
    try {
      const response = await fetch('http://localhost:3001/api/servers');
      if (!response.ok) throw new Error('Failed to fetch servers');
      servers = await response.json();
      loading = false;
    } catch (err) {
      console.error('Error fetching servers:', err);
      error = err.message;
      loading = false;
    }
  });
  
  function createNewServer() {
    window.location.href = '/servers/new';
  }
  
  function importServer() {
    window.location.href = '/servers/import';
  }
</script>

<div class="mb-8">
  <div class="flex flex-col md:flex-row md:justify-between md:items-center gap-4 mb-8">
    <div in:fly={{ y: -20, duration: 400, easing: cubicOut }}>
      <h1 class="text-3xl font-satoshi-bold" style="color: {theme.colors.text.primary}">Server Dashboard</h1>
      <p style="color: {theme.colors.text.secondary}" class="mt-1">Manage all your Minecraft servers in one place</p>
    </div>
    
    <div class="flex gap-3" in:fly={{ y: -20, duration: 400, easing: cubicOut, delay: 200 }}>
      <Button.Root 
        on:click={createNewServer}
        class="bg-beige-500 text-white hover:bg-beige-600 px-4 py-2 rounded-md flex items-center"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        New Server
      </Button.Root>
      
      <Button.Root 
        on:click={importServer}
        class="border border-beige-500 text-beige-500 hover:bg-beige-100 px-4 py-2 rounded-md flex items-center"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0l-4 4m4-4v12"></path>
        </svg>
        Import Server
      </Button.Root>
    </div>
  </div>
  
  <!-- Stats Overview -->
  <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8" in:fly={{ y: 20, duration: 400, delay: 300 }}>
    <Card.Root class="bg-white rounded-lg overflow-hidden shadow-soft">
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: {theme.colors.background};">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.primary} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M12 5l7 7-7 7"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Total Servers</h3>
          <p class="text-2xl font-satoshi-bold" style="color: {theme.colors.text.primary};">{servers.length}</p>
        </div>
      </div>
    </Card.Root>
    
    <Card.Root class="bg-white rounded-lg overflow-hidden shadow-soft">
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: rgba(125, 175, 156, 0.2);">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.status.online} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Online</h3>
          <p class="text-2xl font-satoshi-bold" style="color: {theme.colors.text.primary};">
            {servers.filter(s => s.status === 'online').length}
          </p>
        </div>
      </div>
    </Card.Root>
    
    <Card.Root class="bg-white rounded-lg overflow-hidden shadow-soft">
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: rgba(230, 195, 132, 0.2);">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.status.starting} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Players Online</h3>
          <p class="text-2xl font-satoshi-bold" style="color: {theme.colors.text.primary};">
            {servers.reduce((total, server) => total + (server.players?.online || 0), 0)}
          </p>
        </div>
      </div>
    </Card.Root>
    
    <Card.Root class="bg-white rounded-lg overflow-hidden shadow-soft">
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: rgba(188, 184, 167, 0.2);">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.accent} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Latest Version</h3>
          <p class="text-xl font-satoshi-bold" style="color: {theme.colors.text.primary};">1.20.4</p>
        </div>
      </div>
    </Card.Root>
  </div>
  
  {#if loading}
    <div class="flex justify-center items-center h-64" in:fade={{ duration: 300 }}>
      <div class="pulse-loader"></div>
    </div>
  {:else if error}
    <Card.Root class="bg-white rounded-lg border-l-4 text-center p-8 shadow-soft" 
      style="border-left-color: {theme.colors.status.error};"
      in:fade={{ duration: 300 }}
    >
      <svg class="w-12 h-12 mx-auto mb-4" fill="none" stroke={theme.colors.status.error} viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      <h2 class="text-xl font-satoshi-bold mb-2" style="color: {theme.colors.text.primary};">Unable to load servers</h2>
      <p class="mb-4" style="color: {theme.colors.text.secondary};">{error}</p>
      <Button.Root 
        on:click={() => window.location.reload()}
        class="bg-beige-500 text-white hover:bg-beige-600 px-4 py-2 rounded-md"
      >
        Try Again
      </Button.Root>
    </Card.Root>
  {:else if servers.length === 0}
    <Card.Root 
      class="text-center p-12 border-dashed border-2 rounded-lg shadow-soft" 
      style="border-color: {theme.colors.primary}; background-color: white;"
      in:fade={{ duration: 300 }}
    >
      <svg class="w-16 h-16 mx-auto mb-4" fill="none" stroke={theme.colors.text.secondary} viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
      </svg>
      <h2 class="text-2xl font-satoshi-bold mb-2" style="color: {theme.colors.text.primary};">No Servers Yet</h2>
      <p class="mb-6 max-w-md mx-auto" style="color: {theme.colors.text.secondary};">
        Create your first Minecraft server to start hosting adventures for you and your friends.
      </p>
      <Button.Root 
        on:click={createNewServer}
        class="bg-beige-500 text-white hover:bg-beige-600 px-6 py-3 rounded-md text-lg"
      >
        Create Your First Server
      </Button.Root>
    </Card.Root>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each servers as server, i}
        <div class="animate-fade-in" style="animation-delay: {100 + i * 50}ms">
          <ServerCard {server} />
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .pulse-loader {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: rgba(182, 171, 151, 0.2);
    animation: pulse 1.5s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }
  
  @keyframes pulse {
    0% { transform: scale(0.8); opacity: 0.6; }
    50% { transform: scale(1); opacity: 1; }
    100% { transform: scale(0.8); opacity: 0.6; }
  }
</style>
EOL

# Install frontend dependencies
progress_msg "Installing frontend dependencies..."
cd $PROJECT_DIR/frontend
npm install

# Install backend dependencies
progress_msg "Installing backend dependencies..."
cd $PROJECT_DIR/backend
npm install

# Set permissions
progress_msg "Setting proper permissions..."
cd $PROJECT_DIR
chmod -R 755 .
chown -R $SUDO_USER:$SUDO_USER . 2>/dev/null || chown -R $(whoami):$(whoami) .

# Create data directory with proper permissions
mkdir -p $PROJECT_DIR/data
chmod 777 $PROJECT_DIR/data

# Start the application
progress_msg "Starting Minecraft Panel..."
docker-compose up -d

# Display completion message
PANEL_URL="http://$(hostname -I | awk '{print $1}'):3000"
echo -e "\n${BOLD}${GREEN}===============================================${RESET}"
echo -e "${BOLD}${GREEN}    Minecraft Server Panel Installed!          ${RESET}"
echo -e "${BOLD}${GREEN}===============================================${RESET}"
echo -e "\n${BOLD}Access your panel at:${RESET} ${CYAN}$PANEL_URL${RESET}"
echo -e "\n${YELLOW}Made with ❤️ by Pauli${RESET}\n"
echo -e "${BOLD}NOTE:${RESET} Sie können auch auf ${CYAN}http://$(hostname -I | awk '{print $1}'):5173${RESET} für die Entwicklungsumgebung zugreifen."

# Create an alias for easier management
echo -e "alias minecraft-panel='cd $PROJECT_DIR && docker-compose'" >> ~/.bashrc

exit 0