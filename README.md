# Haskell WASM Counter

A simple single page application using wasm build from ghc.

Follow ideas from [tutorial](https://finley.dev/blog/2024-08-24-ghc-wasm.html)

Demo: see [github page](https://futu2.github.io/haskell_wasm_counter/)

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

### Misc
init function name set to `setup`

## How to use

### Build
```bash
# cd to root dir
sh init.sh
sh build.sh
```
or using nix shell
```bash
# cd to root dir
nix develop --command sh init.sh
nix develop --command sh build.sh
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

### Optimize wasm size
```bash
wasm-opt -Oz -o $wasm_file_path $wasm_file_path
```
