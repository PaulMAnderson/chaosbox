module ChaosBox.Geometry.Arc
  ( ArcOf(..)
  , Arc
  , arc
  , arcPoints
  )
where

import           ChaosBox.Prelude        hiding ( unit )

import           Control.Lens                   ( (^.)
                                                , (.~)
                                                , (&)
                                                )
import           ChaosBox.HasV2
import           ChaosBox.Geometry.Angle
import           ChaosBox.Geometry.Path
import           ChaosBox.Affine
import           ChaosBox.Draw
import qualified Graphics.Rendering.Cairo      as Cairo
import           ChaosBox.Math                  ( lerpMany )

-- | Arc (partial Circle)
data ArcOf a = ArcOf
  { arcCenter :: a
  -- ^ Center of the arc's circle
  , arcRadius :: Double
  -- ^ Radius of the arc's circle
  , arcStart  :: Angle
  -- ^ Start 'Angle'
  , arcEnd    :: Angle
  -- ^ End 'Angle'
  , arcDetail :: Int
  -- ^ Detail in number of points
  }
  deriving stock (Show, Eq, Ord, Functor, Foldable, Traversable)

type Arc = ArcOf (V2 Double)

instance HasV2 a => Draw (ArcOf a) where
  draw ArcOf {..} = Cairo.arc x y arcRadius (getAngle arcStart) (getAngle arcEnd)
    where V2 x y = arcCenter ^. _V2

instance HasV2 a => Affine (ArcOf a) where
  type Transformed (ArcOf a) = Maybe (PathOf a)
  transform m = fmap (transform m) . path . arcPoints

arc :: a -> Double -> Angle -> Angle -> ArcOf a
arc c r s e = ArcOf c r s e 100

arcPoints :: HasV2 a => ArcOf a -> [a]
arcPoints ArcOf {..} = points
 where
  angles = lerpMany arcDetail arcStart arcEnd
  points = flip map angles $ \theta ->
    arcCenter & _V2 .~ (arcCenter ^. _V2 + (unit theta ^* arcRadius))