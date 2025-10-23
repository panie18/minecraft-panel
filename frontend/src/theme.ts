// Modern, clean theme configuration
export const theme = {
  colors: {
    primary: '#3B82F6',    // Clean blue
    secondary: '#10B981',  // Fresh green
    accent: '#8B5CF6',     // Soft purple
    background: '#F9FAFB', // Light gray background
    card: '#FFFFFF',       // White cards
    text: {
      primary: '#1F2937',  // Dark gray text
      secondary: '#6B7280', // Medium gray text
      light: '#F3F4F6',     // Light text for dark backgrounds
    },
    status: {
      online: '#10B981',    // Green
      offline: '#6B7280',   // Gray
      starting: '#F59E0B',  // Amber
      stopping: '#EF4444',  // Red
      error: '#DC2626',     // Bright red
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
    duration: '300ms',
    easing: 'cubic-bezier(0.4, 0, 0.2, 1)',
  }
}