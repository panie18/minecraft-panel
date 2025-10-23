<script>
  import { theme } from '../../theme';
  
  export let type = 'button';
  export let href = null;
  export let size = 'md';
  export let variant = 'default';
  export let primary = false;
  export let secondary = false;
  export let danger = false;
  export let disabled = false;
  export let loading = false;
  export let loadingText = 'Loading...';
  export let icon = null;
  export let fullWidth = false;
  
  // Determine button style based on props
  let buttonClass;
  
  $: {
    // Default button styles
    let baseClass = 'inline-flex items-center justify-center font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2';
    
    // Size classes
    const sizeClass = {
      'xs': 'text-xs px-2 py-1 rounded',
      'sm': 'text-sm px-3 py-1.5 rounded',
      'md': 'text-sm px-4 py-2 rounded-md',
      'lg': 'text-base px-6 py-3 rounded-lg',
      'xl': 'text-lg px-8 py-4 rounded-lg'
    }[size] || 'text-sm px-4 py-2 rounded-md';
    
    // Variant and color classes
    let variantClass = '';
    
    if (primary) {
      variantClass = 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500';
    } else if (secondary) {
      variantClass = 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500';
    } else if (danger) {
      variantClass = 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500';
    } else {
      switch(variant) {
        case 'primary':
          variantClass = 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500';
          break;
        case 'secondary':
          variantClass = 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500';
          break;
        case 'danger':
          variantClass = 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500';
          break;
        case 'outline':
          variantClass = 'border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 focus:ring-blue-500';
          break;
        case 'ghost':
          variantClass = 'text-gray-600 hover:bg-gray-100 focus:ring-gray-500';
          break;
        case 'link':
          variantClass = 'text-blue-600 hover:text-blue-800 underline focus:ring-blue-500';
          break;
        default:
          variantClass = 'bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500';
      }
    }
    
    // Disabled state
    if (disabled || loading) {
      variantClass = 'bg-gray-300 text-gray-500 cursor-not-allowed';
    }
    
    // Width class
    const widthClass = fullWidth ? 'w-full' : '';
    
    buttonClass = `${baseClass} ${sizeClass} ${variantClass} ${widthClass}`;
  }
</script>

{#if href && !disabled}
  <a {href} class={buttonClass} on:click>
    {#if loading}
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      {loadingText}
    {:else if icon}
      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        {#if icon === 'plus'}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
        {:else if icon === 'download'}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
        {:else if icon === 'refresh'}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
        {:else}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{icon}"></path>
        {/if}
      </svg>
      <slot></slot>
    {:else}
      <slot></slot>
    {/if}
  </a>
{:else}
  <button
    {type}
    class={buttonClass}
    disabled={disabled || loading}
    on:click
  >
    {#if loading}
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      {loadingText}
    {:else if icon}
      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        {#if icon === 'plus'}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
        {:else if icon === 'download'}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
        {:else if icon === 'refresh'}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
        {:else}
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{icon}"></path>
        {/if}
      </svg>
      <slot></slot>
    {:else}
      <slot></slot>
    {/if}
  </button>
{/if}