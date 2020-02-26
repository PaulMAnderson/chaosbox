{-# LANGUAGE TypeFamilies #-}
module ChaosBox.Affine
  ( Affine(..)
  , defaultTransform
  , withCairoAffine
  -- * Transformations
  , rotated
  , translated
  , scaled
  , shearedX
  , shearedY
  , sheared
  , reflectedOrigin
  , reflectedX
  , reflectedY
  )
where

import           ChaosBox.Prelude                hiding (scaled)

import           ChaosBox.HasV2
import qualified ChaosBox.Math.Matrix            as Matrix
import           Control.Lens                    ((%~))
import           Graphics.Rendering.Cairo        hiding (transform)
import qualified Graphics.Rendering.Cairo.Matrix as CairoMatrix

-- | A class of items that are transformable via linear transformations
class Affine a where
  type Transformed a :: *
  type Transformed a = a
  transform :: M33 Double -> a -> Transformed a

-- | A useful default 'transform' for 'Functor's over 2D coordinates
--
-- Note: This only works if @Transformed (f a) == f a@
--
defaultTransform :: (Functor f, HasV2 a) => M33 Double -> f a -> f a
defaultTransform m = fmap (_V2 %~ Matrix.applyMatrix m)

-- | Render something with an 'M33' transformation matrix applied
--
-- @withCairoAffine m render@ resets the 'Matrix' to what it was before
-- @render@ is executed afterwards.
--
withCairoAffine :: M33 Double -> Render () -> Render ()
withCairoAffine (V3 (V3 a b c) (V3 d e f) _) render = do
  -- Note: Cairo's transformation matrix is column-major and does not contain a
  -- third row.
  let cairoMatrix = CairoMatrix.Matrix a d b e c f
  oldMatrix <- getMatrix
  setMatrix cairoMatrix
  render
  setMatrix oldMatrix

-- Applied transformations

rotated :: Affine a => Double -> a -> Transformed a
rotated = transform . Matrix.rotation

translated :: Affine a => V2 Double -> a -> Transformed a
translated = transform . Matrix.translation

scaled :: Affine a => V2 Double -> a -> Transformed a
scaled = transform . Matrix.scalar

shearedX :: Affine a => Double -> a -> Transformed a
shearedX = transform . Matrix.shearX

shearedY :: Affine a => Double -> a -> Transformed a
shearedY = transform . Matrix.shearY

sheared :: Affine a => V2 Double -> a -> Transformed a
sheared = transform . Matrix.shear

reflectedOrigin :: Affine a => a -> Transformed a
reflectedOrigin = transform Matrix.reflectOrigin

reflectedX :: Affine a => a -> Transformed a
reflectedX = transform Matrix.reflectX

reflectedY :: Affine a => a -> Transformed a
reflectedY = transform Matrix.reflectY