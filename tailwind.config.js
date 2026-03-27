/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#060a14',
          900: '#0a0f1e',
          800: '#0d1526',
          700: '#111d34',
          600: '#162340',
        },
        gold: {
          300: '#f0d060',
          400: '#e6c84a',
          500: '#c9a227',
          600: '#a8841e',
          700: '#876818',
        },
        slate: {
          850: '#1a2133',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Georgia', 'serif'],
      },
      backgroundImage: {
        'gold-gradient': 'linear-gradient(135deg, #c9a227 0%, #e6c84a 50%, #c9a227 100%)',
        'dark-gradient': 'linear-gradient(180deg, #060a14 0%, #0a0f1e 100%)',
        'card-gradient': 'linear-gradient(135deg, rgba(13,21,38,0.9) 0%, rgba(10,15,30,0.95) 100%)',
      },
      animation: {
        'pulse-gold': 'pulseGold 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.4s ease-out',
      },
      keyframes: {
        pulseGold: {
          '0%, 100%': { opacity: 1 },
          '50%': { opacity: 0.5 },
        },
        fadeIn: {
          '0%': { opacity: 0 },
          '100%': { opacity: 1 },
        },
        slideUp: {
          '0%': { opacity: 0, transform: 'translateY(20px)' },
          '100%': { opacity: 1, transform: 'translateY(0)' },
        },
      },
      boxShadow: {
        gold: '0 0 20px rgba(201, 162, 39, 0.15)',
        'gold-lg': '0 0 40px rgba(201, 162, 39, 0.2)',
        card: '0 4px 24px rgba(0, 0, 0, 0.4)',
      },
    },
  },
  plugins: [],
}
