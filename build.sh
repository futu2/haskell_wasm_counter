wasm_file_path="$(wasm32-wasi-cabal list-bin .)"
lib_path="$(wasm32-wasi-ghc --print-libdir)" 
wasm32-wasi-cabal build;
bun run "$lib_path/post-link.mjs" -i "$wasm_file_path" -o ghc_wasm_jsffi.js;
cp "$wasm_file_path" ./final.wasm
bun build --outdir dist index.html
echo "build done"
