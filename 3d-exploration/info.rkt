#lang info

(define scribblings '(("scribblings/manual.scrbl" (multi-page))))

(define deps '(
  "https://github.com/thoughtstem/TS-GE-Katas.git?path=ts-kata-util"
  "https://github.com/thoughtstem/vr-engine.git"
  "https://github.com/thoughtstem/vr-assets.git"
  "define-assets-from"
  "urlang"
  ))

(define compile-omit-paths '(
  "examples.rkt"))

