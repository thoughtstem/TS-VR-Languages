#lang racket

(require ts-kata-util)

(define-example-code  
  3d-orbit hello-world-1
  (space-orbit)
  )


; ===== SPACE ORBIT KATAS

(define-example-code  
  3d-orbit orbits-1
  (space-orbit
   #:fly-speed 1000
   #:star (basic-star))
  )

(define-example-code  
  3d-orbit orbits-2
  (define my-universe
    (basic-universe
     #:universe-color 'blue
     #:star-color 'orange))
  
  (space-orbit 
   #:universe my-universe
   #:star (basic-star))
  )

(define-example-code  
  3d-orbit orbits-3
  (define dragon-universe
    (basic-universe
     #:star-size 4
     #:star-texture dragon-image))
  
  (space-orbit
   #:universe dragon-universe
   #:star (basic-star))
  )

(define-example-code  
  3d-orbit orbits-4
  (space-orbit
   #:start-position (position 0 0 100)
   #:star (basic-star
           #:radius 20))
  )

; ===== STAR & PLANET KATAS
(define-example-code  
  3d-orbit star-planet-1
  (space-orbit
   #:star (basic-star
           #:planets-list (list
                           (basic-planet))))
  )

(define-example-code  
  3d-orbit star-planet-2
  (define my-planet
    (basic-planet
     #:radius 5
     #:opacity 0.8
     #:color 'blue))

  (define my-star
    (basic-star
     #:radius 5
     #:opacity 0.8
     #:color 'yellow
     #:planets-list (list
                     my-planet)))
  
  (space-orbit
   #:star my-star)
  )

(define-example-code  
  3d-orbit star-planet-3
  (define changing-planet
    (basic-planet
     #:texture jupiter-bg
     #:on-mouse-enter (do-many
                       (texture mars-bg))
     #:on-mouse-leave (do-many
                       (texture jupiter-bg))))
    
  (space-orbit
   #:star (basic-star
           #:texture sun-bg
           #:on-mouse-click (do-many
                             (opacity 0.1))
           #:planets-list (list
                           changing-planet)))
  )
  

(define-example-code  
  3d-orbit star-planet-4
  (define my-planet
    (basic-planet
     #:label "Earth"
     #:label-color 'blue
     #:texture earth-bg
     #:animations-list (list
                        (y-rotation))))
  
  (space-orbit
   #:star (basic-star
           #:animations-list '()
           #:label "Sun"
           #:label-color 'orange
           #:texture sun-bg
           #:planets-list (list
                           my-planet)))
  )

;Earth is 100x furter, change the 230 to 23000
(define-example-code  
  3d-orbit star-planet-5
  (define the-earth
    (planet-earth
     #:position (position 230 0 0)))
  
  (space-orbit
   #:star (star-sun
           #:show-orbits? #t
           #:planets-list (list
                           the-earth)))
   )

; ===== MOON & RING KATAS
(define-example-code  
  3d-orbit moon-ring-1
  (define planet-with-moon
    (basic-planet
     #:moons-list (list
                   (basic-moon))))
  (space-orbit
   #:star (basic-star
           #:planets-list (list
                           planet-with-moon)))
  )

(define-example-code  
  3d-orbit moon-ring-2
  (define my-moons
    (list (basic-moon
           #:texture sun-bg
           #:scale 2)
          (basic-moon
           #:label "This moon grows!"
           #:on-mouse-enter (do-many
                             (scale 2))
           #:on-mouse-leave (do-many
                             (scale 1)))))
  
  (space-orbit
   #:star (basic-star
           #:animations-list '()
           #:planets-list (list
                           (basic-planet
                            #:moons-list my-moons))))
  )

(define-example-code  
  3d-orbit moon-ring-3
  (define my-moons
    (list (basic-moon)
          (basic-moon)))
  
  (define the-planet
    (basic-planet
     #:show-orbits? #t
     #:moons-list my-moons))
  
  (space-orbit
   #:star (basic-star
           #:show-orbits? #t
           #:planets-list (list
                           the-planet)))
  )

(define-example-code  
  3d-orbit moon-ring-4
  (define planet-with-ring
    (basic-planet
     #:rings-list (list
                   (basic-ring))))
  
  (space-orbit
   #:star (basic-star
           #:planets-list (list
                           planet-with-ring)))
  )

(define-example-code  
  3d-orbit moon-ring-5
  (define (my-rings)
    (list
     (basic-ring
      #:color 'red
      #:opacity 0.8)
     (basic-ring
      #:texture saturnring-bg
      #:rotation (rotation 90 0 90))))
  
  (space-orbit
   #:star (basic-star
           #:planets-list (list
                           (basic-planet
                            #:rings-list (my-rings)))))
  )
; ===== STAR SYSTEM KATAS
(define-example-code  
  3d-orbit star-system-1
  (space-orbit)
  )

(define-example-code  
  3d-orbit star-system-2
  (space-orbit)
  )

(define-example-code  
  3d-orbit star-system-3
  (space-orbit)
  )

(define-example-code  
  3d-orbit star-system-4
  (space-orbit)
  )

(define-example-code  
  3d-orbit star-system-5
  (space-orbit)
  )

; ===== SPACE OBJECTS KATAS
(define-example-code  
  3d-orbit space-objects-1
  (space-orbit)
  )

(define-example-code  
  3d-orbit space-objects-2
  (space-orbit)
  )

(define-example-code  
  3d-orbit space-objects-3
  (space-orbit)
  )

(define-example-code  
  3d-orbit space-objects-4
  (space-orbit)
  )

(define-example-code  
  3d-orbit space-objects-5
  (space-orbit)
  )