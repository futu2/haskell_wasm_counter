import {WASI} from "@runno/wasi";
import ghc_wasm_jsffi from "./ghc_wasm_jsffi.js";
import final_wasm from "./final.wasm"

const wasi = new WASI({
    stdout: (out) => console.log("[wasm stdout]", out)
});

const jsffiExports = {};
const wasm = await WebAssembly.instantiateStreaming(
    fetch(final_wasm),
    Object.assign(
        { ghc_wasm_jsffi: ghc_wasm_jsffi(jsffiExports) },
        wasi.getImportObject()
    )
);
Object.assign(jsffiExports, wasm.instance.exports);

wasi.initialize(wasm, {
    ghc_wasm_jsffi: ghc_wasm_jsffi(jsffiExports)
});

wasi.instance.exports.setup();
