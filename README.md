# ispell-ai

ispell-ai is a spell checker for Markdown content using a Chat Completion API.
The implementation is based on [ada][ada] and you can find the new module in
[ISpell.hs](./ISpell.hs).

[ada]: https://github.com/MercuryTechnologies/ada

## Usage

ispell-ai reads the document from stdin, and
it writes the corrected version to stdout:

```ShellSession
cat my-post.md | ispell-ai
```

Here are the environment variables:

| Name            | Value       |
|-----------------|-------------|
| ISPELL_AI_URL   | Service URL |
| ISPELL_AI_KEY   | API Key     |
| ISPELL_AI_MODEL | Model Name  |

The goal is to integrate this tool with a `M-x ispell-ai-region` command,
to interactively accept the changes.


## Install

Install the toolchain using [ghcup](https://www.haskell.org/ghcup/), then run:

```ShellSession
cabal install exe:ispell-ai
```
