module.exports = {
  config: {
    fontSize: 14,
    fontFamily: '"Consolas", monospace',
    cursorColor: '#00ff00',
    foregroundColor: '#00ff00',
    backgroundColor: '#000000',
    borderColor: '#00ff00',
    css: `
      .hyper_main { border: 1px solid #00ff00; }
    `,
    colors: {
      black: '#000000', red: '#00ff00', green: '#00ff00', yellow: '#00ff00',
      blue: '#00ff00', magenta: '#00ff00', cyan: '#00ff00', white: '#00ff00',
      lightBlack: '#003300', lightRed: '#00ff00', lightGreen: '#00ff00', lightYellow: '#00ff00',
      lightBlue: '#00ff00', lightMagenta: '#00ff00', lightCyan: '#00ff00', lightWhite: '#00ff00'
    }
  },
  plugins: ['hyper-power-mode'],
  hyperPowerMode: { "shake": false, "particles": true }
};
