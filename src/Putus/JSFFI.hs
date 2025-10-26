module Putus.JSFFI where

import GHC.Wasm.Prim

foreign import javascript unsafe "document.getElementById($1)"
  js_document_getElementById :: JSString -> IO JSVal

foreign import javascript unsafe "document.createElement($1)"
  js_document_createElement :: JSString -> IO JSVal

foreign import javascript unsafe "$1.textContent = $2"
  js_setTextContent :: JSVal -> JSString -> IO ()


foreign import javascript unsafe "$1.append($2)"
  js_append :: JSVal -> JSVal -> IO ()

foreign import javascript unsafe "$1.target.value"
  js_event_target_value :: JSVal -> IO Double

foreign import javascript unsafe "$1.style.opacity = $2"
  js_setOpacity :: JSVal -> Double -> IO ()

foreign import javascript unsafe "$1.addEventListener($2, $3)"
  js_addEventListener :: JSVal -> JSString -> JSVal -> IO ()

foreign import javascript "wrapper"
  asEventListener :: (JSVal -> IO ()) -> IO JSVal

foreign import javascript unsafe "$1.setAttribute($2, $3);"
  js_setAttribute :: JSVal -> JSString -> JSString -> IO ()

