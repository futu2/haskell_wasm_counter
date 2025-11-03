module Main where

import Putus
import Data.Foldable
import Control.Monad

main :: IO ()
main = undefined

foreign export javascript "setup" setup :: IO ()

setup :: IO ()
setup = do
  putStrLn "start wasm!"
  runApp "app" $ do
    header_ $ do
      setAttribute "class" "container"
      hgroup_ $ do
        h1_ $ text_ "GHC Wasm"
        p_ $ text_ "using jsffi to manipulate dom"
    main_ $ do
      setAttribute "class" "container"
      section_ $ counterApp

counterApp :: AppM m => m ()
counterApp = withSignal (0 :: Int) $ \counterSignal -> do
    h2_ $ do
      text_ "Counter App"
      setAttribute "class" "text-2xl font-bold mb-4"

    p_ $ text_ "a simple counter that works"

    p_ $ do
      setAttribute "class" "grid"
      let setButtonStyle = setAttribute "class" "btn btn-primary"
      button_ $ do
        text_ "0"
        setButtonStyle
        onClick counterSignal (const 0)
        
      button_ $ do
        text_ "+"
        setButtonStyle
        onClick counterSignal (\x -> if x == 99 then 0 else x + 1)

      button_ $ do
        text_ "-"
        setButtonStyle
        onClick counterSignal (\x -> if x == 0 then 99 else x - 1)

    span_ $ do
      p_ $ do
        useSignal counterSignal $ \n -> text_ (show n)

      p_ $ do
        useSignal counterSignal $ \n -> text_ (show (n * 8) <> "!")

      progress_ $ do
        setAttribute "max" "100"
        useSignal counterSignal $ \n -> setAttribute "value" $ show n

    h2_ $ text_ "from 1 to x"
    reactSignal counterSignal $ \n -> do
        when (n > 2) $ ul_ $ do
          for_ [1..n] $ \x -> do
            li_ $ p_ $ text_ (show x)
