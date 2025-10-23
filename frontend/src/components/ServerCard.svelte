<script>
  import { theme } from '$lib/theme';
  import { fly, fade } from 'svelte/transition';
  import { onMount } from 'svelte';
  import toast from 'svelte-french-toast';
  
  // Import Bits UI components
  import { 
    Button, 
    DropdownMenu,
    Progress,
    Badge
  } from '@huntabyte/bits-ui';
  
  export let server = {
    id: '',
    name: '',
    status: 'offline',
    version: '',
    players: { online: 0, max: 20 },
    cpu: 0,
    memory: 0,
    uptime: 0
  };
  
  let progressBarClass;
  
  // Calculate memory usage color
  $: if (server.memory > 85) {
    progressBarClass = 'bg-red-400';
  } else if (server.memory > 60) {
    progressBarClass = 'bg-amber-400';
  } else {
    progressBarClass = 'bg-emerald-400';
  }
  
  // Format uptime
  $: formattedUptime = formatUptime(server.uptime);
  
  function formatUptime(seconds) {
    if (!seconds || server.status !== 'online') return '-';
    
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (days > 0) return `${days}d ${hours}h`;
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  }
  
  async function startServer() {
    try {
      await fetch(`/api/servers/${server.id}/start`, { method: 'POST' });
      server.status = 'starting';
      toast.success('Server starting...', { style: 'background: #E4DCC9; color: #5F5B51' });
    } catch (error) {
      console.error('Failed to start server:', error);
      toast.error('Failed to start server', { style: 'background: #D79B8C; color: #5F5B51' });
    }
  }
  
  async function stopServer() {
    try {
      await fetch(`/api/servers/${server.id}/stop`, { method: 'POST' });
      server.status = 'stopping';
      toast.info('Server stopping...', { style: 'background: #D6CBB3; color: #5F5B51' });
    } catch (error) {
      console.error('Failed to stop server:', error);
      toast.error('Failed to stop server', { style: 'background: #D79B8C; color: #5F5B51' });
    }
  }
  
  function navigateToServer() {
    window.location.href = `/servers/${server.id}`;
  }
  
  // Status badge style
  $: badgeStyle = {
    online: { bg: theme.colors.status.online, text: '#fff' },
    offline: { bg: theme.colors.status.offline, text: '#fff' },
    starting: { bg: theme.colors.status.starting, text: '#5F5B51' },
    stopping: { bg: theme.colors.status.stopping, text: '#fff' }
  }[server.status] || { bg: theme.colors.status.offline, text: '#fff' };
</script>

<div 
  class="bg-white rounded-xl shadow-soft hover:shadow-hover transition-all duration-300"
  style="border-radius: {theme.radius.lg}; animation: {theme.animation.transition};"
  in:fly={{ y: 20, duration: 400, delay: 100 }}
>
  <!-- Header with status badge -->
  <div class="p-5 pb-4">
    <div class="flex justify-between items-start mb-2">
      <h3 
        class="text-xl font-semibold cursor-pointer hover:text-beige-500 transition-all duration-300"
        style="color: {theme.colors.text.primary};"
        on:click={navigateToServer}
      >
        {server.name}
      </h3>
      
      <Badge
        variant="outline"
        class="capitalize animate-pulse-slow"
        style="background-color: {badgeStyle.bg}; color: {badgeStyle.text}; border: none;"
      >
        {server.status}
      </Badge>
    </div>
    
    <div class="flex items-center text-sm" style="color: {theme.colors.text.secondary};">
      <div class="flex items-center mr-4">
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        <span>{server.version}</span>
      </div>
      
      <div class="flex items-center">
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
        </svg>
        <span>{server.players?.online || 0}/{server.players?.max || 20}</span>
      </div>
    </div>
  </div>
  
  <!-- Stats with modern progress bars -->
  <div class="px-5 pb-4">
    <div class="mb-3">
      <div class="flex justify-between text-xs mb-1">
        <span style="color: {theme.colors.text.secondary};">Memory</span>
        <span class="font-medium" style="color: {theme.colors.text.primary};">{server.memory}%</span>
      </div>
      <Progress.Root 
        value={server.memory} 
        class="h-2 bg-beige-100 overflow-hidden rounded-full"
      >
        <Progress.Indicator 
          class="h-full transition-all duration-500 ease-out {progressBarClass}" 
          style="border-radius: {theme.radius.full};"
        />
      </Progress.Root>
    </div>
    
    <div class="mb-3">
      <div class="flex justify-between text-xs mb-1">
        <span style="color: {theme.colors.text.secondary};">CPU</span>
        <span class="font-medium" style="color: {theme.colors.text.primary};">{server.cpu}%</span>
      </div>
      <Progress.Root 
        value={server.cpu} 
        class="h-2 bg-beige-100 overflow-hidden rounded-full"
      >
        <Progress.Indicator 
          class="h-full bg-beige-500 transition-all duration-500 ease-out" 
          style="border-radius: {theme.radius.full};"
        />
      </Progress.Root>
    </div>
    
    <!-- Uptime badge -->
    {#if server.status === 'online' && server.uptime}
      <div class="flex items-center text-xs mb-3" style="color: {theme.colors.text.secondary};">
        <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span>Uptime: {formattedUptime}</span>
      </div>
    {/if}
  </div>
  
  <!-- Action buttons with hover effect -->
  <div class="px-5 py-3 flex items-center justify-between border-t" style="background-color: {theme.colors.secondary}; border-color: {theme.colors.primary}; border-bottom-left-radius: {theme.radius.lg}; border-bottom-right-radius: {theme.radius.lg};">
    <div class="flex space-x-2">
      <Button 
        size="sm" 
        variant={server.status === 'online' ? 'outline' : 'solid'} 
        disabled={server.status === 'online' || server.status === 'starting'}
        on:click={startServer}
        style="
          --btn-accent: {theme.colors.status.online};
          --btn-radius: {theme.radius.md};
        "
      >
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        Start
      </Button>
      
      <Button 
        size="sm" 
        variant={server.status === 'offline' ? 'outline' : 'solid'} 
        disabled={server.status === 'offline' || server.status === 'stopping'}
        on:click={stopServer}
        style="
          --btn-accent: {theme.colors.status.stopping};
          --btn-radius: {theme.radius.md};
        "
      >
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z"></path>
        </svg>
        Stop
      </Button>
    </div>
    
    <div class="flex items-center">
      <Button 
        size="icon-sm" 
        variant="ghost" 
        on:click={() => window.location.href = `/servers/${server.id}/console`}
        class="mx-1"
        style="--btn-radius: {theme.radius.md};"
        title="Console"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
        </svg>
      </Button>
      
      <DropdownMenu.Root>
        <DropdownMenu.Trigger asChild let:builder>
          <Button 
            builders={[builder]} 
            size="icon-sm" 
            variant="ghost"
            style="--btn-radius: {theme.radius.md};"
            title="More options"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"></path>
            </svg>
          </Button>
        </DropdownMenu.Trigger>
        
        <DropdownMenu.Content style="--dropdown-radius: {theme.radius.md}; --dropdown-bg: #FFF;">
          <DropdownMenu.Item 
            href="/servers/{server.id}"
            style="--dropdown-item-hover-bg: {theme.colors.background};"
          >
            Manage Server
          </DropdownMenu.Item>
          <DropdownMenu.Item 
            href="/servers/{server.id}/plugins"
            style="--dropdown-item-hover-bg: {theme.colors.background};"
          >
            Plugins
          </DropdownMenu.Item>
          <DropdownMenu.Item 
            href="/servers/{server.id}/backups"
            style="--dropdown-item-hover-bg: {theme.colors.background};"
          >
            Backups
          </DropdownMenu.Item>
          <DropdownMenu.Item 
            href="/servers/{server.id}/settings"
            style="--dropdown-item-hover-bg: {theme.colors.background};"
          >
            Settings
          </DropdownMenu.Item>
          <DropdownMenu.Item 
            href="/servers/{server.id}/files"
            style="--dropdown-item-hover-bg: {theme.colors.background};"
          >
            File Manager
          </DropdownMenu.Item>
        </DropdownMenu.Content>
      </DropdownMenu.Root>
    </div>
  </div>
</div>

<style>
  .animate-pulse-slow {
    animation: pulse-slow 2s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  }
  
  @keyframes pulse-slow {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.7;
    }
  }
</style>