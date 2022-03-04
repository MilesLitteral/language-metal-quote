{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_language_c_quote (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,13] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/manifold7/.cabal/bin"
libdir     = "/home/manifold7/.cabal/lib/x86_64-linux-ghc-8.10.7/language-c-quote-0.13-inplace"
dynlibdir  = "/home/manifold7/.cabal/lib/x86_64-linux-ghc-8.10.7"
datadir    = "/home/manifold7/.cabal/share/x86_64-linux-ghc-8.10.7/language-c-quote-0.13"
libexecdir = "/home/manifold7/.cabal/libexec/x86_64-linux-ghc-8.10.7/language-c-quote-0.13"
sysconfdir = "/home/manifold7/.cabal/etc"

getBinDir     = catchIO (getEnv "language_c_quote_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "language_c_quote_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "language_c_quote_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "language_c_quote_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "language_c_quote_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "language_c_quote_sysconfdir") (\_ -> return sysconfdir)




joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
