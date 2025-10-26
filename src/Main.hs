module Main where

import Putus

main :: IO ()
main = undefined

foreign export javascript "setup" setup :: IO ()

setup :: IO ()
setup = do
  putStrLn "start wasm!"
  runApp "app" $ do
    el "h1" $ setTextContent "GHC Wasm"
    counterApp

counterApp :: AppM m => m ()
counterApp = withSignal (0 :: Int) $ \(withCounter, updateCounter) -> do
    el "h2" $ do
      setTextContent "Counter App"
      setAttribute "class" "text-2xl font-bold mb-4"

    let setButtonStyle = setAttribute "class" "btn btn-primary"
    el "button" $ do
      setTextContent "0"
      setButtonStyle
      addEventListener "click" (const $ updateCounter  (const 0))
      
    el "button" $ do
      setTextContent "+"
      setButtonStyle
      addEventListener "click" (const $ updateCounter (\x -> if x == 99 then 0 else x + 1))

    el "button" $ do
      setTextContent "-"
      setButtonStyle
      addEventListener "click" (const $ updateCounter (\x -> if x == 0 then 99 else x - 1))

    el "span" $ do
      el "h1" $ do
        withCounter $ \n -> setTextContent (show n)

      el "h1" $ do
        withCounter $ \n -> setTextContent (show (n * 8) <> "!")
