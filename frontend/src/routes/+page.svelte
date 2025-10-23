<script>
  import { onMount } from 'svelte';
  import { theme } from '$lib/theme';
  import { fly, fade } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
  import ServerCard from '../components/ServerCard.svelte';
  
  // Import Bits UI components
  import { Button, Card } from '@huntabyte/bits-ui';
  
  let servers = [];
  let loading = true;
  let error = null;
  
  onMount(async () => {
    try {
      // In a real app, this would fetch from your API
      setTimeout(() => {
        servers = [
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
        loading = false;
      }, 1000);
    } catch (err) {
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
      <h1 class="text-3xl font-bold" style="color: {theme.colors.text.primary}">Server Dashboard</h1>
      <p style="color: {theme.colors.text.secondary}" class="mt-1">Manage all your Minecraft servers in one place</p>
    </div>
    
    <div class="flex gap-3" in:fly={{ y: -20, duration: 400, easing: cubicOut, delay: 200 }}>
      <Button 
        on:click={createNewServer}
        style="
          --btn-accent: {theme.colors.primary};
          --btn-radius: {theme.radius.md};
        "
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        New Server
      </Button>
      
      <Button 
        on:click={importServer}
        variant="outline"
        style="
          --btn-accent: {theme.colors.primary};
          --btn-radius: {theme.radius.md};
        "
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0l-4 4m4-4v12"></path>
        </svg>
        Import Server
      </Button>
    </div>
  </div>
  
  <!-- Stats Overview -->
  <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8" in:fly={{ y: 20, duration: 400, delay: 300 }}>
    <Card.Root 
      class="bg-white"
      style="--card-border-radius: {theme.radius.md};"
    >
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: {theme.colors.background};">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.primary} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M12 5l7 7-7 7"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Total Servers</h3>
          <p class="text-2xl font-semibold" style="color: {theme.colors.text.primary};">{servers.length}</p>
        </div>
      </div>
    </Card.Root>
    
    <Card.Root 
      class="bg-white"
      style="--card-border-radius: {theme.radius.md};"
    >
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: rgba(125, 175, 156, 0.2);">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.status.online} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Online</h3>
          <p class="text-2xl font-semibold" style="color: {theme.colors.text.primary};">{servers.filter(s => s.status === 'online').length}</p>
        </div>
      </div>
    </Card.Root>
    
    <Card.Root 
      class="bg-white"
      style="--card-border-radius: {theme.radius.md};"
    >
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: rgba(230, 195, 132, 0.2);">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.status.starting} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Players Online</h3>
          <p class="text-2xl font-semibold" style="color: {theme.colors.text.primary};">
            {servers.reduce((total, server) => total + (server.players?.online || 0), 0)}
          </p>
        </div>
      </div>
    </Card.Root>
    
    <Card.Root 
      class="bg-white"
      style="--card-border-radius: {theme.radius.md};"
    >
      <div class="flex items-center p-4">
        <div class="p-3 rounded-full" style="background-color: rgba(188, 184, 167, 0.2);">
          <svg class="w-6 h-6" fill="none" stroke={theme.colors.accent} viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium" style="color: {theme.colors.text.secondary};">Latest Version</h3>
          <p class="text-xl font-semibold" style="color: {theme.colors.text.primary};">1.20.4</p>
        </div>
      </div>
    </Card.Root>
  </div>
  
  {#if loading}
    <div class="flex justify-center items-center h-64" in:fade={{ duration: 300 }}>
      <div class="pulse-loader"></div>
    </div>
  {:else if error}
    <Card.Root 
      class="bg-white border-l-4 text-center p-8" 
      style="--card-border-radius: {theme.radius.md}; border-left-color: {theme.colors.status.error};"
      in:fade={{ duration: 300 }}
    >
      <svg class="w-12 h-12 mx-auto mb-4" fill="none" stroke={theme.colors.status.error} viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      <h2 class="text-xl font-medium mb-2" style="color: {theme.colors.text.primary};">Unable to load servers</h2>
      <p class="mb-4" style="color: {theme.colors.text.secondary};">{error}</p>
      <Button 
        on:click={() => window.location.reload()}
        style="--btn-accent: {theme.colors.primary}; --btn-radius: {theme.radius.md};"
      >
        Try Again
      </Button>
    </Card.Root>
  {:else if servers.length === 0}
    <Card.Root 
      class="text-center p-12 border-dashed border-2" 
      style="--card-border-radius: {theme.radius.md}; border-color: {theme.colors.primary}; background-color: white;"
      in:fade={{ duration: 300 }}
    >
      <svg class="w-16 h-16 mx-auto mb-4" fill="none" stroke={theme.colors.text.secondary} viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
      </svg>
      <h2 class="text-2xl font-medium mb-2" style="color: {theme.colors.text.primary};">No Servers Yet</h2>
      <p class="mb-6 max-w-md mx-auto" style="color: {theme.colors.text.secondary};">
        Create your first Minecraft server to start hosting adventures for you and your friends.
      </p>
      <Button 
        on:click={createNewServer}
        size="lg"
        style="--btn-accent: {theme.colors.primary}; --btn-radius: {theme.radius.md};"
      >
        Create Your First Server
      </Button>
    </Card.Root>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each servers as server, i}
        <div style="animation-delay: {100 + i * 50}ms">
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