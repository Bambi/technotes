# Markdown
## Links
- markdown syntax: `[text](link)`
- wiki syntax: `[[link|text]]`
- referenced syntax: `[text][ref]  elsewhere: [ref]: link`

## Emoji
`:smile:`

## Notes
* in the text: `[^ref]`
* note: `[^ref]: note`

## Blocks
Text block with an indicator:
```
>[!tip] title
> text
```
Indicator can be:
- !note
- !important
- !info
- !warnibg
- !failure

## Metadata
At the to or the end of the note:
```
---
yaml metadata
---
```

## Tags
To set a tag use either the metadata (`yaml tag: [mytag, ...]`)
or `#mytag` (at the beginning of a line).

# ZK
Edit a note: `zk edit -i`.
