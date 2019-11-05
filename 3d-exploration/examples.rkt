#lang racket

(require ts-kata-util)

; === TODO: Make vr-test work, file in ts-kata-util/main.rkt
(define-example-code  
  3d-exploration hello-world-1
  (exploration-scene)
  )


; ===== ENVIRONMENT KATAS
(define-example-code  
  3d-exploration environment-1
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'volcano))
  )

(define-example-code  
  3d-exploration environment-2
  (exploration-scene
   #:environment (basic-environment
                  #:dressing 'mushrooms
                  #:dressing-amount 25
                  #:dressing-scale 0.5))
  )

(define-example-code  
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
  ;needs preset or else colors don't work
  3d-exploration environment-4
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'egypt 
                  #:horizon-color 'orange
                  #:sky-color 'dark-blue
                  #:fog 0.6))
  )


; ===== GROUND OBJECTS KATAS
(define-example-code  
  3d-exploration ground-objects-1
  (define (my-sphere)
    (basic-sphere #:color 'red
                  #:opacity 0.75))
  
  (exploration-scene
   #:ground-objects (list (my-sphere)))
  )

(define-example-code  
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
  3d-exploration ground-objects-3
  (define (my-ocean)
    (basic-ocean #:color 'orange
                 #:width 30
                 #:depth 20))
  (exploration-scene
   #:ground-objects (list (my-ocean)
                          (my-ocean)
                          (my-ocean)))
  )

(define-example-code 
  3d-exploration ground-objects-4
  (define (my-sphere)
    (basic-sphere
     #:color 'red
     #:on-mouse-click (do-many
                       (color 'blue))))
    (exploration-scene
     #:ground-objects (list (my-sphere)))
  )

(define-example-code  
  3d-exploration ground-objects-5
  (define (my-cylinder)
    (basic-cylinder
     #:color 'orange
     #:on-mouse-enter (do-many
                       (color 'yellow)
                       (radius 5))
     #:on-mouse-leave (do-many
                       (color 'orange)
                       (radius 1))))
     (exploration-scene
      #:ground-objects (list (my-cylinder)))
  )


; ===== SKY OBJECTS KATAS
(define-example-code  
  3d-exploration sky-objects-1
  (exploration-scene
   #:sky-objects (list (basic-cone
                        #:scale (random-scale)
                        #:color (random-color)
                        #:rotation (random-rotation))))
  )

(define-example-code  
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
  3d-exploration sky-objects-3
  (exploration-scene
   #:sky-objects (list bird
                       astronaut
                       sword))
  )

(define-example-code  
  3d-exploration sky-objects-4
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'egypt
                  #:fog 0)
   #:stars (basic-stars))
  )

(define-example-code  
  3d-exploration sky-objects-5
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'forest
                  #:horizon-color 'dark-blue
                  #:sky-color 'black
                  #:fog 0)
   #:stars (basic-stars))
  )

; ===== PARTICLES KATAS
(define-example-code  
  3d-exploration particles-1
  (exploration-scene
   #:ground-objects (list (basic-particles)))
  )

(define-example-code  
  3d-exploration particles-2
  (define (my-particles)
    (basic-particles
     #:speed 5
     #:size 5
     #:age 3))
  
  (exploration-scene
   #:sky-objects (list
                  (my-particles)))
  )

(define-example-code  
  3d-exploration particles-3
  (define (my-particles)
    (basic-particles #:preset 'rain
                     #:count 5000))
  
  (exploration-scene
   #:sky-objects (list
                  (my-particles)))

  )

(define-example-code  
  3d-exploration particles-4
  (define (my-particles)
    (basic-particles #:preset 'dust
                     #:count 4000))
  
  (exploration-scene
   #:environment (basic-environment
                  #:preset 'egypt)
   #:ground-objects (list
                     (my-particles)))
  )

(define-example-code  
  3d-exploration particles-5
  (define (my-environment)
    (basic-environment
     #:preset 'forest
     #:horizon-color 'dark-blue
     #:sky-color 'black
     #:fog 0.5))

  (define (my-particles)
    (basic-particles #:image dragon-image
                     #:count 2000))
  
  (exploration-scene
   #:environment (my-environment)
   #:sky-objects (list
                  (my-particles)))
  )


  ; ===== ANIMATIONS KATAS
(define-example-code  
  3d-exploration animations-1
  (define (my-cylinder)
    (basic-cylinder
     #:color (random-color)
     #:animations-list (do-many
                        (animate-scale #:to 5))))
  
  (exploration-scene
   #:ground-objects (list
                     (my-cylinder)))
  )

(define-example-code  
  3d-exploration animations-2
  (define (my-cone)
    (basic-cone
     #:animations-list (do-many
                        (animate-position
                         #:loops 5
                         #:to (position 0 0 0)))))
  (exploration-scene
   #:sky-objects (list (my-cone)))             
  )

(define-example-code  
  3d-exploration animations-3
  (define (my-box)
    (basic-box
     #:color (random-color)
     #:animations-list (do-many
                        (animate-rotation)
                        (animate-scale #:to 3))))
  
  (exploration-scene
   #:ground-objects (list
                     (my-box)))               
  )

(define-example-code  
  3d-exploration animations-4
  (define (earth)
    (basic-sphere
     #:position (position 25 0 0)    
     #:texture earth-bg))
  (define (sun)
    (basic-sphere #:texture sun-bg
                  #:radius 5
                  #:animations-list (do-many
                                     (animate-rotation))
                  #:components-list (list
                                     (earth))))
  (exploration-scene
   #:sky-objects (list
                  (sun)))
  )

(define-example-code  
  3d-exploration animations-5
  (define (my-model)
    (3d-model #:model bird
              #:position (position 0 0 0)
              #:animations-list (do-many
                                 (animate-position
                                  #:to (position 100 100 100)
                                  #:loops 0))))
  (exploration-scene
   #:ground-objects (list
                     (my-model)))          
  )

