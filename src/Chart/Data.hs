{-# LANGUAGE RebindableSyntax #-}
{-# OPTIONS_GHC -Wall #-}
{-# OPTIONS_HADDOCK prune #-}

-- | Data primitives and utilities
--
-- Whilst the library makes use of <https://hackage.haskell.org/package/numhask numhask>, it does not re-export, to avoid clashes with Prelude, with the exception of 'zero', 'one', 'angle', 'norm' & 'abs'.
--
-- 'Rect' and 'Point', from <https://hackage.haskell.org/package/numhask-space numhask-space>, make up the base elements of many chart primitives, and all of numhask-space is re-exported.
--
module Chart.Data
  ( -- * Data Primitives
    Rect (..),
    padRect,
    padSingletons,
    singletonGuard,
    Point (..),
    addp,

    -- * NumHask Exports
    --
    -- | Note that (+) and (*) from numhask are not actually re-exported.
    Multiplicative (one),
    Additive (zero),
    Direction (..),
    Norm (..),
    Signed (..),

    -- * Re-exports
    module NumHask.Space,
  )
where

import NumHask.Prelude
import NumHask.Space

-- | Additive pad (or frame or buffer) a Rect.
--
-- >>> padRect 1 one
-- Rect -1.5 1.5 -1.5 1.5
padRect :: (Subtractive a) => a -> Rect a -> Rect a
padRect p (Rect x z y w) = Rect (x - p) (z + p) (y - p) (w + p)

-- | Pad a Rect to remove singleton dimensions.
--
-- Attempting to scale a singleton dimension of a Rect is a common bug.
--
-- Due to the use of scaling, and thus zero dividing, this is a common exception to guard against.
--
-- >>> project (Rect 0 0 0 1) one (Point 0 0)
-- Point NaN -0.5
--
-- >>> project (padSingletons (Rect 0 0 0 1)) one (Point 0 0)
-- Point 0.0 -0.5
padSingletons :: Rect Double -> Rect Double
padSingletons (Rect x z y w)
  | x == z && y == w = Rect (x - 0.5) (x + 0.5) (y - 0.5) (y + 0.5)
  | x == z = Rect (x - 0.5) (x + 0.5) y w
  | y == w = Rect x z (y - 0.5) (y + 0.5)
  | otherwise = Rect x z y w

-- | Guard against an upstream Nothing or a singleton dimension
singletonGuard :: Maybe (Rect Double) -> Rect Double
singletonGuard = maybe one padSingletons

-- | add Points, dimension-wise
--
-- >>> Point 1 1 `addp` Point 0 2
-- Point 1.0 3.0
addp :: Point Double -> Point Double -> Point Double
addp = (+)
