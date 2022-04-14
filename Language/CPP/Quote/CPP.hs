module Language.CPP.Quote where

import qualified Language.CPP.Parser as P
import qualified Language.CPP.Syntax as CPP
import Language.CPP.Quote.Base (ToIdent(..), ToConst(..), ToExp(..), quasiquote)
import Language.Haskell.TH.Quote (QuasiQuoter)

exts :: [CPP.Extensions]
exts = []

typenames :: [String]
typenames = []