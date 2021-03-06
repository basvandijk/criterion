{-# LANGUAGE DeriveDataTypeable #-}

-- |
-- Module      : Criterion.Config
-- Copyright   : (c) 2009, 2010 Bryan O'Sullivan
--
-- License     : BSD-style
-- Maintainer  : bos@serpentine.com
-- Stability   : experimental
-- Portability : GHC
--
-- Benchmarking configuration.

module Criterion.Config
    (
      Config(..)
    , PrintExit(..)
    , Verbosity(..)
    , defaultConfig
    , fromLJ
    , ljust
    ) where

import Data.Data (Data)
import Data.Function (on)
import Data.Monoid (Monoid(..), Last(..))
import Data.Typeable (Typeable)

-- | Control the amount of information displayed.
data Verbosity = Quiet
               | Normal
               | Verbose
                 deriving (Eq, Ord, Bounded, Enum, Read, Show, Typeable)

-- | Print some information and exit, without running any benchmarks.
data PrintExit = Nada           -- ^ Do not actually print-and-exit. (Default.)
               | List           -- ^ Print a list of known benchmarks.
               | Version        -- ^ Print version information (if known).
               | Help           -- ^ Print a help\/usaage message.
                 deriving (Eq, Ord, Bounded, Enum, Read, Show, Typeable, Data)

instance Monoid PrintExit where
    mempty  = Nada
    mappend = max

-- | Top-level program configuration.
data Config = Config {
      cfgBanner       :: Last String -- ^ The \"version\" banner to print.
    , cfgConfInterval :: Last Double -- ^ Confidence interval to use.
    , cfgPerformGC    :: Last Bool   -- ^ Whether to run the GC between passes.
    , cfgPrintExit    :: PrintExit   -- ^ Whether to print information and exit.
    , cfgResamples    :: Last Int    -- ^ Number of resamples to perform.
    , cfgReport       :: Last FilePath -- ^ Filename of report.
    , cfgSamples      :: Last Int    -- ^ Number of samples to collect.
    , cfgSummaryFile  :: Last FilePath -- ^ Filename of summary CSV.
    , cfgCompareFile  :: Last FilePath -- ^ Filename of the comparison CSV.
    , cfgTemplate     :: Last FilePath -- ^ Filename of report template.
    , cfgVerbosity    :: Last Verbosity -- ^ Whether to run verbosely.
    , cfgJUnitFile    :: Last FilePath -- ^ Filename of JUnit report.
    , cfgMeasure      :: Last Bool   -- ^ Whether to do any measurement.
    } deriving (Eq, Read, Show, Typeable)

instance Monoid Config where
    mempty  = emptyConfig
    mappend = appendConfig

-- | A configuration with sensible defaults.
defaultConfig :: Config
defaultConfig = Config {
                  cfgBanner       = ljust "I don't know what version I am."
                , cfgConfInterval = ljust 0.95
                , cfgPerformGC    = ljust False
                , cfgPrintExit    = Nada
                , cfgResamples    = ljust (100 * 1000)
                , cfgReport       = mempty
                , cfgSamples      = ljust 100
                , cfgSummaryFile  = mempty
                , cfgCompareFile  = mempty
                , cfgTemplate     = ljust "report.tpl"
                , cfgVerbosity    = ljust Normal
                , cfgJUnitFile    = mempty
                , cfgMeasure      = ljust True
                }

-- | Constructor for 'Last' values.
ljust :: a -> Last a
ljust = Last . Just

-- | Deconstructor for 'Last' values.
fromLJ :: (Config -> Last a)    -- ^ Field to access.
       -> Config                -- ^ Default to use.
       -> a
fromLJ f cfg = case f cfg of
                 Last Nothing  -> fromLJ f defaultConfig
                 Last (Just a) -> a

emptyConfig :: Config
emptyConfig = Config {
                cfgBanner       = mempty
              , cfgConfInterval = mempty
              , cfgPerformGC    = mempty
              , cfgPrintExit    = mempty
              , cfgReport       = mempty
              , cfgResamples    = mempty
              , cfgSamples      = mempty
              , cfgSummaryFile  = mempty
              , cfgCompareFile  = mempty
              , cfgTemplate     = mempty
              , cfgVerbosity    = mempty
              , cfgJUnitFile    = mempty
              , cfgMeasure      = mempty
              }

appendConfig :: Config -> Config -> Config
appendConfig a b =
    Config {
      cfgBanner       = app cfgBanner a b
    , cfgConfInterval = app cfgConfInterval a b
    , cfgPerformGC    = app cfgPerformGC a b
    , cfgPrintExit    = app cfgPrintExit a b
    , cfgReport       = app cfgReport a b
    , cfgResamples    = app cfgResamples a b
    , cfgSamples      = app cfgSamples a b
    , cfgSummaryFile  = app cfgSummaryFile a b
    , cfgCompareFile  = app cfgCompareFile a b
    , cfgTemplate     = app cfgTemplate a b
    , cfgVerbosity    = app cfgVerbosity a b
    , cfgJUnitFile    = app cfgJUnitFile a b
    , cfgMeasure      = app cfgMeasure a b
    }
  where app f = mappend `on` f
