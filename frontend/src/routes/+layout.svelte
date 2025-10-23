<script lang="ts">
  import '../app.postcss';
  import { Toaster } from 'svelte-sonner';
  import { fade } from 'svelte/transition';
  
  // Komponenten importieren
  import { Button } from '$lib/components/ui/button';
</script>

<div class="min-h-screen bg-beige-100 font-satoshi flex flex-col">
  <!-- Header -->
  <header class="bg-gradient-to-r from-beige-300 to-beige-500 shadow-md">
    <div class="container mx-auto px-4 py-4 flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
          <!-- Minecraft cube logo with subtle animation -->
          <div class="minecraft-cube"></div>
        </div>
        <div>
          <h1 class="text-xl font-bold text-beige-900">Minecraft Panel</h1>
          <p class="text-xs text-beige-700">Manage your servers with style</p>
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

  <!-- Main content -->
  <main class="flex-grow container mx-auto px-4 py-6">
    <div in:fade={{ duration: 300, delay: 100 }}>
      <slot />
    </div>
  </main>

  <!-- Footer -->
  <footer class="bg-beige-500 text-beige-50 py-6">
    <div class="container mx-auto px-4">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <p class="mb-4 md:mb-0">© {new Date().getFullYear()} Minecraft Panel</p>
        
        <div class="flex items-center">
          <span class="text-sm">Made with</span>
          <span class="mx-1 text-red-500">❤️</span>
          <span class="text-sm font-bold">by Pauli</span>
        </div>
      </div>
    </div>
  </footer>
  
  <Toaster richColors />
</div>

<style>
  /* Modern nav links with hover effect */
  .nav-link {
    position: relative;
    color: rgba(95, 91, 81, 0.8);
    font-weight: 500;
    padding: 0.5rem 0;
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .nav-link:hover {
    color: rgb(95, 91, 81);
  }
  
  .nav-link::after {
    content: '';
    position: absolute;
    width: 0;
    height: 2px;
    bottom: 0;
    left: 0;
    background-color: rgb(95, 91, 81);
    transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .nav-link:hover::after {
    width: 100%;
  }
  
  /* Spinning cube animation */
  .minecraft-cube {
    width: 24px;
    height: 24px;
    background-color: #B6AB97;
    animation: cube-rotate 12s infinite cubic-bezier(0.4, 0, 0.2, 1);
    transform-style: preserve-3d;
  }
  
  @keyframes cube-rotate {
    0% { transform: rotateX(0) rotateY(0); }
    50% { transform: rotateX(180deg) rotateY(180deg); }
    100% { transform: rotateX(360deg) rotateY(360deg); }
  }
</style>