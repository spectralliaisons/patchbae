# patchbae
Like tracking your synth and drum machine patches in a spreadsheet, but filter by tags, categories.

## see it in action
https://spectralliaisons.github.io/patchbae/

Columns:

`Name`: What is its saved name?

`Instrument`: Which device?

`Address`: Where is it stored on the device?

`Family`: Variations of one root patch.

`Friends`: What sounds good together?

## recent screenshot

![an image examplar](./examples/proofofconcept1.jpg)

## e.g.
Filter: [#     ]

Instrument | Category | Address | Name | Rating | Tags | Projects | Family | Friends|
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Prophet Rev2 | #pad | U4-P86 | Cine4 | * * * | #mellow #smooth #tinny #warble | #SongA | #Buum | # |
| Roland TR-8S | #kick | Kit-97 | Buum | * * | #deep #broad | #SongA #SongB | #Cine4 | #Snak |
| Roland TR-8S | #snare | Kit-97 | Snak | * * * * | #deep #broad | #SongC #SongD | # | #Buum |

## Building

`sh optimize.sh src/Main.elm`
