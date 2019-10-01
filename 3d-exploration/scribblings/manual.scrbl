#lang scribble/manual
 
@require[scribble/extract]

@; === TODO: angle already required conflict
@require[@for-label[@;"../main.rkt"
                    racket/base]]

@title{3d-exploration}
@author{thoughtstem}
@defmodulelang[3d-exploration]

This language allows the user to create 3D Explorable Worlds.

@table-of-contents[]

@section{Functions}
@(include-extracted "../lang/main.rkt")

@section{VR Assets}
All of the assets in this @(hyperlink "https://docs.racket-lang.org/vr-assets@vr-assets/index.html" "library") are provided.