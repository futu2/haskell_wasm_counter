module Main where

import Control.Concurrent
import GHC.Wasm.Prim
import Data.Function

import Control.Event.Handler
import Reactive.Banana
import Reactive.Banana.Frameworks

main :: IO ()
main = undefined

foreign export javascript "setup" setup :: IO ()

setup :: IO ()
setup = do
  putStrLn "start wasm!"
  appRoot <- getElementById "app"
  appRoot & setTextContent ""

  (addHandlerCounter, fireCounter) <- newAddHandler
  counterDisplay <- createElement "span"
  -- counterDisplay & setAttribute "class" "text-xl font-bold mb-4"
  counterDisplay & setAttribute "aria-live" "polite"
  -- counterDisplay & setAttribute "aria-lable" "59"
  let updateCounter n = do
        counterDisplay & setAttribute "style" ("--value:" <> show n <> ";")
        counterDisplay & setTextContent (show n)
        counterDisplay & setAttribute "aria-lable" (show n)
  updateCounter 0


  heading <- createElement "h2"
  heading & setTextContent "Counter App"
  heading & setAttribute "class" "text-2xl font-bold mb-4"
  heading & append appRoot

  let setButtonStyle = setAttribute "class" "btn btn-primary"
  b0 <- createElement "button"
  b0 & setTextContent "0"
  b0 & setButtonStyle
  b0 & append appRoot
  b0 & addEventListener "click" (const $ fireCounter (const 0))

  b1 <- createElement "button"
  b1 & setTextContent "+"
  b1 & setButtonStyle
  b1 & append appRoot
  b1 & addEventListener "click" (const $ fireCounter (\x -> if x == 99 then 0 else x + 1))

  b2 <- createElement "div"
  b2 & setTextContent "-"
  b2 & setButtonStyle
  b2 & append appRoot
  b2 & addEventListener "click" (const $ fireCounter (\x -> if x == 0 then 99 else x - 1))

  counterFrame <- createElement "span"
  counterFrame & setAttribute "class" "countdown text-xl font-bold mb-4"
  counterFrame & append appRoot
  counterDisplay & append counterFrame

  network <- compile $ do
    counterEvent <- fromAddHandler addHandlerCounter
    eCount <- accumE 0 counterEvent  -- Start at 0, update with eChange

    reactimate $ putStrLn . ("Current count: " ++) . show <$> eCount
    reactimate $ updateCounter <$> eCount

  actuate network

foreign import javascript unsafe "document.getElementById($1)"
  js_document_getElementById :: JSString -> IO JSVal

getElementById :: String -> IO JSVal
getElementById = js_document_getElementById . toJSString 

foreign import javascript unsafe "document.createElement($1)"
  js_document_createElement :: JSString -> IO JSVal

createElement :: String -> IO JSVal
createElement = js_document_createElement . toJSString 

foreign import javascript unsafe "$1.textContent = $2"
  js_setTextContent :: JSVal -> JSString -> IO ()

setTextContent :: String -> JSVal -> IO ()
setTextContent textContent element = js_setTextContent element (toJSString textContent)

foreign import javascript unsafe "$1.append($2)"
  append :: JSVal -> JSVal -> IO ()

foreign import javascript unsafe "$1.target.value"
  js_event_target_value :: JSVal -> IO Double

foreign import javascript unsafe "$1.style.opacity = $2"
  js_setOpacity :: JSVal -> Double -> IO ()

foreign import javascript unsafe "$1.addEventListener($2, $3)"
  js_addEventListener :: JSVal -> JSString -> JSVal -> IO ()

foreign import javascript "wrapper"
  asEventListener :: (JSVal -> IO ()) -> IO JSVal

addEventListener :: String -> (JSVal -> IO ()) -> JSVal -> IO ()
addEventListener eventName eventListener element = do
  callback <- asEventListener eventListener
  js_addEventListener element (toJSString eventName) callback

foreign import javascript unsafe "$1.setAttribute($2, $3);"
  js_setAttribute :: JSVal -> JSString -> JSString -> IO ()

setAttribute :: String -> String -> JSVal -> IO ()
setAttribute attributeName attributeValue element = js_setAttribute element (toJSString attributeName) (toJSString attributeValue)
