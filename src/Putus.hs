module Putus where

import Control.Monad
import Control.Concurrent
import GHC.Wasm.Prim
import Data.Foldable
import Control.Monad.Reader
import Control.Monad.IO.Unlift (MonadUnliftIO, withRunInIO)

import Putus.JSFFI

data Config = Config {rootElement :: JSVal}

type AppM m = (MonadReader Config m, MonadIO m, MonadUnliftIO m)

forkApp :: (MonadUnliftIO m) => m () -> m ThreadId
forkApp m = withRunInIO $ \run -> forkIO $ run m

withSignal :: AppM m => a -> (((a -> m ()) -> m (), (a -> a) -> IO ()) -> m ()) -> m ()
withSignal initValue inner = do
  sigValue <- liftIO $ newMVar initValue
  sig <- liftIO $ newChan
  handlers :: MVar [a -> m ()] <- liftIO $ newMVar []

  _ <- forkApp $ forever $ do
    c <- liftIO $ readChan sig
    v0 <- liftIO $ takeMVar sigValue
    let v1 = c v0
    liftIO $ putMVar sigValue v1
    fs <- liftIO $ readMVar handlers
    for_ fs (\f -> (f v1))

  inner 
    ( \h -> do
        config0 <- ask
        liftIO $ modifyMVar_ handlers (pure . ((\a0 -> local (const config0) (h a0)) :)) 
    , writeChan sig
    )

  fs0 <- liftIO $ readMVar handlers
  v00 <- liftIO $ readMVar sigValue
  for_ fs0 (\f -> (f v00))

runApp :: String -> ReaderT Config IO () -> IO ()
runApp rootId mainApp = void $ do
  appRoot <- getElementById rootId
  runReaderT mainApp (Config appRoot)

el :: AppM m => String -> m () -> m ()
el tag child = do
  newElement <- createElement tag
  root <- asks rootElement
  -- liftIO $ putStrLn tag
  -- liftIO $ debug root
  local (\ x -> x {rootElement = newElement}) child
  append root newElement


getElementById :: MonadIO m => String -> m JSVal
getElementById = liftIO . js_document_getElementById . toJSString 

setTextContent :: AppM m => String -> m ()
setTextContent textContent = do
  root <- asks rootElement
  liftIO $ js_setTextContent root (toJSString textContent)

append :: (MonadIO m) => JSVal -> JSVal -> m ()
append r child = liftIO $ js_append r child

createElement :: MonadIO m => String -> m JSVal
createElement = liftIO . js_document_createElement . toJSString 

addEventListener :: AppM m => String -> (JSVal -> IO ()) -> m ()
addEventListener eventName eventListener = do
  root <- asks rootElement
  liftIO $ do
    callback <- asEventListener eventListener
    js_addEventListener root (toJSString eventName) callback



setAttribute :: AppM m => String -> String -> m ()
setAttribute attributeName attributeValue = do
  root <- asks rootElement
  liftIO $ js_setAttribute root (toJSString attributeName) (toJSString attributeValue)

-- foreign import javascript unsafe "console.log($1);"
--   debug :: JSVal -> IO ()
