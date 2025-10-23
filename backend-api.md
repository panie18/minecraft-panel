# Backend API Design

## Core Endpoints

### Server Management
- `GET /api/servers` - List all servers
- `POST /api/servers` - Create a new server
- `GET /api/servers/:id` - Get server details
- `PUT /api/servers/:id` - Update server configuration
- `DELETE /api/servers/:id` - Delete a server
- `POST /api/servers/:id/start` - Start a server
- `POST /api/servers/:id/stop` - Stop a server
- `POST /api/servers/:id/restart` - Restart a server

### Server Console
- `GET /api/servers/:id/console` - Get console logs
- `POST /api/servers/:id/console` - Send command to console
- `WS /api/servers/:id/console/live` - WebSocket for real-time console

### Plugin Management
- `GET /api/servers/:id/plugins` - List installed plugins
- `POST /api/servers/:id/plugins` - Install plugin
- `DELETE /api/servers/:id/plugins/:pluginId` - Remove plugin
- `GET /api/plugins` - Browse available plugins

### Backup Management
- `GET /api/servers/:id/backups` - List backups
- `POST /api/servers/:id/backups` - Create backup
- `GET /api/servers/:id/backups/:backupId` - Get backup details
- `POST /api/servers/:id/backups/:backupId/restore` - Restore backup
- `DELETE /api/servers/:id/backups/:backupId` - Delete backup