{-# LANGUAGE MonadComprehensions, OverloadedLists, TypeFamilies, GeneralizedNewtypeDeriving #-}

module Main where

import qualified Data.Set.Monad as DSM
import Data.List (intercalate)
import Control.Monad (join)
import Control.Applicative (Alternative)
import GHC.Exts (IsList(..))

-- we use a newtype wrapper so that we can define our own Show instance
newtype Set a = Set (DSM.Set a)
  deriving (Eq, Ord, Functor, Applicative, Monad, Alternative)

-- set output: {x₁,...,xₙ}
instance (Ord a, Show a) => Show (Set a) where
  show xs = "{" ++ intercalate ", " (map show (toList xs)) ++ "}"

-- set input: overloaded list syntax such that [x₁,...,xₙ] ≡ {x₁,...,xₙ}
instance Ord a => IsList (Set a) where
  type Item (Set a) = a
  fromList xs    = Set (DSM.fromList xs)
  toList (Set s) = DSM.toList s

-----------------------------------------------------------------------
-- Preliminaries: set operations

(∪) :: Ord a => Set a -> Set a -> Set a
(Set xs) ∪ (Set ys) = Set (xs `DSM.union` ys)

(⊆) :: Ord a => Set a -> Set a -> Bool
(Set xs) ⊆ (Set ys) = xs `DSM.isSubsetOf` ys

(∖) :: Ord a => Set a -> Set a -> Set a
(Set xs) ∖ (Set ys) = Set (xs DSM.\\ ys)

(⋃) :: Ord a => Set (Set a) -> Set a
(⋃) = join

type Attr = String

data FD = Set Attr :-> Attr       -- {A1,...,An} -> B
  deriving (Show, Eq, Ord)


------------------------------------------------------------------
-- Key Computation

key :: Set Attr -> Set Attr -> Set FD -> Set (Set Attr)
key ks us _ | us == [] = [ks]
key ks us fds          = (⋃) [ step [c] | c <- us ]
  where
    step :: Set Attr -> Set (Set Attr)
    step c | c ⊆ cover (ks ∪ (us ∖ c)) fds = key ks (us ∖ c) fds
           | otherwise                     = key (ks ∪ c) (us ∖ cover (ks ∪ c) fds) fds


cover :: Set Attr -> Set FD -> Set Attr
cover alpha fds = repeat (\xs -> xs ∪ det xs) alpha
  where
    det :: Set Attr -> Set Attr
    det xs = [ c | (β :-> c) <- fds, β ⊆ xs ]

    repeat :: Eq a => (a -> a) -> a -> a
    repeat f = until (\x -> f x == x) f


------------------------------------------------------------------

sch :: String -> Set Attr
sch "instructions" = ["set", "step", "piece", "color",
                      "quantity", "page", "img", "width", "height"]

sch "R"            = ["A", "B", "C", "D", "E"]

sch "zipcodes"     = ["zip", "street", "city", "state"]

sch "Bad"          = [ "A" ++ i | i <- fmap show [1..3] ] ∪
                     [ "B" ++ i | i <- fmap show [1..3] ]

-- see https://www.reddit.com/r/Database/comments/7ujky2/can_anyone_help_me_out_with_a_database_theory/
sch "Reddit"       = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]

fds :: String -> Set FD
fds "instructions" = [ ["set","step"] :-> "page",
                       ["set","step"] :-> "img",
                       ["img"]  :-> "width",
                       ["img"]  :-> "height",
                       ["set","step","piece","color"] :-> "quantity" ]

fds "R"            = [ ["A", "B"] :-> "E",
                       ["A", "D"] :-> "B",
                       ["B"]      :-> "C",
                       ["C"]      :-> "D" ]

fds "zipcodes"     = [ ["zip"] :-> "city",
                       ["zip"] :-> "state",
                       ["street", "city", "state"] :-> "zip" ]

fds "Bad"          = [ ["A" ++ i] :-> ("B" ++ i) | i <- fmap show [1..3] ] ∪
                     [ ["B" ++ i] :-> ("A" ++ i) | i <- fmap show [1..3] ]

fds "Reddit1"      = [ ["A","B"] :-> "C",
                       ["A"]     :-> "D",
                       ["A"]     :-> "E",
                       ["B"]     :-> "F",
                       ["F"]     :-> "G",
                       ["F"]     :-> "H",
                       ["D"]     :-> "I",
                       ["D"]     :-> "J" ]

fds "Reddit2"      = [ ["A","B"] :-> "C",
                       ["B","D"] :-> "E",
                       ["B","D"] :-> "F",
                       ["A","D"] :-> "G",
                       ["A","D"] :-> "H",
                       ["A"]     :-> "I",
                       ["H"]     :-> "J"]


main = do
  -- print $ cover ["set", "step"] (fds "instructions")
  print $ key [] (sch "instructions") (fds "instructions")
  -- print $ key [] (sch "R")        (fds "R")
  -- print $ key [] (sch "zipcodes") (fds "zipcodes")
  -- print $ key [] (sch "Bad")      (fds "Bad")
  -- print $ key [] (sch "Reddit")   (fds "Reddit2")
