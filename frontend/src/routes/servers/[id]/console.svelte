<script>
  import { onMount, onDestroy } from 'svelte';
  import { page } from '$app/stores';
  import { fly, fade } from 'svelte/transition';
  import { theme } from '$lib/theme';
  import { Button, Card, ScrollArea, Badge } from '@huntabyte/bits-ui';
  
  let serverId = $page.params.id;
  let serverInfo = null;
  let logs = [];
  let logInput = '';
  let socket = null;
  let autoScroll = true;
  let loading = true;
  
  // Fetch server details and initial logs
  onMount(async () => {
    try {
      // Connect to WebSocket for real-time logs
      socket = new WebSocket(`ws://${window.location.hostname}:3001/api/servers/${serverId}/console/live`);
      
      socket.onopen = () => {
        console.log('WebSocket connection established');
      };
      
      socket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        if (data.type === 'log') {
          logs = [...logs, data.content];
          if (autoScroll && logContainer) {
            setTimeout(() => {
              logContainer.scrollTop = logContainer.scrollHeight;
            }, 10);
          }
        } else if (data.type === 'server_info') {
          serverInfo = data.content;
        }
      };
      
      socket.onclose = () => {
        console.log('WebSocket connection closed');
      };
      
      // Fetch server info and initial logs
      const serverResponse = await fetch(`/api/servers/${serverId}`);
      serverInfo = await serverResponse.json();
      
      const logsResponse = await fetch(`/api/servers/${serverId}/console?lines=100`);
      logs = await logsResponse.json();
    } catch (error) {
      console.error('Error fetching server data:', error);
    } finally {
      loading = false;
    }
  });
  
  onDestroy(() => {
    if (socket) {
      socket.close();
    }
  });
  
  let logContainer;
  
  function sendCommand() {
    if (!logInput.trim() || !socket) return;
    
    socket.send(JSON.stringify({
      type: 'command',
      content: logInput
    }));
    
    // Ad