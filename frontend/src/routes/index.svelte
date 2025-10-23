<script>
  import { onMount } from 'svelte';
  import { theme } from '../theme';
  import { fly, fade } from 'svelte/transition';
  import ServerCard from '../components/ServerCard.svelte';
  import { Button, Card } from '../components/ui';
  
  let servers = [];
  let loading = true;
  let error = null;
  
  onMount(async () => {
    try {
      const response = await fetch('/api/servers');
      if (!response.ok) throw new Error('Failed to load servers');
      servers = await response.json();
    } catch (err) {
      error = err.message;
    } finally {
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
    <div in:fly={{ y: -20, duration: 400 }}>
      <h1 class="text-3xl font-bold text-gray-800">Server Dashboard</h1>
      <p class="text-gray-500 mt-1">Manage all your Minecraft servers in one place</p>
    </div>
    
    <div class="flex gap-3" in:fly={{ y: -20, duration: 400, delay: 200 }}>
      <Button primary icon="plus" on:click={createNewServer}>
        New Server
      </Button>
      <Button secondary icon="download" on:click={importServer}>
        Import Server
      </Button>
    </div>
  </div>
  
  <!-- Stats Overview -->
  <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8" in:fly={{ y: 20, duration: 400, delay: 300 }}>
    <Card>
      <div class="flex items-center">
        <div class="p-3 bg-blue-100 rounded-full">
          <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M12 5l7 7-7 7"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium text-gray-500">Total Servers</h3>
          <p class="text-2xl font-semibold">{servers.length}</p>
        </div>
      </div>
    </Card>
    
    <Card>
      <div class="flex items-center">
        <div class="p-3 bg-green-100 rounded-full">
          <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium text-gray-500">Online</h3>
          <p class="text-2xl font-semibold">{servers.filter(s => s.status === 'online').length}</p>
        </div>
      </div>
    </Card>
    
    <Card>
      <div class="flex items-center">
        <div class="p-3 bg-yellow-100 rounded-full">
          <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium text-gray-500">Players Online</h3>
          <p class="text-2xl font-semibold">
            {servers.reduce((total, server) => total + (server.players?.online || 0), 0)}
          </p>
        </div>
      </div>
    </Card>
    
    <Card>
      <div class="flex items-center">
        <div class="p-3 bg-purple-100 rounded-full">
          <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
        <div class="ml-4">
          <h3 class="text-sm font-medium text-gray-500">Latest Version</h3>
          <p class="text-xl font-semibold">1.20.4</p>
        </div>
      </div>
    </Card>
  </div>
  
  {#if loading}
    <div class="flex justify-center items-center h-64" in:fade>
      <div class="pulse-loader"></div>
    </div>
  {:else if error}
    <Card class="bg-red-50 border-red-200 text-center p-8" in:fade>
      <svg class="w-12 h-12 text-red-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      <h2 class="text-xl font-medium text-red-800 mb-2">Unable to load servers</h2>
      <p class="text-red-600 mb-4">{error}</p>
      <Button on:click={() => window.location.reload()}>Try Again</Button>
    </Card>
  {:else if servers.length === 0}
    <Card class="text-center p-12 border-dashed border-2 border-gray-200" in:fade>
      <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
      </svg>
      <h2 class="text-2xl font-medium text-gray-800 mb-2">No Servers Yet</h2>
      <p class="text-gray-600 mb-6 max-w-md mx-auto">Create your first Minecraft server to start hosting adventures for you and your friends.</p>
      <Button primary size="lg" on:click={createNewServer}>Create Your First Server</Button>
    </Card>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" in:fade={{ duration: 400, delay: 200 }}>
      {#each servers as server, i}
        <div in:fly={{ y: 20, duration: 300, delay: 100 + i * 50 }}>
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
    background: rgba(59, 130, 246, 0.2);
    animation: pulse 1.5s ease-in-out infinite;
  }
  
  @keyframes pulse {
    0% { transform: scale(0.8); opacity: 0.6; }
    50% { transform: scale(1); opacity: 1; }
    100% { transform: scale(0.8); opacity: 0.6; }
  }
</style>