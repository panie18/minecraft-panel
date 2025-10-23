<script lang="ts">
  import { onMount } from 'svelte';
  import { toast } from 'svelte-sonner';
  import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
  import { Progress } from '$lib/components/ui/progress';
  import { Badge } from '$lib/components/ui/badge';
  import { api } from '$lib/api';
  import type { Server } from '$lib/types';

  let servers: Server[] = [];
  let loading = true;
  let error: string | null = null;
  
  onMount(async () => {
    try {
      servers = await api.getServers();
      loading = false;
    } catch (err: any) {
      error = err.message;
      loading = false;
      toast.error('Failed to load servers');
    }
  });

  async function startServer(id: string) {
    try {
      await api.startServer(id);
      toast.success('Server is starting');
      
      // Update server status in UI
      const server = servers.find(s => s.id === id);
      if (server) server.status = 'starting';
    } catch (err: any) {
      toast.error('Failed to start server');
    }
  }

  async function stopServer(id: string) {
    try {
      await api.stopServer(id);
      toast.success('Server is stopping');
      
      // Update server status in UI
      const server = servers.find(s => s.id === id);
      if (server) server.status = 'stopping';
    } catch (err: any) {
      toast.error('Failed to stop server');
    }
  }

  function getStatusColor(status: string) {
    switch (status) {
      case 'online': return 'bg-emerald-500 hover:bg-emerald-600';
      case 'offline': return 'bg-slate-500 hover:bg-slate-600';
      case 'starting': return 'bg-amber-500 hover:bg-amber-600';
      case 'stopping': return 'bg-red-500 hover:bg-red-600';
      default: return 'bg-slate-500 hover:bg-slate-600';
    }
  }
</script>

<div class="space-y-8">
  <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
    <div>
      <h1 class="text-3xl font-bold text-beige-900">Server Dashboard</h1>
      <p class="text-beige-700 mt-1">Manage all your Minecraft servers in one place</p>
    </div>
    
    <div class="flex gap-3">
      <Button variant="default" class="bg-beige-500 hover:bg-beige-600" href="/servers/new">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        New Server
      </Button>
      
      <Button variant="outline" class="border-beige-500 text-beige-700 hover:bg-beige-200" href="/servers/import">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
        </svg>
        Import Server
      </Button>
    </div>
  </div>
  
  <!-- Stats Overview -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
    <Card>
      <CardHeader class="pb-2">
        <CardTitle class="text-sm font-medium text-beige-700">Total Servers</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex items-center">
          <div class="p-2 rounded-full bg-beige-100 mr-3">
            <svg class="w-6 h-6 text-beige-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M12 5l7 7-7 7"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold text-beige-900">{servers.length}</p>
        </div>
      </CardContent>
    </Card>
    
    <Card>
      <CardHeader class="pb-2">
        <CardTitle class="text-sm font-medium text-beige-700">Online</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex items-center">
          <div class="p-2 rounded-full bg-emerald-100 mr-3">
            <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold text-beige-900">
            {servers.filter(s => s.status === 'online').length}
          </p>
        </div>
      </CardContent>
    </Card>
    
    <Card>
      <CardHeader class="pb-2">
        <CardTitle class="text-sm font-medium text-beige-700">Players Online</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex items-center">
          <div class="p-2 rounded-full bg-amber-100 mr-3">
            <svg class="w-6 h-6 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold text-beige-900">
            {servers.reduce((total, server) => total + (server.players?.online || 0), 0)}
          </p>
        </div>
      </CardContent>
    </Card>
    
    <Card>
      <CardHeader class="pb-2">
        <CardTitle class="text-sm font-medium text-beige-700">Latest Version</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex items-center">
          <div class="p-2 rounded-full bg-beige-100 mr-3">
            <svg class="w-6 h-6 text-beige-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
            </svg>
          </div>
          <p class="text-xl font-bold text-beige-900">1.20.4</p>
        </div>
      </CardContent>
    </Card>
  </div>
  
  {#if loading}
    <div class="flex justify-center items-center py-20">
      <div class="w-12 h-12 border-4 border-beige-500 border-t-transparent rounded-full animate-spin"></div>
    </div>
  {:else if error}
    <Card class="border-red-300 bg-red-50">
      <CardHeader>
        <CardTitle class="text-red-700">Error loading servers</CardTitle>
        <CardDescription class="text-red-600">{error}</CardDescription>
      </CardHeader>
      <CardFooter>
        <Button variant="destructive" on:click={() => window.location.reload()}>Try Again</Button>
      </CardFooter>
    </Card>
  {:else if servers.length === 0}
    <Card class="border-dashed border-2 border-beige-300 bg-white">
      <CardHeader class="items-center text-center pt-8 pb-4">
        <svg class="w-16 h-16 text-beige-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        <CardTitle class="text-2xl font-bold text-beige-900">No Servers Yet</CardTitle>
        <CardDescription class="text-beige-700 max-w-md mx-auto">
          Create your first Minecraft server to start hosting adventures for you and your friends.
        </CardDescription>
      </CardHeader>
      <CardFooter class="flex justify-center pb-8">
        <Button size="lg" class="bg-beige-500 hover:bg-beige-600" href="/servers/new">
          Create Your First Server
        </Button>
      </CardFooter>
    </Card>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each servers as server (server.id)}
        <Card class="shadow-sm hover:shadow-md transition-shadow overflow-hidden">
          <CardHeader>
            <div class="flex justify-between items-start">
              <CardTitle class="text-xl font-bold text-beige-900">{server.name}</CardTitle>
              <Badge
                class="capitalize {server.status === 'online' ? 'bg-emerald-500' : 
                       server.status === 'offline' ? 'bg-slate-500' : 
                       server.status === 'starting' ? 'bg-amber-500' : 
                       'bg-red-500'}"
              >
                {server.status}
              </Badge>
            </div>
            <CardDescription>
              <div class="flex items-center justify-between text-beige-700 mt-1">
                <span>Version: {server.version}</span>
                <span>Players: {server.players.online}/{server.players.max}</span>
              </div>
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div class="space-y-4">
              <div>
                <div class="flex justify-between text-xs text-beige-700 mb-1">
                  <span>CPU</span>
                  <span>{server.cpu}%</span>
                </div>
                <Progress value={server.cpu} class="h-2" />
              </div>
              
              <div>
                <div class="flex justify-between text-xs text-beige-700 mb-1">
                  <span>Memory</span>
                  <span>{server.memory}%</span>
                </div>
                <Progress value={server.memory} class="h-2" />
              </div>
            </div>
          </CardContent>
          <CardFooter class="flex justify-between border-t border-beige-200 bg-beige-50">
            <Button 
              size="sm" 
              variant={server.status === 'online' || server.status === 'starting' ? 'outline' : 'default'} 
              disabled={server.status === 'online' || server.status === 'starting'} 
              class={server.status === 'online' || server.status === 'starting' ? 'text-slate-400 cursor-not-allowed' : 'bg-emerald-500 hover:bg-emerald-600'}
              on:click={() => startServer(server.id)}
            >
              Start
            </Button>
            
            <Button 
              size="sm" 
              variant={server.status === 'offline' || server.status === 'stopping' ? 'outline' : 'default'} 
              disabled={server.status === 'offline' || server.status === 'stopping'} 
              class={server.status === 'offline' || server.status === 'stopping' ? 'text-slate-400 cursor-not-allowed' : 'bg-red-500 hover:bg-red-600'}
              on:click={() => stopServer(server.id)}
            >
              Stop
            </Button>
            
            <Button 
              size="sm" 
              variant="outline" 
              class="border-beige-300 hover:bg-beige-100"
              href="/servers/{server.id}"
            >
              Manage
            </Button>
          </CardFooter>
        </Card>
      {/each}
    </div>
  {/if}
</div>