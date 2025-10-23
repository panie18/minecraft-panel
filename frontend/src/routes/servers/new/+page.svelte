<script lang="ts">
  import { onMount } from 'svelte';
  import { toast } from 'svelte-sonner';
  import { api } from '$lib/api';
  import type { VersionInfo } from '$lib/types';
  import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
  import { Input } from '$lib/components/ui/input';
  import { Label } from '$lib/components/ui/label';
  import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '$lib/components/ui/select';
  import { Slider } from '$lib/components/ui/slider';

  let versions: VersionInfo[] = [];
  let loading = true;
  let submitting = false;
  let error: string | null = null;

  let formData = {
    name: '',
    version: '',
    memory: 2048,
    port: 25565,
    maxPlayers: 20,
    gamemode: 'survival',
    difficulty: 'normal',
    enableCommandBlocks: true,
    pvp: true
  };

  onMount(async () => {
    try {
      const versionData = await api.getVersions();
      versions = versionData.versions;
      
      // Set default to latest release
      formData.version = versionData.latest.release;
      loading = false;
    } catch (err: any) {
      error = err.message || 'Failed to load Minecraft versions';
      loading = false;
    }
  });

  async function handleSubmit() {
    submitting = true;
    error = null;
    
    try {
      const serverData = {
        name: formData.name,
        version: formData.version,
        memory: formData.memory,
        port: formData.port,
        maxPlayers: formData.maxPlayers,
        gamemode: formData.gamemode,
        difficulty: formData.difficulty,
        enableCommandBlocks: formData.enableCommandBlocks,
        pvp: formData.pvp
      };
      
      const newServer = await api.createServer(serverData);
      toast.success('Server created successfully');
      
      // Redirect to server page
      window.location.href = `/servers/${newServer.id}`;
    } catch (err: any) {
      error = err.message || 'Failed to create server';
      toast.error(error);
    } finally {
      submitting = false;
    }
  }
</script>

<div class="space-y-8">
  <div>
    <h1 class="text-3xl font-bold text-beige-900">Create New Server</h1>
    <p class="text-beige-700 mt-1">Set up a new Minecraft server with your preferred configuration</p>
  </div>
  
  {#if loading}
    <div class="flex justify-center items-center py-20">
      <div class="w-12 h-12 border-4 border-beige-500 border-t-transparent rounded-full animate-spin"></div>
    </div>
  {:else}
    <form on:submit|preventDefault={handleSubmit} class="space-y-8">
      {#if error}
        <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded-md">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm text-red-700">{error}</p>
            </div>
          </div>
        </div>
      {/if}
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Basic Settings Card -->
        <Card>
          <CardHeader>
            <CardTitle>Server Information</CardTitle>
            <CardDescription>Basic configuration for your Minecraft server</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="space-y-2">
              <Label for="name">Server Name</Label>
              <Input
                id="name"
                bind:value={formData.name}
                placeholder="My Minecraft Server"
                required
              />
            </div>
            
            <div class="space-y-2">
              <Label for="version">Minecraft Version</Label>
              <Select bind:value={formData.version} required>
                <SelectTrigger class="w-full">
                  <SelectValue placeholder="Select version" />
                </SelectTrigger>
                <SelectContent>
                  {#each versions as version}
                    <SelectItem value={version.id}>
                      {version.id} {version.latest ? '(Latest)' : ''}
                    </SelectItem>
                  {/each}
                </SelectContent>
              </Select>
            </div>
            
            <div class="space-y-2">
              <Label for="port">Server Port</Label>
              <Input
                type="number"
                id="port"
                bind:value={formData.port}
                min="1025"
                max="65535"
                required
              />
            </div>
            
            <div class="space-y-2">
              <Label for="maxPlayers">Max Players</Label>
              <Input
                type="number"
                id="maxPlayers"
                bind:value={formData.maxPlayers}
                min="1"
                max="100"
                required
              />
            </div>
          </CardContent>
        </Card>
        
        <!-- Gameplay Settings Card -->
        <Card>
          <CardHeader>
            <CardTitle>Gameplay Settings</CardTitle>
            <CardDescription>Configure how players will experience your server</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="space-y-2">
              <Label for="gamemode">Game Mode</Label>
              <Select bind:value={formData.gamemode} required>
                <SelectTrigger class="w-full">
                  <SelectValue placeholder="Select game mode" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="survival">Survival</SelectItem>
                  <SelectItem value="creative">Creative</SelectItem>
                  <SelectItem value="adventure">Adventure</SelectItem>
                  <SelectItem value="spectator">Spectator</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div class="space-y-2">
              <Label for="difficulty">Difficulty</Label>
              <Select bind:value={formData.difficulty} required>
                <SelectTrigger class="w-full">
                  <SelectValue placeholder="Select difficulty" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="peaceful">Peaceful</SelectItem>
                  <SelectItem value="easy">Easy</SelectItem>
                  <SelectItem value="normal">Normal</SelectItem>
                  <SelectItem value="hard">Hard</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div class="flex items-center justify-between space-x-2">
              <Label for="pvp">Enable PVP</Label>
              <input 
                type="checkbox" 
                id="pvp" 
                bind:checked={formData.pvp} 
                class="toggle toggle-primary" 
              />
            </div>
            
            <div class="flex items-center justify-between space-x-2">
              <Label for="enableCommandBlocks">Enable Command Blocks</Label>
              <input 
                type="checkbox" 
                id="enableCommandBlocks" 
                bind:checked={formData.enableCommandBlocks} 
                class="toggle toggle-primary" 
              />
            </div>
          </CardContent>
        </Card>
      </div>
      
      <!-- Resource Settings -->
      <Card>
        <CardHeader>
          <CardTitle>Server Resources</CardTitle>
          <CardDescription>Allocate resources for your Minecraft server</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="space-y-2">
            <div class="flex justify-between">
              <Label for="memory">Memory Allocation</Label>
              <span class="text-sm font-medium text-beige-900">{formData.memory} MB</span>
            </div>
            <Slider 
              id="memory" 
              min={512} 
              max={8192} 
              step={512} 
              bind:value={formData.memory} 
            />
            <div class="flex justify-between text-xs text-beige-600 mt-1">
              <span>512 MB</span>
              <span>4 GB</span>
              <span>8 GB</span>
            </div>
          </div>
        </CardContent>
        <CardFooter class="flex justify-end space-x-4">
          <Button variant="outline" href="/">
            Cancel
          </Button>
          
          <Button type="submit" disabled={submitting} class="bg-beige-500 hover:bg-beige-600">
            {submitting ? 'Creating...' : 'Create Server'}
          </Button>
        </CardFooter>
      </Card>
    </form>
  {/if}
</div>