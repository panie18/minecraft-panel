import type { Server, VersionManifest, Plugin, Backup } from './types';

// Ändern Sie dies zu Ihrer tatsächlichen API-URL
const API_URL = 'http://192.168.0.234:3001';

async function fetchApi<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const url = `${API_URL}${endpoint}`;
  
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });
    
    if (!response.ok) {
      throw new Error(`API request failed: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API request error:', error);
    throw error;
  }
}

export const api = {
  // Server-Management
  getServers: () => fetchApi<Server[]>('/api/servers'),
  getServer: (id: string) => fetchApi<Server>(`/api/servers/${id}`),
  startServer: (id: string) => fetchApi(`/api/servers/${id}/start`, { method: 'POST' }),
  stopServer: (id: string) => fetchApi(`/api/servers/${id}/stop`, { method: 'POST' }),
  createServer: (serverData: Partial<Server>) => fetchApi<Server>('/api/servers', { 
    method: 'POST', 
    body: JSON.stringify(serverData) 
  }),
  
  // Minecraft-Versionen
  getVersions: () => fetchApi<VersionManifest>('/api/minecraft/versions'),
  
  // Plugin-Management
  getPlugins: () => fetchApi<Plugin[]>('/api/plugins'),
  getServerPlugins: (serverId: string) => fetchApi<Plugin[]>(`/api/servers/${serverId}/plugins`),
  installPlugin: (serverId: string, pluginId: string) => fetchApi(`/api/servers/${serverId}/plugins`, {
    method: 'POST',
    body: JSON.stringify({ pluginId })
  }),
  removePlugin: (serverId: string, pluginId: string) => fetchApi(`/api/servers/${serverId}/plugins/${pluginId}`, {
    method: 'DELETE'
  }),
  
  // Backup-Management
  getBackups: (serverId: string) => fetchApi<Backup[]>(`/api/servers/${serverId}/backups`),
  createBackup: (serverId: string, name: string) => fetchApi(`/api/servers/${serverId}/backups`, {
    method: 'POST',
    body: JSON.stringify({ name })
  }),
  restoreBackup: (serverId: string, backupId: string) => fetchApi(`/api/servers/${serverId}/backups/${backupId}/restore`, {
    method: 'POST'
  }),
  deleteBackup: (serverId: string, backupId: string) => fetchApi(`/api/servers/${serverId}/backups/${backupId}`, {
    method: 'DELETE'
  })
};