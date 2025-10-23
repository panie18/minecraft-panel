export interface Player {
  online: number;
  max: number;
}

export interface Server {
  id: string;
  name: string;
  status: 'online' | 'offline' | 'starting' | 'stopping';
  version: string;
  players: Player;
  cpu: number;
  memory: number;
  uptime?: number;
}

export interface VersionInfo {
  id: string;
  type: 'release' | 'snapshot';
  latest: boolean;
}

export interface VersionManifest {
  latest: {
    release: string;
    snapshot: string;
  };
  versions: VersionInfo[];
}

export interface Plugin {
  id: string;
  name: string;
  version: string;
  description?: string;
  enabled?: boolean;
}

export interface Backup {
  id: string;
  serverId: string;
  date: string;
  size: number;
  name: string;
}