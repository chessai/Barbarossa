{-# LANGUAGE BangPatterns #-}
module Moves.History (
        History, newHist, toHist, valHist
    ) where

import Data.Bits
import qualified Data.Vector.Unboxed.Mutable as V
import Struct.Struct

type History = V.IOVector Int

rows, cols, vsize :: Int
rows = 64
cols = 64
vsize = rows * cols

adr :: Int -> Int -> Int
adr !f !t = rows * f + t

newHist :: IO History
newHist = V.replicate vsize 0

histw :: Int -> Int
histw !d = 1 `unsafeShiftL` dm
    where !dm = maxd - d
          maxd = 20

toHist :: History -> Bool -> Square -> Square -> Int -> IO ()
toHist h True  f t d = addHist h (adr f t) (histw d)
toHist h False f t d = subHist h (adr f t) (histw d)

valHist :: History -> Square -> Square -> Int -> IO Int
valHist !h !f !t _ = V.unsafeRead h $! adr f t

addHist :: History -> Int -> Int -> IO ()
addHist h !ad !p = do
    a <- V.unsafeRead h ad
    let !u = a - p	-- trick here: we subtract, so that the sort is big to small
        !v = if u < lowLimit then lowHalf else u
    V.unsafeWrite h ad v
    where lowLimit = -1000000000
          lowHalf  =  -500000000

subHist :: History -> Int -> Int -> IO ()
subHist h !ad !p = do
    a <- V.unsafeRead h ad
    let !u = a + p	-- trick here: we add, so that the sort is big to small
        !v = if u > higLimit then higHalf else u
    V.unsafeWrite h ad v
    where higLimit = 1000000000
          higHalf  =  500000000
