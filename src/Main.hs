module Main where

import Putus
import Data.Foldable
import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent
import Control.Arrow

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
      section_ $ todoApp

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
        onChangeChecked timerRun (\e -> const e)

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

type TodoList = [(String, Bool)]

todoApp :: AppM m => m ()
todoApp = withSignal ([] :: TodoList)  $ \ todolist -> do
  h2_ $ text_ "Todo List"
  p_ $ text_ "what u wanna add"
  withSignal "" $ \newTodoContent -> do
    input_ $ do
      type_ "text"
      onInput newTodoContent const
    reactSignal newTodoContent $ \ t -> do
      button_ $ do
        text_ $ "add new todo: " <> show t
        onClick todolist (<> [(t, False)])
  reactSignal todolist $ \tds -> do
    ul_ $ do
      for_ (zip [0..] tds) $ \(num, (t,tb)) -> do
        li_ $ do
          p_ $ text_ $ show num
          input_ $ do
            type_ "checkbox"
            when tb $ setAttribute "checked" ""
            onChangeChecked todolist $ \b -> updateNth num (second $ const b)
          button_ $ do
            text_ "x"
            onClick todolist (removeNth num)
          p_ $ text_ t
          p_ $ text_ (show tb)

updateNth :: Int -> (a -> a) -> [a] -> [a]
updateNth _ _ [] = []
updateNth n f xs
  | n < 0     = xs
  | otherwise = go n xs
  where
    go 0 (y:rest) = f y : rest
    go i (y:rest) = y : go (i-1) rest
    go _ []       = []   -- index beyond list length

removeNth :: Int -> [a] -> [a]
removeNth _ [] = []
removeNth n xs
  | n < 0     = xs
  | otherwise = go n xs
  where
    go 0 (_:rest) = rest
    go i (y:rest) = y : go (i-1) rest
    go _ []       = []   -- index beyond list length
