
module CmafiheModule where

import Posix
-- TODO migrate to System.Process

import System
import IRC
import Control.Monad.Trans

newtype CmafiheModule = CmafiheModule ()

theModule = MODULE cmafiheModule
cmafiheModule = CmafiheModule ()

type Word = String
type Translation = String

-- Extracts the first item of a triple.
fst3 :: (a, b, c) -> a
fst3 (a, _, _) = a

-- Looks up a word by passing it to `cmafihe'.
cmafihe      :: Word -> IO Translation
cmafihe word =  popen cmafihePath [] (Just word) >>= return . fst3
    where cmafihePath = "/usr/bin/cmafihe"

ircCmafihe :: Word -> IRC Translation
ircCmafihe = liftIO . cmafihe

instance Module CmafiheModule where
    moduleName _ = return "cmafihe"
    moduleSticky _ = False
    commands _ = return ["cmafihe"]

    process _ _ target _ []   = ircPrivmsg target "Nothing is universal."
    process _ _ target _ rest = ircCmafihe rest >>= ircPrivmsg target
