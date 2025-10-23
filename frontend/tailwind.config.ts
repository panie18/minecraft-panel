import type { Config } from "tailwindcss";

export default {
  darkMode: ["class"],
  content: [
    "./src/**/*.{html,js,svelte,ts}",
    "./src/lib/components/**/*.{html,js,svelte,ts}"
  ],
  theme: {
    extend: {
      colors: {
        beige: {
          100: '#E4DCC9',
          200: '#D6D2C5',
          300: '#D6CBB3',
          400: '#BCB8A7',
          500: '#B6AB97',
          600: '#A39A87',
          700: '#8A8370',
          800: '#716C5C',
          900: '#5F5B51'
        }
      }
    }
  },
  plugins: []
} satisfies Config;