#!/bin/bash

# Minecraft Server Panel Installation Script
# Made with ❤️ by Pauli

echo "==============================================="
echo "    Minecraft Server Panel Installation        "
echo "==============================================="
echo "Made with ❤️ by Pauli"
echo

# Abhängigkeiten installieren
echo "Installiere Abhängigkeiten..."
sudo apt-get update -qq
sudo apt-get install -y curl -qq

# Projektordner erstellen
echo "Erstelle Projektordner..."
sudo mkdir -p /opt/minecraft-panel/{frontend,backend}
sudo chown -R $USER:$USER /opt/minecraft-panel
cd /opt/minecraft-panel

# Frontend und Backend initialisieren
echo "Initialisiere SvelteKit Frontend..."
cd frontend
npm create svelte@latest . -- --template skeleton --types typescript
npm install
npm i -D tailwindcss postcss autoprefixer
npm i -D @skeletonlabs/skeleton @skeletonlabs/tw-plugin @tailwindcss/forms
npm i -D vite-plugin-tailwind-purgecss @floating-ui/dom
npm i svelte-sonner @huntabyte/shadcn-svelte

# Shadcn-Svelte Komponenten installieren
npx shadcn-svelte@latest init
npx shadcn-svelte@latest add button card input label select slider progress badge

cd ../backend
echo "Initialisiere Backend..."
npm init -y
npm i express cors typescript ts-node @types/express @types/cors

# Projekt erstellen
echo "Erstelle Projekt-Dateien..."

# Docker-Compose einrichten
cat > docker-compose.yml << 'EOF'
version: '3'

services:
  backend:
    build: ./backend
    ports:
      - "3001:3001"
    volumes:
      - ./backend:/app
      - /app/node_modules

  frontend:
    build: ./frontend
    ports:
      - "5173:5173"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      - backend
EOF

# Backend-Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3001

CMD ["npm", "start"]
EOF

# Frontend-Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOF

echo "Installation abgeschlossen!"
echo "Füge nun die Code-Dateien hinzu und starte mit:"
echo "cd /opt/minecraft-panel && docker-compose up -d"