#lang racket

;if using #lang 3d-orbit
(module reader syntax/module-reader
  3d-exploration/lang)

;if you (require 3d-orbit)
(provide (all-from-out "./lang.rkt"))
(require "./lang.rkt")
