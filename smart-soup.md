# ``smart-soup``

Machine Learning Index Extensions to [Soup](https://github.com/alfwatt/Soup)

## Overview

Uses [`SearchKit`](https://developer.apple.com/documentation/coreservices/search_kit) 
to build and matain vector indicies, the
[`Natural Language`](https://developer.apple.com/documentation/naturallanguage) 
framework for text embeddings, and the
[`Latent Semantic Mapping`](https://developer.apple.com/documentation/latentsemanticmapping/)
framework to create smart indicies for your soup.

### Classes

- `LanguageIndex` -- `ILSoupIndex` 
- `LatenetIndex` -- [`LSMapRef`](https://developer.apple.com/documentation/latentsemanticmapping/lsmmap?language=objc)`
- `VectorIndex` -- [`SKIndexRef`](https://developer.apple.com/documentation/coreservices/skindexref?language=objc)

### To-Do

- Perceptual Hash Indicies for Photo, Audio, and Video content
