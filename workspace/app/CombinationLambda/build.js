const esbuild = require('esbuild');
const esbuildPluginTsc = require('esbuild-plugin-tsc');

const settings = {
  entryPoints: ['src/main.ts'],
  outfile: 'build/bundle.js',
  bundle: true,
  plugins: [
    esbuildPluginTsc({
      force: true,
      tsconfigPath: './tsconfig.build.json',
    }),
  ],
  minify: true,
  platform: 'node',
  target: 'node16.19',
};

esbuild.build(settings).then(() => console.log('Bundle complete'));
