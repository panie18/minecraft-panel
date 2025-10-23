<script>
  import { theme } from '$lib/theme';
  import { navigating } from '$app/stores';
  import { fade, fly } from 'svelte/transition';
  import { cubicInOut } from 'svelte/easing';
  import { Toaster } from 'svelte-french-toast';
  import '@huntabyte/bits-ui/styles/bits-ui.css';
  import '../app.css';
</script>

<div class="app min-h-screen flex flex-col" style="background-color: {theme.colors.background};">
  <!-- Modern header with subtle beige gradient -->
  <header 
    class="shadow-soft transition-all duration-300"
    style="
      background: linear-gradient(to right, {theme.colors.secondary}, {theme.colors.primary});
      border-bottom-left-radius: {theme.radius.lg}; 
      border-bottom-right-radius: {theme.radius.lg};
    "
  >
    <div class="container mx-auto px-4 py-4 flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-12 h-12 bg-white rounded-lg flex items-center justify-center shadow-sm">
          <!-- Minecraft cube logo with subtle animation -->
          <div class="minecraft-cube"></div>
        </div>
        <div>
          <h1 class="text-xl font-bold" style="color: {theme.colors.text.primary};">
            Minecraft Panel
          </h1>
          <p class="text-xs" style="color: {theme.colors.text.secondary};">
            Manage your servers with style
          </p>
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

  <!-- Page content with smooth animation -->
  <main class="flex-grow container mx-auto px-4 py-6">
    {#if $navigating}
      <div class="flex justify-center items-center py-20">
        <div class="spinner"></div>
      </div>
    {:else}
      <div in:fade={{ duration: 400, easing: cubicInOut, delay: 100 }}>
        <slot></slot>
      </div>
    {/if}
  </main>

  <!-- Modern footer with attribution -->
  <footer style="
    background-color: {theme.colors.primary}; 
    border-top-left-radius: {theme.radius.lg}; 
    border-top-right-radius: {theme.radius.lg};
  ">
    <div class="container mx-auto px-4 py-6">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <p class="mb-4 md:mb-0" style="color: {theme.colors.text.light};">
          © {new Date().getFullYear()} Minecraft Panel
        </p>
        
        <div class="flex items-center">
          <span class="text-sm" style="color: {theme.colors.text.light};">Made with</span>
          <span class="mx-1 text-red-500">❤️</span>
          <span class="text-sm font-semibold" style="color: {theme.colors.text.light};">by Pauli</span>
        </div>
      </div>
    </div>
  </footer>

  <!-- Toast notifications -->
  <Toaster position="bottom-right" />
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
    width: 28px;
    height: 28px;
    background-color: #B6AB97;
    animation: cube-rotate 12s infinite cubic-bezier(0.4, 0, 0.2, 1);
    transform-style: preserve-3d;
  }
  
  @keyframes cube-rotate {
    0% { transform: rotateX(0) rotateY(0); }
    50% { transform: rotateX(180deg) rotateY(180deg); }
    100% { transform: rotateX(360deg) rotateY(360deg); }
  }
  
  /* Loading spinner */
  .spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(182, 171, 151, 0.2);
    border-radius: 50%;
    border-top-color: #B6AB97;
    animation: spin 1.2s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>