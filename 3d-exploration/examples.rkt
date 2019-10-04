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
   #:environment (basic-environment
                  #:preset 'volcano))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-2
  (exploration-scene
   #:environment (basic-environment
                  #:dressing 'mushrooms
                  #:dressing-amount 25
                  #:dressing-scale 0.5))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-3
  (exploration-scene
   #:environment (basic-environment
                  #:ground 'spikes
                  #:ground-texture 'checkerboard
                  #:ground-color-1 'red
                  #:ground-color-2 'black
                  ))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration environment-4
  (exploration-scene
   #:environment (basic-environment
                  #:horizon-color 'orange
                  #:sky-color 'dark-blue
                  #:fog 0.6))
  )


; ===== GROUND OBJECTS KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-1
  (define (my-sphere)
    (basic-sphere #:color 'red
                  #:opacity 0.75))
  
  (exploration-scene
   #:ground-objects (list (my-sphere)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-2
  (define (my-cylinder)
    (basic-cylinder #:radius 3
                    #:height 5))

  (define (my-box)
    (basic-box #:scale 5 
               #:color 'blue))
                    
  (exploration-scene
   #:ground-objects (list (my-cylinder)
                          (my-box)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-3
  (define (my-ocean)
    (basic-ocean #:color 'aqua
                 #:width 30
                 #:depth 20))
  (exploration-scene
   #:ground-objects (list (my-ocean)
                          (my-ocean)
                          (my-ocean)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-4
  (define (my-sphere)
    (basic-sphere
     #:color 'red
     #:on-mouse-click (list
                       (color 'blue))))
    (exploration-scene
     #:ground-objects (list (my-sphere)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration ground-objects-5
  (define (my-cylinder)
    (basic-cylinder
     #:color 'orange
     #:on-mouse-enter (list
                       (color 'yellow)
                       (radius 5))
     #:on-mouse-leave (list
                       (color 'orange)
                       (radius 1))))
     (exploration-scene
      #:ground-objects (list (my-cylinder)))
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
  (define (my-sphere)
    (basic-sphere
     #:color (random-color)
     #:opacity 0.2))
  
  (exploration-scene 
   #:sky-objects (list (my-sphere)
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
   #:environment (basic-environment
                  #:preset 'egypt
                  #:fog 0)
   #:stars (basic-stars))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration sky-objects-5
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'forest
                  #:horizon-color 'black
                  #:sky-color 'black
                  #:fog 0)
   #:stars (basic-stars))
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
                      (basic-particles
                       #:speed 20
                       #:size 5
                       #:age 2)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-3
  (exploration-scene
   #:sky-objects (list
                  (basic-particles #:preset 'rain
                                   #:count 5000
                                   #:posn-spread (posn-spread 200 100 200))))

  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-4
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'egypt)
   #:sky-objects (list
                  (basic-particles #:preset 'dust
                                   #:count 4000)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration particles-5
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'forest
                  #:horizon-color 'dark-blue
                  #:sky-color 'black
                  #:fog 0.5)
   #:sky-objects (list
                  (basic-particles #:image forest-bg ;dragon-image
                                   #:count 2000))               )
  )


  ; ===== ANIMATIONS KATAS
(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-1
  (exploration-scene
   #:ground-objects (list
                     (basic-box
                      #:color (random-color)
                      #:animations-list (list
                                         (animate-scale #:to 5))))               )
   )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-2
  (exploration-scene
   #:sky-objects (basic-cone
                      #:components-list (list
                                         (animate-position
                                          #:loops 5
                                          #:to (position 0 0 0)))))               
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-3
  (exploration-scene
   #:ground-objects (list
                     (basic-box
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
  (define (sun)
    (basic-sphere #:texture sun-bg
                 #:radius 5
                 #:animations-list (list
                                    (animate-rotation))
                 #:components-list (list
                                    (earth))))
  (exploration-scene
   #:sky-objects (list (sun)))
  )

(define-example-code
  ;#:with-test (test vr-test)
  3d-exploration animations-5
 (exploration-scene
 (3d-model #:model bird
            #:position (position 0 0 0)
            #:animations-list (list (animate-position
                                     #:to (posn 50 50 50)
                                     #:duration 10000))))          
  )

