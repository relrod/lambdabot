--
-- | Simple template module
--
module Plugins.Dummy (theModule) where

import IRC
import Plugins.Dummy.DocAssocs (docAssocs)
import Plugins.Dummy.Moo (cows)
import qualified Map as M

newtype DummyModule = DummyModule ()

theModule :: MODULE
theModule = MODULE $ DummyModule ()

instance Module DummyModule [String] where
  moduleDefState _ = return $ cycle cows

  moduleHelp _ s = return $ case s of
        "dummy"       -> "print a string constant"
        "wiki"        -> "wiki urls"
        "paste"       -> "paste page url"
        "docs"        -> "library documentation"
        "learn"       -> "another url"
        "eurohaskell" -> "urls are good"
        "moo"         -> "vegan-friendly command"
        _             -> "dummy module"

  moduleCmds   _ = return $ "moo" : map fst dummylst

  process _ _ src "moo" _ = do
        cow:farm <- readMS
        writeMS farm
        mapM_ (ircPrivmsg' src) (lines cow)

  process _ _ src cmd rest = case lookup cmd dummylst of
			       Nothing -> error "Dummy: invalid command"
                               Just f -> ircPrivmsg src $ f rest

dummylst :: [(String, String -> String)]
dummylst = [("dummy",       \_ -> "dummy"),
	    ("eurohaskell", \_ -> unlines ["less talks, more code!",
					   "http://www.haskell.org/hawiki/EuroHaskell",
					   "EuroHaskell - Haskell Hackfest - Summer 2005 ",
                                                "- Gothenburg, Sweden"]),
	    ("wiki",        \x -> "http://www.haskell.org/hawiki/" ++ x),
	    ("paste",       \_ -> "http://www.haskell.org/hawiki/HaskellIrcPastePage"),
            ("docs",        \x -> case M.lookup x docAssocs of
               Nothing -> x ++ " not available"
               Just m  -> "http://haskell.org/ghc/docs/latest/html/"++
                          "libraries/" ++ m ++ "/" ++ x ++ ".html"),
	    ("learn",       \_ -> "http://www.haskell.org/learning.html")]