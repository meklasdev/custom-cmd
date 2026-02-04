module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 14,
    fontFamily: '"CaskaydiaCove Nerd Font", Menlo, "DejaVu Sans Mono", Consolas, "Lucida Console", monospace',
    fontWeight: 'bold',
    fontWeightBold: 'bold',
    lineHeight: 1,
    letterSpacing: 0,
    cursorColor: 'rgba(248,28,229,0.8)',
    cursorAccentColor: '#000',
    cursorShape: 'BLOCK',
    cursorBlink: true,
    foregroundColor: '#fff',
    backgroundColor: '#000',
    selectionColor: 'rgba(248,28,229,0.3)',
    borderColor: '#333',
    css: `
      .hyper_main {
        border: 2px solid transparent;
        background-image: linear-gradient(#000, #000), linear-gradient(45deg, #f0f, #0ff, #f0f);
        background-origin: border-box;
        background-clip: content-box, border-box;
        box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
        animation: glow 3s infinite alternate;
      }
      
      @keyframes glow {
        from {
          box-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
        }
        to {
          box-shadow: 0 0 30px rgba(255, 0, 255, 0.8), 0 0 10px rgba(0, 255, 255, 0.8);
        }
      }
      
      .tab_tab {
        border-bottom: 2px solid #333;
      }
      
      .tab_active {
        border-bottom: 2px solid #0ff !important;
        color: #0ff !important;
      }
    `,
    termCSS: '',
    showHamburgerMenu: '',
    showWindowControls: '',
    padding: '12px 14px',
    colors: {
      black: '#000000',
      red: '#C51E14',
      green: '#1DC121',
      yellow: '#C7C329',
      blue: '#0A2FC4',
      magenta: '#C839C5',
      cyan: '#20C5C6',
      white: '#C7C7C7',
      lightBlack: '#686868',
      lightRed: '#FD6F6B',
      lightGreen: '#67F86F',
      lightYellow: '#FFFA72',
      lightBlue: '#6A76FB',
      lightMagenta: '#FD7CFC',
      lightCyan: '#68FDFE',
      lightWhite: '#FFFFFF',
    },
    shell: 'pwsh.exe', // PowerShell by default
    shellArgs: ['--nologo'],
    env: {},
    bell: 'SOUND',
    copyOnSelect: false,
    defaultSSHApp: true,
    quickEdit: false,
    macOptionSelectionMode: 'vertical',
    webGLRenderer: true,
    webLinksActivationKey: 'ctrl',
    disableLigatures: true,
    disableAutoUpdates: false,
    screenReaderMode: false,
    preserveCWD: true,
  },
  plugins: [],
  localPlugins: [],
  keymaps: {
  },
};
