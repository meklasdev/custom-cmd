module.exports = {
  config: {
    fontSize: 14,
    fontFamily: '"CaskaydiaCove Nerd Font", monospace',
    cursorColor: '#ff00ff',
    foregroundColor: '#fff',
    backgroundColor: '#2b213a',
    borderColor: '#ff00ff',
    css: `
      .hyper_main { border: 2px solid #ff00ff; }
    `,
    colors: {
      black: '#2b213a', red: '#ff5c57', green: '#5af78e', yellow: '#f3f99d',
      blue: '#57c7ff', magenta: '#ff6ac1', cyan: '#9aedfe', white: '#f1f1f0',
      lightBlack: '#686868', lightRed: '#ff5c57', lightGreen: '#5af78e', lightYellow: '#f3f99d',
      lightBlue: '#57c7ff', lightMagenta: '#ff6ac1', lightCyan: '#9aedfe', lightWhite: '#ffffff'
    }
  },
  plugins: ['hyper-power-mode'],
  hyperPowerMode: { "shake": false, "particles": true }
};
