<script>
  import { theme } from './theme';
  import { navigating } from '$app/stores';
  import { fade, fly } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
</script>

<div class="app bg-gray-50 min-h-screen flex flex-col">
  <!-- Modern header with subtle gradient -->
  <header 
    class="bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-md" 
    style="border-bottom-left-radius: {theme.radius.lg}; border-bottom-right-radius: {theme.radius.lg};">
    <div class="container mx-auto px-4 py-4 flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
          <!-- Minecraft cube logo with subtle animation -->
          <div class="minecraft-cube"></div>
        </div>
        <div>
          <h1 class="text-xl font-bold">Minecraft Panel</h1>
          <p class="text-xs text-blue-100">Manage your servers with style</p>
        </div>
      </div>
      
      <nav>
        <ul class="flex space-x-6">
          <li><a href="/" class="nav-link">Dashboard</a></li>
          <li><a href="/servers" class="nav-link">Servers</a></li>
          <li><a href="/plugins" class="nav-link">Plugins</a></li>
          <li><a href="/backups" class="nav-link">Backups</a></li>
          <li><a href="/settings" class="nav-link">Settings</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <!-- Page content with animation -->
  <main class="flex-grow container mx-auto px-4 py-6">
    {#if $navigating}
      <div class="flex justify-center items-center py-20">
        <div class="spinner"></div>
      </div>
    {:else}
      <div in:fade={{ duration: 300, easing: cubicOut }}>
        <slot></slot>
      </div>
    {/if}
  </main>

  <!-- Modern footer with attribution -->
  <footer class="bg-gray-800 text-gray-300 py-6 mt-auto" style="border-top-left-radius: {theme.radius.lg}; border-top-right-radius: {theme.radius.lg};">
    <div class="container mx-auto px-4">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <p class="mb-4 md:mb-0">© {new Date().getFullYear()} Minecraft Panel</p>
        
        <div class="flex items-center">
          <span class="text-sm">Made with</span>
          <span class="mx-1 text-red-500">❤️</span>
          <span class="text-sm">by <span class="font-semibold text-white">Pauli</span></span>
        </div>
      </div>
    </div>
  </footer>
</div>

<style>
  /* Modern nav links with hover effect */
  .nav-link {
    position: relative;
    color: rgba(255, 255, 255, 0.8);
    font-weight: 500;
    padding: 0.5rem 0;
    transition: color 0.2s ease;
  }
  
  .nav-link:hover {
    color: white;
  }
  
  .nav-link::after {
    content: '';
    position: absolute;
    width: 0;
    height: 2px;
    bottom: 0;
    left: 0;
    background-color: white;
    transition: width 0.3s ease;
  }
  
  .nav-link:hover::after {
    width: 100%;
  }
  
  /* Spinning cube animation */
  .minecraft-cube {
    width: 24px;
    height: 24px;
    background-color: #5BBD53;
    animation: cube-rotate 8s infinite linear;
    transform-style: preserve-3d;
  }
  
  @keyframes cube-rotate {
    0% { transform: rotateX(0) rotateY(0); }
    100% { transform: rotateX(360deg) rotateY(360deg); }
  }
  
  /* Loading spinner */
  .spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(59, 130, 246, 0.2);
    border-radius: 50%;
    border-top-color: #3B82F6;
    animation: spin 1s ease-in-out infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>