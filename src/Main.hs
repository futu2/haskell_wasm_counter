module Main where

import Putus
import Data.Foldable
import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent

main :: IO ()
main = undefined

foreign export javascript "setup" setup :: IO ()

setup :: IO ()
setup = do
  putStrLn "start wasm!"
  runApp "app" $ do
    header_ $ do
      class_ "container"
      hgroup_ $ do
        h1_ $ text_ "GHC Wasm"
        p_ $ text_ "using jsffi to manipulate dom"
    main_ $ do
      class_ "container"
      section_ $ counterApp

counterApp :: AppM m => m ()
counterApp = withSignal (0 :: Int) $ \counterSignal -> withSignal False $ \timerRun -> do
    liftIO $ void $ forkIO $ forever $ do
      threadDelay 1000000
      tb <- readSignal timerRun
      when tb $ updateSignal counterSignal (\x -> if x == 99 then 0 else x + 1)

    h2_ $ do
      text_ "Counter App"

    p_ $ text_ "a simple counter that works"

    p_ $ do
      class_ "grid"
      button_ $ do
        text_ "0"
        onClick counterSignal (const 0)
        
      button_ $ do
        text_ "+"
        onClick counterSignal (\x -> if x == 99 then 0 else x + 1)

      button_ $ do
        text_ "-"
        onClick counterSignal (\x -> if x == 0 then 99 else x - 1)

    div_ $ do
      class_ "grid"
      p_ $ text_ "switch on for auto count"
      input_ $ do
        type_ "checkbox"
        role_ "switch"
        onChange timerRun (\e -> const e)

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
