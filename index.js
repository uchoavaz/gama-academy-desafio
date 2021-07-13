const hapi = require('@hapi/hapi')
const pino = require('hapi-pino')

const init = async (port) => {
  const server = hapi.server({ port })

  server.route({
    method: 'GET',
    path: '/',
    handler: () => ({ date: new Date() })
  })

  await server.register({
    plugin: pino,
    options: {
      prettyPrint: process.env.NODE_ENV !== 'production'
    }
  })

  await server.start()

  console.info(`Server running on port ${port}`)
}

init(process.env.PORT || 3000)
