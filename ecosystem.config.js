module.exports = {
  apps: [{
    name: 'organizadorjuridico',
    script: 'npm',
    args: 'run dev',
    cwd: '/home/flaviodev/projetos/next/Barros-Alves/organizadorjuridico',
    env: {
      NODE_ENV: 'development',
      PORT: 3000
    }
  }]
}
