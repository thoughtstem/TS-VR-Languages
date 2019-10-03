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
                                #:dressing-amount 25
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
                                    #:dressing-variance (variance 2 2 2)
                                    #:ground 'canyon
                                    #:ground-texture 'squares
                                    #:fog 0.6
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
  (exploration-scene
   #:ground-objects (list (basic-sphere
                           #:color "red"
                           #:on-mouse-click (list
                                             (color "blue")))))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-5
  (exploration-scene
   #:ground-objects (list (basic-cylinder
                           #:color 'orange
                           #:on-mouse-enter (list
                                             (color 'yellow)
                                             (radius 5))
                           #:on-mouse-leave (list
                                             (color 'orange)
                                             (radius 1)))))
  )


; ===== SKY OBJECTS KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-1
  (exploration-scene
   #:sky-objects (list (basic-cone
                        #:scale (random-scale 1.0 5.0)
                        #:color (random-color)
                        #:rotation (random-rotation))))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-2
  (define (my-object)
    (basic-dodecahedron
     #:color (random-color)
     #:opacity 0.2))
  
  (exploration-scene 
   #:sky-objects (list (my-object)
                       thoughtstem-logo))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-3
  (exploration-scene
   #:sky-objects (list bird
                       astronaut
                       sword))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-4
  (exploration-scene
   #:environment (basic-volcano
                  #:fog 0)
   #:stars (add-stars))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-5
  (exploration-scene
   #:environment (basic-forest
                  #:horizon-color 'black
                  #:sky-color 'black
                  #:fog 0)
   #:stars (add-stars #:hex-color 'yellow))
  )

; ===== PARTICLES KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-1
  (exploration-scene
   #:ground-objects (list (add-particles)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-2
  (exploration-scene
    #:sky-objects (list
                      (add-particles #:hex-color "#ff0000,#00ff00,#0000ff"
                                     #:speed 20
                                     #:size 5
                                     #:age 2)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-3
  (exploration-scene
   (add-particles #:preset 'rain
                  #:hex-color "#0000ff"
                  #:count 5000
                  #:posn-spread (posn-spread 200 100 200)))

  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-4
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'egypt)
   (add-particles #:preset 'dust
                  #:count 4000
                  #:hex-color "#deb887"))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-5
  (exploration-scene
   #:environment (basic-forest
                  #:horizon-color "dark-blue"
                  #:sky-color "black"
                  #:fog 0.5)
   (add-particles #:preset 'snow
                  #:hex-color "#ffffff"
                  #:count 2000))               
  )
  ; ===== OCEAN KATAS
  