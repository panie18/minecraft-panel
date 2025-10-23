<script>
  import { onMount } from 'svelte';
  import { fly, fade } from 'svelte/transition';
  import { theme } from '../../theme';
  import { Button, Card, Input, Select, Range, Toggle } from '../../components/ui';
  
  let versions = [];
  let loading = true;
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
  
  let submitting = false;
  let error = null;
  
  onMount(async () => {
    try {
      // Fetch available Minecraft versions
      const response = await fetch('/api/minecraft/versions');
      const data = await response.json();
      versions = data.versions;
      
      // Set default to latest release
      const latestRelease = versions.find(v => v.type === 'release' && v.latest);
      if (latestRelease) {
        formData.version = latestRelease.id;
      }
    } catch (err) {
      error = "Failed to load Minecraft versions";
      console.error(err);
    } finally {
      loading = false;
    }
  });
  
  async function handleSubmit() {
    submitting = true;
    error = null;
    
    try {
      const response = await fetch('/api/servers', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to create server');
      }
      
      const server = await response.json();
      window.location.href = `/servers/${server.id}`;
    } catch (err) {
      error = err.message;
    } finally {
      submitting = false;
    }
  }
</script>

<div class="mb-8">
  <div in:fly={{ y: -20, duration: 400 }}>
    <h1 class="text-3xl font-bold text-gray-800 mb-2">Create New Server</h1>
    <p class="text-gray-500">Set up a new Minecraft server with your preferred configuration</p>
  </div>
  
  <div class="mt-8 max-w-4xl" in:fade={{ duration: 300, delay: 200 }}>
    {#if loading}
      <div class="flex justify-center items-center h-64">
        <div class="pulse-loader"></div>
      </div>
    {:else}
      <form on:submit|preventDefault={handleSubmit} class="space-y-8">
        {#if error}
          <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded-md" in:fly={{ y: 10, duration: 300 }}>
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
          <Card title="Server Information" in:fly={{ y: 20, duration: 400, delay: 100 }}>
            <div class="space-y-4 p-4">
              <Input
                label="Server Name"
                id="name"
                bind:value={formData.name}
                placeholder="My Minecraft Server"
                required
              />
              
              <Select
                label="Minecraft Version"
                id="version"
                bind:value={formData.version}
                required
              >
                <option value="" disabled>Select a version</option>
                {#each versions as version}
                  <option value={version.id}>
                    {version.id} {version.latest ? '(Latest)' : ''}
                  </option>
                {/each}
              </Select>
              
              <Input
                label="Server Port"
                type="number"
                id="port"
                bind:value={formData.port}
                min="1025"
                max="65535"
                required
              />
              
              <Input
                label="Max Players"
                type="number"
                id="maxPlayers"
                bind:value={formData.maxPlayers}
                min="1"
                max="100"
                required
              />
            </div>
          </Card>
          
          <!-- Advanced Settings Card -->
          <Card title="Gameplay Settings" in:fly={{ y: 20, duration: 400, delay: 200 }}>
            <div class="space-y-4 p-4">
              <Select
                label="Game Mode"
                id="gamemode"
                bind:value={formData.gamemode}
                required
              >
                <option value="survival">Survival</option>
                <option value="creative">Creative</option>
                <option value="adventure">Adventure</option>
                <option value="spectator">Spectator</option>
              </Select>
              
              <Select
                label="Difficulty"
                id="difficulty"
                bind:value={formData.difficulty}
                required
              >
                <option value="peaceful">Peaceful</option>
                <option value="easy">Easy</option>
                <option value="normal">Normal</option>
                <option value="hard">Hard</option>
              </Select>
              
              <Toggle
                label="Enable PVP"
                id="pvp"
                bind:checked={formData.pvp}
              />
              
              <Toggle
                label="Enable Command Blocks"
                id="enableCommandBlocks"
                bind:checked={formData.enableCommandBlocks}
              />
            </div>
          </Card>
        </div>
        
        <!-- Resource Settings -->
        <Card title="Server Resources" in:fly={{ y: 20, duration: 400, delay: 300 }}>
          <div class="p-4">
            <div class="mb-2">
              <label for="memory" class="block text-sm font-medium text-gray-700">
                Memory Allocation: {formData.memory} MB
              </label>
              <p class="text-xs text-gray-500 mt-1">
                Allocate more memory for larger worlds or more plugins
              </p>
            </div>
            
            <div class="py-2">
              <Range 
                id="memory"
                min="512"
                max="8192"
                step="512"
                bind:value={formData.memory}
              />
            </div>
            
            <div class="flex justify-between text-xs text-gray-500 mt-1">
              <span>512 MB</span>
              <span>8 GB</span>
            </div>
          </div>
        </Card>
        
        <div class="flex justify-end space-x-4">
          <Button 
            href="/"
            variant="outline"
            disabled={submitting}
          >
            Cancel
          </Button>
          
          <Button
            type="submit"
            primary
            loading={submitting}
            loadingText="Creating Server..."
          >
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
            </svg>
            Create Server
          </Button>
        </div>
      </form>
    {/if}
  </div>
</div>

<style>
  .pulse-loader {
    width: 50px;
    height: 50px;
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