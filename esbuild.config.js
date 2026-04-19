const esbuild = require('esbuild')

// Check if we're in watch mode
const watchMode = process.argv.includes('--watch')

// Common build options
const buildOptions = {
  bundle: true,
  sourcemap: true,
  loader: { '.js': 'jsx' },
  format: 'iife',
  plugins: []
}

// Function to handle builds
async function build() {
  let ctx = {}
  
  try {
    if (watchMode) {
      // Admin bundle with watch context
      ctx.admin = await esbuild.context({
        ...buildOptions,
        entryPoints: ['app/javascript/admin/index.js'],
        outfile: 'app/assets/builds/admin.js',
      })

      // Public bundle with watch context
      ctx.public = await esbuild.context({
        ...buildOptions,
        entryPoints: ['app/javascript/public/index.js'],
        outfile: 'app/assets/builds/public.js',
      })

      // Start watching
      await Promise.all([
        ctx.admin.watch(),
        ctx.public.watch()
      ])
      console.log('Watching for changes...')
    } else {
      // One-time builds
      await Promise.all([
        esbuild.build({
          ...buildOptions,
          entryPoints: ['app/javascript/admin/index.js'],
          outfile: 'app/assets/builds/admin.js',
        }),
        esbuild.build({
          ...buildOptions,
          entryPoints: ['app/javascript/public/index.js'],
          outfile: 'app/assets/builds/public.js',
        })
      ])
      console.log('Build complete')
    }
  } catch (error) {
    console.error('Build failed:', error)
    process.exit(1)
  }
}

build()
