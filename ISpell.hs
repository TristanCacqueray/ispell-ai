{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}

-- | This module contains the ispell-ai implementation.
module ISpell (processDocument, DocumentChunk (..)) where

import Data.String.Interpolate (__i)
import Data.Text (Text)
import Data.Text qualified as T
import Text.Parsec qualified as P

-- | The prompt to edit English 'document' written by a 'userLanguage' speaker.
prompt :: Text -> Text -> Text
prompt userLanguage document =
    [__i|
  You are a professional editor specializing in helping people who speak English as a second language with their article.
  Your job is to edit the given article specifically focusing on common grammar and vocabulary mistakes.
  Do not comment or change the structure of the article, just respond with the edited article.

  Here is a blog post from one of your #{userLanguage} client:

  #{document}
|]

-- | The input document is divided into reasonably sized chunks.
data DocumentChunk
    = -- | A completion prompt
      Section Text
    | -- | A code block to be kept verbatim
      Verbatim Text
    deriving (Show)

-- | Get the next chunk of the document
getNextChunk :: [Text] -> (Maybe DocumentChunk, [Text])
getNextChunk [] = (Nothing, [])
getNextChunk xs
    | Just (codeBlock, rest) <- getVerbatimBlock xs = (Just $ Verbatim (T.unlines codeBlock), rest)
    | otherwise =
        let (section, rest) = getText 0 [] xs
         in (Just $ Section (T.unlines $ reverse section), rest)

-- | Return a reasonable section of text
getText :: Word -> [Text] -> [Text] -> ([Text], [Text])
getText _ acc [] = (acc, [])
getText count acc (x : xs)
    | -- Stop at code block delimiter
      isCodeBlock x || isLink x =
        (acc, (x : xs))
    | -- Reached a new heading after enough context
      count > 64 && "#" `T.isPrefixOf` x =
        (acc, (x : xs))
    | -- Keep on accumulating
      otherwise =
        getText (count + 1) (x : acc) xs

-- | Match code block delimiter
isCodeBlock :: Text -> Bool
isCodeBlock line = any (`T.isPrefixOf` line) (["```", "---", ":::"] :: [Text])

-- | Return True if the input is a markdown link like `[name]: url`
isLink :: Text -> Bool
isLink l = case P.parse linkParser mempty l of
    Left _ -> False
    Right _ -> True
  where
    linkParser = do
        _ <- P.char '['
        _ <- P.many1 (P.satisfy (/= ']'))
        _ <- P.string "]: http"
        pure ()

-- | Return the current code block
getVerbatimBlock :: [Text] -> Maybe ([Text], [Text])
getVerbatimBlock [] = Nothing
getVerbatimBlock (x : xs)
    | isLink x =
        let (links, rest) = span (isLink) xs
         in Just (x : links, rest)
    | isCodeBlock x =
        let (code, rest) = span (not . isCodeBlock) xs
         in case rest of
                (l : ls) -> Just (x : code <> [l], ls)
                [] -> Just (x : code, [])
    | otherwise = Nothing

-- | Process the input document for ispell-ai
processDocument :: Text -> Text -> [DocumentChunk]
processDocument userLanguage document = reverse $ go [] (T.lines document)
  where
    go acc [] = acc
    go acc inputLines = do
        let (currentChunk, rest) = getNextChunk inputLines
        case currentChunk of
            Nothing -> acc
            Just chunk -> do
                let action = case chunk of
                        Section txt -> Section $ prompt userLanguage txt
                        Verbatim txt -> Verbatim txt
                go (action : acc) rest
