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
  (define (my-sphere)
    (basic-sphere #:color (color 255 0 0)
                  #:radius 5.0
                  #:opacity 0.75))
  
  (exploration-scene
   #:ground-objects (list (my-sphere)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-2
  (define (object-1)
    (basic-cylinder #:radius 3
                    #:height 5
                    #:texture forest-bg
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
  3d-exploration ground-objects-3
  (define (my-ocean)
    (basic-ocean #:color "aqua"
                 #:width 50
                 #:depth 30))
  (exploration-scene
   #:ground-objects (list (my-ocean)
                          (basic-ocean)
                          (basic-ocean)))
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
   #:stars (basic-stars))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-5
  (exploration-scene
   #:environment (basic-forest
                  #:horizon-color 'black
                  #:sky-color 'black
                  #:fog 0)
   #:stars (basic-stars #:hex-color 'yellow))
  )

; ===== PARTICLES KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-1
  (exploration-scene
   #:ground-objects (list (basic-particles)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-2
  (exploration-scene
    #:sky-objects (list
                      (basic-particles #:hex-color "#ff0000,#00ff00,#0000ff"
                                     #:speed 20
                                     #:size 5
                                     #:age 2)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-3
  (exploration-scene
   (basic-particles #:preset 'rain
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
   (basic-particles #:preset 'dust
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
   (basic-particles #:preset 'snow
                  #:hex-color "#ffffff"
                  #:count 2000))               
  )


  ; ===== ANIMATIONS KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-1
  (exploration-scene
   (basic-box
    #:color (random-color)
    #:animations-list (list
                       (animate-scale #:to 5))))               
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-2
  (exploration-scene
   #:sky-objects (basic-cone
                      #:components-list (list
                                         (animate-position
                                          #:loops "5"
                                          #:to (to-posn 0 0 0)))))               
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-3
  (exploration-scene
   #:ground-objects (list
                     (basic-dodecahedron
                      #:color (random-color)
                      #:animations-list (list
                                         (animate-scale #:to 3
                                                        #:duration 10000)
                                         (animate-rotation)))))               
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-4
  (define (earth)
    (basic-sphere
     #:position (position 25 0 0)    
     #:texture earth-bg))
  (exploration-scene
   (basic-sphere #:texture sun-bg
                 #:position (position 0 5 0)
                 #:radius 5
                 #:animations-list (list
                                    (animate-rotation
                                     #:duration 10000))
                 #:components-list (list
                                    (earth))))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-5
  (define (earth)
    (basic-sphere
     #:position (position 25 0 0)
     #:animations-list (list
                        (animate-rotation
                         #:to (to-posn 360 0 360)))
     #:components-list (list (moon))))
  (define (moon)
    (basic-sphere
     #:position (position 1 1 2)
     #:radius .2)) 
  (exploration-scene
   (basic-sphere #:position (position 0 5 0)
                 #:radius 5
                 #:animations-list (list
                                    (animate-rotation
                                     #:duration 10000))
                 #:components-list (list
                                    (earth))))           
  )
