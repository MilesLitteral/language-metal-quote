-- |
-- Module      :  Language.C.Quote.Metal
-- Copyright   :  (c) 2022 Miles J. Litteral
-- License     :  BSD-style
-- Maintainer  :  mandaloe2@gmail.com

module Language.C.Quote.Metal (
    ToIdent(..),
    ToConst(..),
    ToExp(..),
    cexp,
    cedecl,
    cdecl,
    csdecl,
    cenum,
    ctyquals,
    cty,
    cparam,
    cparams,
    cinit,
    cstm,
    cstms,
    citem,
    citems,
    cunit,
    cfun
  ) where

import qualified Language.Metal.Parser as P
import qualified Language.Metal.Syntax as M
import Language.C.Quote.Base (ToIdent(..), ToConst(..), ToExp(..), quasiquote)
import Language.Haskell.TH.Quote (QuasiQuoter)

basicIncludes :: String
basicIncludes = "#include <metal_stdlib>\n using namespace metal\n"

exts :: [M.Extensions]
exts = [M.Metal]

typenames :: [String]
typenames =
    ["kernel", "device", "texture2d", "texture", "uint2", "access::read", "access::write",
     "half", "half4"] ++
    ["bool", "char", "uchar", "short", "ushort", "int", "uint",
     "long" , "ulong", "float", "half", "double"]
    ++ ["size_t", "ptrdiff_t", "intptr_t", "uintpyt_t", "void"]
    ++ concatMap typeN ["char", "uchar", "short", "ushort",
                        "int", "uint", "long", "ulong", "float"]
    ++ ["[[thread_position_in_grid]]"]

typeN :: String -> [String]
typeN typename = [typename ++ show n | n <- [2, 3, 4, 8, 16 :: Integer]]

cdecl, cedecl, cenum, cexp, cfun, cinit, cparam, cparams, csdecl, cstm, cstms :: QuasiQuoter
citem, citems, ctyquals, cty, cunit :: QuasiQuoter
cdecl    = quasiquote exts typenames P.parseDecl
cedecl   = quasiquote exts typenames P.parseEdecl
cenum    = quasiquote exts typenames P.parseEnum
cexp     = quasiquote exts typenames P.parseExp
cfun     = quasiquote exts typenames P.parseFunc
cinit    = quasiquote exts typenames P.parseInit
cparam   = quasiquote exts typenames P.parseParam
cparams  = quasiquote exts typenames P.parseParams
csdecl   = quasiquote exts typenames P.parseStructDecl
cstm     = quasiquote exts typenames P.parseStm
cstms    = quasiquote exts typenames P.parseStms
citem    = quasiquote exts typenames P.parseBlockItem
citems   = quasiquote exts typenames P.parseBlockItems
ctyquals = quasiquote exts typenames P.parseTypeQuals
cty      = quasiquote exts typenames P.parseType
cunit    = quasiquote exts typenames P.parseUnit
