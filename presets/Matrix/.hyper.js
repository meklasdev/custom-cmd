module.exports = {
  config: {
    fontSize: 14,
    fontFamily: '"Courier New", Consolas, monospace',
    cursorColor: '#00FF00',
    cursorShape: 'BLOCK',
    foregroundColor: '#00FF00',
    backgroundColor: '#000000',
    borderColor: '#00FF00',
    css: `
      .hyper_main {
        border: 2px solid #00FF00;
        box-shadow: 0 0 15px rgba(0, 255, 0, 0.4);
      }
      .term_fit:after {
        content: "";
        position: absolute;
        top: 0; left: 0; width: 100vw; height: 100vh;
        background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));
        background-size: 100% 2px, 3px 100%;
        pointer-events: none;
      }
    `,
    plugins: ['hyper-power-mode'],
    overview: {
        'hyper-power-mode': {
            "shake": false,
            "particles": true
        }
    }
  }
};
