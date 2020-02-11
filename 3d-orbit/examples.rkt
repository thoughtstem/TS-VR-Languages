#lang racket

(require ts-kata-util)

(define-example-code  
  3d-orbit hello-world-1
  (orbit-scene)
  )


; ===== SPACE ORBIT KATAS

(define-example-code  
  3d-orbit orbit-1
  (orbit-scene
   #:fly-speed 1000
   #:star (basic-star))
  )

(define-example-code  
  3d-orbit orbit-2
  (define my-universe
    (basic-universe
     #:universe-color 'blue
     #:star-color 'orange))
  
  (orbit-scene 
   #:universe my-universe
   #:star (basic-star))
  )

(define-example-code  
  3d-orbit orbit-3
  (define dragon-universe
    (basic-universe
     #:star-size 4
     #:star-texture dragon-image))
  
  (orbit-scene
   #:universe dragon-universe
   #:star (basic-star))
  )

(define-example-code  
  3d-orbit orbit-4
  (orbit-scene
   #:start-position (position 0 0 100)
   #:star (basic-star
           #:radius 20))
  )

; ===== STAR & PLANET KATAS
(define-example-code  
  3d-orbit star-and-planet-1
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           (basic-planet))))
  )

(define-example-code  
  3d-orbit star-and-planet-2
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
  
  (orbit-scene
   #:star my-star)
  )

(define-example-code  
  3d-orbit star-and-planet-3
  (define changing-planet
    (basic-planet
     #:texture jupiter-tex
     #:on-mouse-enter (do-many
                       (texture mars-tex))
     #:on-mouse-leave (do-many
                       (texture jupiter-tex))))
    
  (orbit-scene
   #:star (basic-star
           #:texture sun-tex
           #:on-mouse-click (do-many
                             (opacity 0.1))
           #:planets-list (list
                           changing-planet)))
  )
  

(define-example-code  
  3d-orbit star-and-planet-4
  (define my-planet
    (basic-planet
     #:label "Earth"
     #:label-color 'blue
     #:texture earth-tex
     #:animations-list (list
                        (y-rotation))))
  
  (orbit-scene
   #:star (basic-star
           #:animations-list '()
           #:label "Sol"
           #:label-color 'orange
           #:texture sun-tex
           #:planets-list (list
                           my-planet)))
  )

;Earth is 100x furter, change the 230 to 23000
(define-example-code  
  3d-orbit star-and-planet-5
  (define the-earth
    (planet-earth
     #:position (position 230 0 0)))
  
  (orbit-scene
   #:star (star-sun
           #:show-orbits? #t
           #:planets-list (list
                           the-earth)))
   )

; ===== MOON & RING KATAS
(define-example-code  
  3d-orbit moon-and-ring-1
  (define planet-with-moon
    (basic-planet
     #:moons-list (list
                   (basic-moon))))
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           planet-with-moon)))
  )

(define-example-code  
  3d-orbit moon-and-ring-2
  (define my-moons
    (list (basic-moon)
          (basic-moon)))
  
  (define the-planet
    (basic-planet
     #:show-orbits? #t
     #:moons-list my-moons))
  
  (orbit-scene
   #:star (basic-star
           #:show-orbits? #t
           #:planets-list (list
                           the-planet)))
  )

(define-example-code  
  3d-orbit moon-and-ring-3
  (define my-moons
    (list (basic-moon
           #:texture sun-tex
           #:scale 2)
          (basic-moon
           #:label "This moon grows!"
           #:on-mouse-enter (do-many
                             (scale 2))
           #:on-mouse-leave (do-many
                             (scale 1)))))
  
  (orbit-scene
   #:star (basic-star
           #:animations-list '()
           #:planets-list (list
                           (basic-planet
                            #:moons-list my-moons))))
  )

(define-example-code  
  3d-orbit moon-and-ring-4
  (define planet-with-ring
    (basic-planet
     #:rings-list (list
                   (basic-ring))))
  
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           planet-with-ring)))
  )

(define-example-code  
  3d-orbit moon-and-ring-5
  (define my-rings
    (list
     (basic-ring
      #:color 'red
      #:opacity 0.8)
     (basic-ring
      #:texture saturnring-tex
      #:tilt (tilt 90 0 90))))
  
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           (basic-planet
                            #:rings-list my-rings))))
  )

; ===== SPACE OBJECTS KATAS
(define-example-code  
  3d-orbit space-objects-1
  (define asteroids-list
    (list (basic-asteroid
           #:color 'red)
          (basic-asteroid
           #:opacity 0.7)
          (basic-asteroid
           #:label "Big Rock")))
  
  (orbit-scene
   #:star (basic-star)
   #:objects-list asteroids-list)
  )

(define-example-code  
  3d-orbit space-objects-2
  (define asteroids-list
    (list
     (basic-asteroid
      #:texture mars-tex)
     (basic-asteroid
      #:radius 0.5)
     (basic-asteroid
      #:on-mouse-click (do-many
                        (opacity 0)))))
  
  (orbit-scene
   #:star (basic-star
           #:objects-list asteroids-list))
   )

(define-example-code  
  3d-orbit space-objects-3
  (define my-planet
    (basic-planet
     #:objects-list (list
                     (basic-moon)
                     (basic-asteroid)
                     astronaut)))
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           my-planet)))
  )

(define-example-code  
  3d-orbit space-objects-4
  (define my-planet
    (basic-planet
     #:objects-list (list
                     (scale-object 0.5 satellite-1))))
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           my-planet)))
  )

(define-example-code  
  3d-orbit space-objects-5
  (define my-moon
    (basic-moon
     #:objects-list (list
                    flying-saucer-1)))

  (define my-planet
    (basic-planet
     #:moons-list (list my-moon)))
  
  (orbit-scene
   #:star (basic-star
           #:planets-list (list my-planet)))
  )

; ===== STAR SYSTEM KATAS
(define-example-code  
  3d-orbit star-system-1
  (define the-moon
    (basic-moon
     #:texture moon-tex
     #:label "Luna"))
  
  (define my-planets
    (list
     (basic-planet #:texture mercury-tex
                   #:label "Mercury")
     (basic-planet #:texture venus-tex
                   #:label "Venus")
     (basic-planet #:texture earth-tex
                   #:label "Earth"
                   #:moons-list (list the-moon))))
  
  (orbit-scene
   #:star (basic-star
           #:texture sun-tex
           #:label "Sol"
           #:planets-list my-planets))
  )

(define-example-code  
  3d-orbit star-system-2
  (define the-ring
    (basic-ring #:rotation (rotation 90 0 0)
                #:texture saturnring-tex
                #:radius 2
                #:thicknes 0.5))
     
  (define my-planets
    (list
     (basic-planet #:texture jupiter-tex
                   #:label "Jupiter")
     (basic-planet #:texture saturn-tex
                   #:label "Saturn"
                   #:rings-list (list the-ring))))
  
  (orbit-scene
   #:star (basic-star
           #:texture sun-tex
           #:label "Sol"
           #:planets-list my-planets))
  )

(define-example-code  
  3d-orbit star-system-3
  (define my-planets
    (list (basic-planet
           #:texture brick-tex
           #:label "Brick World")
          (basic-planet
           #:texture steel-tex
           #:label "Steel World")))
    
  (orbit-scene
   #:star (basic-star
           #:planets-list my-planets))
  )

(define-example-code  
  3d-orbit star-system-4
  (define moon-planet
    (basic-planet
     #:moons-list (list
                   (basic-moon
                    #:texture black-tex))))

  (define ring-planet
    (basic-planet
     #:rings-list (list
                   (basic-ring
                    #:texture pink-tex))))
    
  (orbit-scene
   #:star (basic-star
           #:planets-list (list
                           moon-planet
                           ring-planet)))
  )

(define-example-code  
  3d-orbit star-system-5
  (define my-planet
    (basic-planet
     #:texture purple-tex))
  
  (orbit-scene
   #:star (basic-star
           #:planets-list (list my-planet
                                my-planet))
   #:objects-list (list international-space-station
                        space-shuttle
                        asteroids))
  )

