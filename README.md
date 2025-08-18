# Haskell WASM Counter

A simple single page application using wasm build from ghc.

Follow ideas from [tutorial](https://finley.dev/blog/2024-08-24-ghc-wasm.html)

## Note

### Build Steps

```bash
# where final wasm file locates
wasm_file_path="$(wasm32-wasi-cabal list-bin .)"
# where ghc scripts locates
lib_path="$(wasm32-wasi-ghc --print-libdir)" 
# cabal build haskell project
wasm32-wasi-cabal build;
# post-link generated wasm file, generate jsffi.js
bun run "$lib_path/post-link.mjs" -i "$wasm_file_path" -o ghc_wasm_jsffi.js;
# copy wasm to root dir, for packing
cp "$wasm_file_path" ./final.wasm
# pack page
bun build --outdir dist index.html
```

## How to use

### Build
```bash
# cd to root dir
bun install
sh build.sh
```
Then the generated page files is in `dist` dir.

### Dev

monitor haskell source
```
sh watch.sh
```

serve the dist to local port
```
live-server dist --hard
```
