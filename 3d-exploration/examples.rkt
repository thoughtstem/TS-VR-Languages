#lang racket

(require ts-kata-util)

; === TODO: Make vr-test work, file in ts-kata-util/main.rkt
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration hello-world-1
  (exploration-scene))


; ===== ENVIRONMENT KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-1
  (exploration-scene
   #:environment (basic-volcano))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-2
  (exploration-scene
   #:environment (basic-volcano #:preset 'egypt
                                #:dressing 'mushrooms
                                #:dressing-amount 20
                                #:dressing-scale 0.5
                                ))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-3
  (exploration-scene
   #:fly-mode #f
   #:environment (basic-forest #:preset 'poison
                               #:dressing 'cubes
                               #:dressing-amount 10
                               #:ground 'spikes
                               #:fog 0.6
                               #:horizon-color "#00B0B0"
                               ))
  )

(define-example-code
   ;#:with-test (test vr-test)
  3d-exploration environment-4
  (exploration-scene
   #:speed 100
   #:environment (basic-environment #:preset 'tron
                                    #:dressing 'hexagons
                                    #:dressing-amount 40
                                    #:dressing-scale 0.5
                                    #:dressing-variance (variance 0.1 2.0 0.1)
                                    #:ground 'canyon
                                    #:ground-texture 'squares
                                    #:fog 0.6
                                    #:horizon-color "#00B0B0"
                                    ))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-5
  (exploration-scene
   #:environment (basic-environment #:preset 'tron
                                    #:dressing 'hexagons
                                    #:dressing-amount 40
                                    #:dressing-scale 0.5
                                    #:dressing-variance (variance 0.1 2.0 0.1)
                                    #:ground 'canyon
                                    #:ground-texture 'squares
                                    #:fog 0.6
                                    #:horizon-color "#00B0B0"
                                    ))
  )


; ===== GROUND OBJECTS KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-1
  (exploration-scene
   #:ground-objects (list (basic-sphere)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-2
  (define (my-sphere)
    (basic-sphere #:color (color 255 0 0)
                  #:radius 5.0
                  #:opacity 0.75))
  
  (exploration-scene
   #:ground-objects (list (my-sphere)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-3
  (define (object-1)
    (basic-cylinder #:radius 3
                    #:height 5
                    #:texture forest_bg
                    #:rotation (rotation 0 1 0)))

  (define (object-2)
    (basic-dodecahedron #:scale (scale 1 5 1)
                        #:color (color 0 255 0)))
                    
  (exploration-scene
   #:ground-objects (list (object-1)
                          (object-2)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-4
  ;TODO: Something like mouse-click 
  (exploration-scene
   #:ground-objects (list (basic-sphere)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-5
  ;TODO: Something like mouse-enter, mouse-leave
  (exploration-scene
   #:ground-objects (list (basic-sphere)))
  )


; ===== SKY OBJECTS KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-1
  (exploration-scene
   #:sky-objects (list (basic-cone)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-2
  (exploration-scene
   #:sky-objects (list (basic-cone)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-3
  (exploration-scene
   #:sky-objects (list (basic-cone)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-4
  (exploration-scene
   #:sky-objects (list (basic-cone)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-5
  (exploration-scene
   #:sky-objects (list (basic-cone)))
  )
; ===== PARTICLES KATAS
; ===== OCEAN KATAS
