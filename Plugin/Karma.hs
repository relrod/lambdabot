--
-- | Karma
--
module Plugin.Karma (theModule) where

import Plugin
import qualified IRC
import qualified Data.Map as M

PLUGIN Karma

type KarmaState = M.Map String Integer
type Karma m a = ModuleT KarmaState m a

instance Module KarmaModule KarmaState where

    moduleCmds _ = ["karma", "karma+", "karma-"]
    moduleHelp _ "karma"  = "karma <nick>. Return a person's karma value"
    moduleHelp _ "karma+" = "karma+ <nick>. Increment someone's karma"
    moduleHelp _ "karma-" = "karma- <nick>. Decrement someone's karma"

    moduleDefState  _ = return $ M.empty
    moduleSerialize _ = Just mapSerial

    process      _ msg _ cmd rest =
        case words rest of
          []       -> tellKarma sender sender
          (nick:_) -> do
              case cmd of
                 "karma"  -> tellKarma        sender nick
                 "karma+" -> changeKarma 1    sender nick
                 "karma-" -> changeKarma (-1) sender nick
                 _        -> error "KarmaModule: can't happen"
        where sender = IRC.nick msg

------------------------------------------------------------------------

getKarma :: String -> KarmaState -> Integer
getKarma nick karmaFM = fromMaybe 0 (M.lookup nick karmaFM)

tellKarma :: String -> String -> Karma LB [String]
tellKarma sender nick = do
    karma <- getKarma nick `fmap` readMS
    return [concat [if sender == nick then "You have" else nick ++ " has"
                   ," a karma of "
                   ,show karma]]

changeKarma :: Integer -> String -> String -> Karma LB [String]
changeKarma km sender nick
  | sender == nick = return ["You can't change your own karma, silly."]
  | otherwise      = withMS $ \fm write -> do
      let fm' = M.insertWith (+) nick km fm
      let karma = getKarma nick fm'
      write fm'
      return [fmt nick km (show karma)]
          where fmt n v k | v < 0     = n ++ "'s karma lowered to " ++ k ++ "."
                          | otherwise = n ++ "'s karma raised to " ++ k ++ "."
