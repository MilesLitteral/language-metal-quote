-- |
-- Module      :  Language.C.Quote
-- Copyright   :  (c) 2010-2011 Harvard University
--                (c) 2011-2013 Geoffrey Mainland
--             :  (c) 2013-2015 Drexel University
-- License     :  BSD-style
-- Maintainer  :  mainland@drexel.edu
--
-- There are five modules that provide quasiquoters, each for a different C
-- variant. 'Language.C.Quote.C' parses C99, 'Language.C.Quote.GCC' parses C99
-- plus GNU extensions, 'Language.C.Quote.CUDA' parses C99 plus GNU and CUDA
-- extensions, 'Language.C.Quote.OpenCL' parses C99 plus GNU and OpenCL
-- extensions and, 'Language.C.Quote.ObjC' parses C99 plus a subset of Objective-C
--
-- For version of GHC prior to 7.4, the quasiquoters generate Template Haskell
-- expressions that use data constructors that must be in scope where the
-- quasiquoted expression occurs. You will be safe if you add the following
-- imports to any module using the quasiquoters provided by this package:
--
-- > import qualified Data.Loc
-- > import qualified Language.C.Syntax
--
-- These modules may also be imported unqualified, of course. The quasiquoters
-- also use some constructors defined in the standard Prelude, so if it is not
-- imported by default, it must be imported qualified. On GHC 7.4 and above, you
-- can use the quasiquoters without worrying about what names are in scope.
--
-- The following quasiquoters are defined:
--
-- [@cdecl@] Declaration, of type @'InitGroup'@.
--
-- [@cedecl@] External declarations (top-level declarations in a C file,
-- including function definitions and declarations), of type @'Definition'@.
--
-- [@cenum@] Component of an @enum@ definition, of type @'CEnum'@.
--
-- [@cexp@] Expression, of type @'Exp'@.
--
-- [@cstm@] Statement, of type @'Stm'@.
--
-- [@cstms@] A list of statements, of type @['Stm']@.
--
-- [@citem@] Block item, of type @'BlockItem'@. A block item is either a
-- declaration or a statement.
--
-- [@citems@] A list of block items, of type @['BlockItem'].
--
-- [@cfun@] Function definition, of type @'Func'@.
--
-- [@cinit@] Initializer, of type @'Initializer'@.
--
-- [@cparam@] Declaration of a function parameter, of type @'Param'@.
--
-- [@cparams@] Declaration of function parameters, of type @['Param']@.
--
-- [@csdecl@] Declaration of a struct member, of type @'FieldGroup'@.
--
-- [@ctyquals@] A list of type qualifiers, of type @['TyQual']@.
--
-- [@cty@] A C type, of type @'Type'@.
--
-- [@cunit@] A compilation unit, of type @['Definition']@.
--
-- In addition, Objective-C support defines the following quasiquoters:
--
-- [@objcprop@] Property declaration of type @'ObjCIfaceDecl'@.
--
-- [@objcifdecls@] Interface declarations of type @['ObjCIfaceDecl']@
--
-- [@objcimdecls@] Class implementation declarations of type @['Definition']@
--
-- [@objcdictelem@] Dictionary element, of type @'ObjCDictElem'@
--
-- [@objcpropattr@] Property attribute element, of type @'ObjCPropAttr'@
--
-- [@objcmethparam@] Method parameter, of type @'ObjCParam'@
--
-- [@objcmethproto@] Method prototype, of type @'ObjCMethodProto'@
--
-- [@objcmethdef@] Method definition, of type @'Definition'@
--
-- [@objcrecv@] Receiver, of type @'ObjCRecv'@
--
-- [@objcarg@] Keyword argument, of type @'ObjCArg'@
--
--
-- Antiquotations allow splicing in subterms during quotation. These subterms
-- may bound to a Haskell variable or may be the value of a Haskell
-- expression. Antiquotations appear in a quasiquotation in the form
-- @$ANTI:VARID@, where @ANTI@ is a valid antiquote specifier and @VARID@ is a
-- Haskell variable identifier, or in the form @$ANTI:(EXP)@, where @EXP@ is a
-- Haskell expressions (the parentheses must appear in this case). The Haskell
-- expression may itself contain a quasiquote, but in that case the final @|]@
-- must be escaped as @\\|\\]@. Additionally, @$VARID@ is shorthand for
-- @$exp:VARID@ and @$(EXP)@ is shorthand for @$exp:(EXP)@, i.e., @exp@ is the
-- default antiquote specifier.
--
-- It is often useful to use typedefs that aren't in scope when quasiquoting,
-- e.g., @[cdecl|uint32_t foo;|]@. The quasiquoter will complain when it sees
-- this because it thinks @uint32_t@ is an identifier. The solution is to use
-- the @typename@ keyword, borrowed from C++, to tell the parser that the
-- identifier is actually a type name. That is, we can write @[cdecl|typename
-- uint32_t foo;|]@ to get the desired behavior.
--
-- Valid antiquote specifiers are:
--
-- [@id@] A C identifier. The argument must be an instance of @'ToIdent'@.
--
-- [@comment@] A comment to be attached to a statement. The argument must have
-- type @'String'@, and the antiquote must appear in a statement context.
--
-- [@const@] A constant. The argument must be an instance of @'ToConst'@.
--
-- [@int@] An @integer@ constant. The argument must be an instance of
-- @'Integral'@.
--
-- [@uint@] An @unsigned integer@ constant. The argument must be an instance of
-- @'Integral'@.
--
-- [@lint@] A @long integer@ constant. The argument must be an instance of
-- @'Integral'@.
--
-- [@ulint@] An @unsigned long integer@ constant. The argument must be an
-- instance of @'Integral'@.
--
-- [@llint@] A @long long integer@ constant. The argument must be an instance of
-- @'Integral'@.
--
-- [@ullint@] An @unsigned long long integer@ constant. The argument must be an
-- instance of @'Integral'@.
--
-- [@float@] A @float@ constant. The argument must be an instance of
-- @'Fractional'@.
--
-- [@double@] A @double@ constant. The argument must be an instance of
-- @'Fractional'@.
--
-- [@long double@] A @long double@ constant. The argument must be an instance
-- of @'Fractional'@.
--
-- [@char@] A @char@ constant. The argument must have type @'Char'@.
--
-- [@string@] A string (@char*@) constant. The argument must have type
-- @'String'@.
--
-- [@exp@] A C expression. The argument must be an instance of @'ToExp'@.
--
-- [@func@] A function definition. The argument must have type @'Func'@.
--
-- [@args@] A list of function arguments. The argument must have type @['Exp']@.
--
-- [@decl@] A declaration. The argument must have type @'InitGroup'@.
--
-- [@decls@] A list of declarations. The argument must have type
-- @['InitGroup']@.
--
-- [@sdecl@] A struct member declaration. The argument must have type
-- @'FieldGroup'@.
--
-- [@sdecls@] A list of struct member declarations. The argument must have type
-- @['FieldGroup']@.
--
-- [@enum@] An enum member. The argument must have type @'CEnum'@.
--
-- [@enums@] An list of enum members. The argument must have type @['CEnum']@.
--
-- [@esc@] An arbitrary top-level C "definition," such as an @#include@ or a
-- @#define@. The argument must have type @'String'@.  Also: an uninterpreted,
-- expression-level C escape hatch, which is useful for passing through macro
-- calls. The argument must have type @'String'@.
--
-- [@escstm@] An uninterpreted, statement-level C escape hatch, which is useful
-- for passing through macro calls. The argument must have type @'String'@.
--
-- [@edecl@] An external definition. The argument must have type @'Definition'@.
--
-- [@edecls@] An list of external definitions. The argument must have type
-- @['Definition']@.
--
-- [@item@] A statement block item. The argument must have type @'BlockItem'@.
--
-- [@items@] A list of statement block item. The argument must have type
-- @['BlockItem']@.
--
-- [@stm@] A statement. The argument must have type @'Stm'@.
--
-- [@stms@] A list of statements. The argument must have type @['Stm']@.
--
-- [@tyqual@] A type qualifier. The argument must have type @'TyQual'@.
--
-- [@tyquals@] A list of type qualifiers. The argument must have type
-- @['TyQual']@.
--
-- [@ty@] A C type. The argument must have type @'Type'@.
--
-- [@spec@] A declaration specifier. The argument must have type @'DeclSpec'@.
--
-- [@param@] A function parameter. The argument must have type @'Param'@.
--
-- [@params@] A list of function parameters. The argument must have type
-- @['Param']@.
--
-- [@pragma@] A pragma statement. The argument must have type @'String'@.
--
-- [@init@] An initializer. The argument must have type @'Initializer'@.
--
-- [@inits@] A list of initializers. The argument must have type
-- @['Initializer']@.
--
-- In addition, Objective-C code can use these antiquote specifiers:
--
-- [@ifdecl@] A class interface declaration. The argument must have type
-- @'ObjCIfaceDecl'@.
--
-- [@ifdecls@] A list of class interface declaration. The argument must have
-- type @['ObjCIfaceDecl']@.
--
-- [@prop@] A property declaration. The argument must have type
-- @'ObjCIfaceDecl'@.
--
-- [@props@] A list of property declarations. The argument must have type
-- @['ObjCIfaceDecl']@.
--
-- [@propattr@] A property attribute. The argument must have type
-- @'ObjCPropAttr'@.
--
-- [@propattrs@] A list of property attribute. The argument must have type
-- @['ObjCPropAttr']@.
--
-- [@dictelems@] A list dictionary elements. The argument must have type
-- @['ObjCDictElem']@.
--
-- [@methparam@] A method parameter. The argument must have type
-- @'ObjCParam'@.
--
-- [@methparams@] A list of method parameters. The argument must have type
-- @['ObjCParam']@.
--
-- [@methproto@] A method prototype. The argument must have type
-- @'ObjCMethodProto'@.
--
-- [@methdef@] A method definition. The argument must have type
-- @['Definition']@.
--
-- [@methdefs@] A list of method definitions. The argument must have type
-- @['Definition']@.
--
-- [@recv@] A receiver. The argument must have type @'ObjCRecv'@.
--
-- [@kwarg@] A keywords argument. The argument must have type
-- @'ObjCArg'@.
--
-- [@kwargs@] A list of keyword arguments. The argument must have type
-- @['ObjCArg']@.
--
--------------------------------------------------------------------------------

module Language.C.Quote (
    module Language.C.Quote.Base,
    module Language.C.Syntax
  ) where

import Language.C.Quote.Base
import Language.C.Syntax