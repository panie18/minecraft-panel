// Minecraft Panel Color Theme - Beige Collection

export const theme = {
  colors: {
    primary: '#B6AB97',     // Beige-4
    secondary: '#D6CBB3',   // Beige-3
    accent: '#BCB8A7',      // Beige-5
    background: '#E4DCC9',  // Beige-2
    card: '#FFFFFF',
    text: {
      primary: '#5F5B51',   // Darker version of Beige-5
      secondary: '#948C7E', // Slightly darker version of Beige-4
      light: '#E4DCC9',     // Beige-2
    },
    status: {
      online: '#7DAF9C',    // Soft green that complements beige
      offline: '#BCB8A7',   // Beige-5
      starting: '#E6C384',  // Soft amber that complements beige
      stopping: '#D79B8C',  // Soft red that complements beige
      error: '#C96567',     // Bright red that complements beige
    }
  },
  radius: {
    sm: '0.375rem',
    md: '0.5rem',
    lg: '0.75rem',
    xl: '1rem',
    full: '9999px',
  },
  animation: {
    duration: '400ms',
    easing: 'cubic-bezier(0.4, 0, 0.2, 1)',
    transition: 'all 400ms cubic-bezier(0.4, 0, 0.2, 1)',
  }
}