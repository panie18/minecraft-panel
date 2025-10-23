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

# Clone repository or create from scratch
progress_msg "Setting up project files..."
if [ -d ".git" ]; then
  git pull
else
  # Create project structure
  mkdir -p frontend/src/{routes,components,lib}
  mkdir -p backend/{src,data}
  
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

  # Create tailwind.config.js with theme colors
  cat > frontend/tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
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
fi

# Install frontend dependencies
progress_msg "Installing frontend dependencies..."
cd $PROJECT_DIR/frontend
npm install
npm install @huntabyte/bits-ui

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
echo -e "${BOLD}NOTE:${RESET} You may need to wait a few moments for all services to start completely."

# Create an alias for easier management
echo -e "alias minecraft-panel='cd $PROJECT_DIR && docker-compose'" >> ~/.bashrc

exit 0