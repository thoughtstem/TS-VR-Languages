#lang at-exp racket

(require scribble/srcdoc)
(require (for-doc racket/base scribble/manual))

(require (except-in vr-engine
                    basic-ring)
         "../assets.rkt"
         image-coloring
         ts-kata-util)

(provide random-scale
         random-color
         random-rotation
         random-range
         x-rotation
         y-rotation
         z-rotation

         basic-star
         basic-planet
         basic-ring
         basic-moon
         basic-asteroid

         star-sun
         planet-mercury
         planet-venus
         planet-earth
         moon-moon
         planet-mars
         planet-jupiter
         planet-saturn
         planet-uranus
         planet-neptune

         solar-system
         planets-to-scale)

; ==== GENENRIC FUNCTIONS ====
(define (random-float min max #:factor [factor 10])
  (real->double-flonum (/ (random  (exact-round (* min factor)) (exact-round (* max factor))) factor)))

(define (random-scale [min 0.5] [max 5.0])
  (define scale-val (random-float min max))
  (scale scale-val scale-val scale-val))

(define (random-color)
  (color (random 256) (random 256) (random 256)))

(define (random-rotation)
  (rotation (random 360) (random 360) (random 360)))

(define (random-range t f)
  (define offset (- f t))
  (* (+ (random 0 offset) offset) (first (shuffle (list -1 1)))))

(define (x-rotation [spd 20000])
  (animate-rotation
   #:duration spd
   #:to (position 360 0 0)))

(define (z-rotation [spd 20000])
  (animate-rotation
   #:duration spd
   #:to (position 0 0 360)))

(define (y-rotation [spd 20000])
  (animate-rotation
   #:duration spd))

(define (get-distance a b)
  (define a-list (string-split (render a) " "))
  (define ax (string->number (first  a-list)))
  (define ay (string->number (second a-list)))
  (define az (string->number (third  a-list)))
  (define b-list (string-split (render b) " "))
  (define bx (string->number (first  b-list)))
  (define by (string->number (second b-list)))
  (define bz (string->number (third  b-list)))
  (sqrt (+ (expt (- ax bx) 2) (expt (- ay by) 2) (expt (- az bz) 2))))

(define (position-attribute? attr)
  (is-a? attr position%))

(define (radius-attribute? attr)
  (is-a? attr radius%))

; ==== SPACE ORBIT =====
(define/contract/doc (space-orbit #:fly-speed      [speed 750]
                                  #:fly-mode?      [fly-mode #t]
                                  #:universe       [universe (basic-universe)]
                                  #:star           [star #f]
                                  ;#:planets        [planets '()]
                                  #:objects        [objects '()]
                                  . other-entities)
  ; === TODO: Fix contract
  (->i ()
       (#:fly-speed      [speed positive?]
        #:fly-mode?      [fly-mode boolean?]
        #:universe       [universe any/c]
        #:star           [star any/c]
        ;#:planets        [planets any/c]
        #:objects        [objects any/c])
       #:rest           [more-objects any/c]
       [returns any/c])

  @{The top-level function for the 3d-orbit language.
         Can be run with no parameters to get a basic, default orbit.}
  
  (define (randomize-position e)
    (define old-attrs (entity-attrs e))
    (define new-attrs (append (list (position (random-float -80 80)
                                              (random-float  20 60)
                                              (random-float -80 80)))
                              (filter-not position-attribute? old-attrs)))
    (update-attributes e new-attrs))
  
  (define (asset-eq? a1 a2)
    (equal? (send (findf (curryr is-a? id%) (entity-attrs a1)) render)
            (send (findf (curryr is-a? id%) (entity-attrs a2)) render)))

  (define (obj-model? e)
    (equal? (entity-name e) "obj-model"))

  (define (gltf-model? e)
    (equal? (entity-name e) "gltf-model"))
  
  (define (model->assets-items model)
    ;Note, calling render will save it twice
    (cond [(obj-model? model) (let ([src-str (send (findf (curryr is-a? src%) (entity-attrs model)) render)]
                                    [mtl-str (send (findf (curryr is-a? mtl%) (entity-attrs model)) render)])
                                (list (assets-item #:components-list
                                                   (list (id (string-replace src-str "." "-"))
                                                         (src src-str)))
                                      (assets-item #:components-list
                                                   (list (id (string-replace mtl-str "." "-"))
                                                         (src mtl-str)))))]
          [(gltf-model? model) (let ([src-str (send (findf (curryr is-a? src%) (entity-attrs model)) render)])
                                 (list (assets-item #:components-list
                                                    (list (id (string-replace src-str "." "-"))
                                                          (src src-str)))))]
          [else (error "That wasn't a valid model file")]
          ))

  (define (assetize-model e)
    (define old-attrs (entity-attrs e))
    (define (src-or-mtl? attr)
      (or (is-a? attr src%)
          (is-a? attr mtl%)))
    (define new-src (src (~a "#" (string-replace (send (findf (curryr is-a? src%) old-attrs) render)
                                                 "." "-"))))
    (define new-mtl (if (findf (curryr is-a? mtl%) old-attrs)
                        (mtl (~a "#" (string-replace (send (findf (curryr is-a? mtl%) old-attrs) render)
                                                     "." "-")))
                        #f))
    (define new-attrs (append (filter identity (list new-src
                                                     new-mtl))
                              (filter-not src-or-mtl? old-attrs)))
    (update-attributes e new-attrs))

  (define object-model-list (filter (or/c obj-model?
                                          gltf-model?) objects))
  
  (define assets-manager
    (assets #:components-list
            (remove-duplicates (flatten (map model->assets-items object-model-list))
                               asset-eq?)))

  (define assetized-object-models (map assetize-model object-model-list))

  (define modified-objects (map randomize-position
                                (append (filter-not (or/c obj-model?
                                                          gltf-model?) objects)
                                        assetized-object-models)))
  
  (vr-scene universe
            (basic-camera #:fly? fly-mode
                          #:acceleration speed
                          #:cursor (basic-cursor #:color (color 0 255 255)
                                                 #:opacity 0.5))
            (filter identity (append (list assets-manager)
                                     modified-objects
                                     (list star)
                                     ;planets
                                     other-entities) )))

; ===== SPACE OBJECTS

(define (basic-universe #:universe-color [bg-color 'black]
                        #:star-color [star-color 'white]
                        #:star-count [count 10000]
                        #:star-depth [dep 250]
                        #:star-radius [rad 250]
                        #:star-size [size 1.0]
                        #:star-texture [texture ""])
  (list (basic-sky #:color bg-color
                   #:radius (* 2 rad))
        (basic-stars #:color     star-color
                     #:count     count
                     #:depth     dep
                     #:radius    rad
                     #:star-size size
                     #:texture   texture)))

(define (basic-star #:position        [pos (position 0 0 -30)]
                    #:rotation        [rota (rotation 0.0 0.0 0.0)]
                    #:scale           [sca (scale 1.0 1.0 1.0)]
                    #:color           [col (color 255 255 255)]
                    #:texture         [texture sun-bg]
                    #:radius          [r (random 8 15)]
                    #:opacity         [opac 1.0]
                    #:show-orbits?    [orbits? #f]
                    #:animations-list [animations-list (do-many (y-rotation))]
                    #:planets-list    [p-list '()]
                    #:on-mouse-enter  [mouse-enter #f]
                    #:on-mouse-leave  [mouse-leave #f]
                    #:on-mouse-click  [mouse-click #f]
                    )

  (define (make-orbit l)
    (define n-list (map string->number l))
    (basic-ring #:rotation (rotation 90 0 0)
                #:radius (get-distance (position (first n-list)
                                                 (second n-list)
                                                 (third n-list))
                                       (position 0 0 0))
                #:thicknes 0.05
                #:opacity 1.0
                #:color 'white))
  
  (define (add-orbits)
    (define (filter-position-from planet)
      (filter position-attribute? (entity-attrs planet)))
    (define posn-attr-list (flatten (map filter-position-from p-list)))
    (define posn-str-list (map string-split (map render posn-attr-list)))
    (map make-orbit posn-str-list))
  
  (basic-sphere #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture
                #:radius          r
                #:opacity         opac
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:components-list (if orbits?
                                      (append (add-orbits)
                                              p-list)
                                      p-list)))

(define (basic-ring  #:rotation [rota (rotation 0 0 0)]
                     #:radius   [rad (random-float 0.25 1.5 #:factor 100)]
                     #:thicknes [rt (random-float 0.015 0.05 #:factor 1000)]
                     #:opacity  [opa (random-float 0.25 1.0 #:factor 100)]
                     #:color    [c (random-color)]
                     #:texture  [texture #f])
  (basic-torus #:rotation       rota
               #:radius         rad
               #:radius-tubular rt
               #:opacity        (if texture
                                    1.0
                                    opa)
               #:color          (if texture
                                    'white
                                    c)
               #:texture        texture))

(define (basic-planet #:position        [pos (position (random-range 25 75) 0 (random-range 25 75))]
                      #:rotation        [rota (rotation 0.0 0.0 0.0)]
                      #:scale           [sca (scale 1.0 1.0 1.0)]
                      #:color           [col (color 255 255 255)]
                      #:texture         [texture (first (shuffle (list mercury-bg
                                                                       venus-bg
                                                                       earth-bg
                                                                       earthnight-bg
                                                                       mars-bg
                                                                       jupiter-bg
                                                                       saturn-bg
                                                                       uranus-bg
                                                                       neptune-bg)))]
                      #:radius          [r (random 1 5)]
                      #:opacity         [opac 1.0]
                      #:rings-list      [r-list '()]
                      #:moons-list      [m-list '()]
                      #:animations-list [animations-list (do-many (x-rotation))]
                      #:on-mouse-enter  [mouse-enter #f]
                      #:on-mouse-leave  [mouse-leave #f]
                      #:on-mouse-click  [mouse-click #f])

  (define (adjust-radius e)
    (define old-attrs (entity-attrs e))
    (define (filter-radius-from e)
      (filter radius-attribute? (entity-attrs e)))
    (define old-r (string->number (render (first (filter-radius-from e)))))
    (define new-attrs (append (list (radius (+ r  old-r)))
                              (filter-not radius-attribute? old-attrs)))
    (update-attributes e new-attrs))
    
  (basic-sphere #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture
                #:radius          r
                #:opacity         opac
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:components-list (append m-list
                                          (map adjust-radius r-list))))

(define (basic-moon #:position        [pos (position 0 (random-range 7 12) (random-range 7 12))]
                    #:rotation        [rota (rotation 0.0 0.0 0.0)]
                    #:scale           [sca (scale 1.0 1.0 1.0)]
                    #:color           [col (color 255 255 255)]
                    #:texture         [texture moon-bg]
                    #:radius          [r (random-float 0.25 0.75 #:factor 100)]
                    #:opacity         [opac 1.0]
                    #:animations-list [animations-list (do-many (y-rotation))]
                    #:on-mouse-enter  [mouse-enter #f]
                    #:on-mouse-leave  [mouse-leave #f]
                    #:on-mouse-click  [mouse-click #f]
                    #:components-list [c '()])
  (basic-sphere #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture
                #:radius          r
                #:opacity         opac
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:components-list c))

(define (basic-asteroid #:position        [pos (position 0 (random-range 7 12) (random-range 7 12))]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture (first (shuffle (list (tint-img 'brown asteroid-bg)
                                                                         (tint-img 'black asteroid-bg)
                                                                         (tint-img 'grey asteroid-bg)
                                                                         (tint-img 'white asteroid-bg)
                                                                         asteroid-bg)))]
                        #:radius          [r (random-float 0.1 0.3 #:factor 100)]
                        #:opacity         [opac 1.0]
                        #:animations-list [animations-list (do-many (y-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f]
                        #:components-list [c '()])
  (basic-dodecahedron #:position        pos
                      #:rotation        rota
                      #:scale           sca
                      #:color           col
                      #:texture         texture
                      #:radius          r
                      #:opacity         opac
                      #:animations-list animations-list
                      #:on-mouse-enter  mouse-enter
                      #:on-mouse-leave  mouse-leave
                      #:on-mouse-click  mouse-click
                      #:components-list c))

; ====== SUN AND PLANETS ======
(define (star-sun #:position        [pos (position 0 0 -250)]
                  #:rotation        [rota (rotation 0.0 0.0 0.0)]
                  #:scale           [sca (scale 1.0 1.0 1.0)]
                  #:color           [col (color 255 255 255)]
                  #:texture         [texture sun-bg]
                  #:radius          [r 109]
                  #:opacity         [opac 1.0]
                  #:show-orbits?    [orbits? #f]
                  #:animations-list [animations-list (do-many (y-rotation))]
                  #:planets-list    [p-list '()]
                  #:on-mouse-enter  [mouse-enter #f]
                  #:on-mouse-leave  [mouse-leave #f]
                  #:on-mouse-click  [mouse-click #f])
  (basic-star #:position        pos
              #:rotation        rota
              #:scale           sca
              #:color           col
              #:texture         texture
              #:radius          r
              #:opacity         opac
              #:show-orbits?    orbits?
              #:animations-list animations-list
              #:planets-list    p-list
              #:on-mouse-enter  mouse-enter
              #:on-mouse-leave  mouse-leave
              #:on-mouse-click  mouse-click))

(define (planet-mercury #:position        [pos (position 0 0 2)]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture mercury-bg]
                        #:radius          [r 0.38]
                        #:opacity         [opac 1.0]
                        #:rings-list      [r-list '()]
                        #:moons-list      [m-list '()]
                        #:animations-list [animations-list (do-many (x-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (planet-venus #:position        [pos (position 0 0 3)]
                      #:rotation        [rota (rotation 0.0 0.0 0.0)]
                      #:scale           [sca (scale 1.0 1.0 1.0)]
                      #:color           [col (color 255 255 255)]
                      #:texture         [texture venus-bg]
                      #:radius          [r 0.95]
                      #:opacity         [opac 1.0]
                      #:rings-list      [r-list '()]
                      #:moons-list      [m-list '()]
                      #:animations-list [animations-list (do-many (x-rotation))]
                      #:on-mouse-enter  [mouse-enter #f]
                      #:on-mouse-leave  [mouse-leave #f]
                      #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (planet-earth #:position        [pos (position 0 0 3)]
                      #:rotation        [rota (rotation 0.0 0.0 0.0)]
                      #:scale           [sca (scale 1.0 1.0 1.0)]
                      #:color           [col (color 255 255 255)]
                      #:texture         [texture earth-bg]
                      #:radius          [r 1]
                      #:opacity         [opac 1.0]
                      #:rings-list      [r-list '()]
                      #:moons-list      [m-list '()]
                      #:animations-list [animations-list (do-many (x-rotation))]
                      #:on-mouse-enter  [mouse-enter #f]
                      #:on-mouse-leave  [mouse-leave #f]
                      #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (moon-moon #:position        [pos (position 0 0 2)]
                   #:rotation        [rota (rotation 0.0 0.0 0.0)]
                   #:scale           [sca (scale 1.0 1.0 1.0)]
                   #:color           [col (color 255 255 255)]
                   #:texture         [texture moon-bg]
                   #:radius          [r 0.27]
                   #:opacity         [opac 1.0]
                   #:animations-list [animations-list (do-many (y-rotation))]
                   #:on-mouse-enter  [mouse-enter #f]
                   #:on-mouse-leave  [mouse-leave #f]
                   #:on-mouse-click  [mouse-click #f]
                   #:components-list [c '()])
  (basic-moon #:position        pos
              #:rotation        rota
              #:scale           sca
              #:color           col
              #:texture         texture
              #:radius          r
              #:opacity         opac
              #:animations-list animations-list
              #:on-mouse-enter  mouse-enter
              #:on-mouse-leave  mouse-leave
              #:on-mouse-click  mouse-click
              #:components-list c))

(define (planet-mars #:position        [pos (position 0 0 3)]
                     #:rotation        [rota (rotation 0.0 0.0 0.0)]
                     #:scale           [sca (scale 1.0 1.0 1.0)]
                     #:color           [col (color 255 255 255)]
                     #:texture         [texture mars-bg]
                     #:radius          [r 0.53]
                     #:opacity         [opac 1.0]
                     #:rings-list      [r-list '()]
                     #:moons-list      [m-list '()]
                     #:animations-list [animations-list (do-many (x-rotation))]
                     #:on-mouse-enter  [mouse-enter #f]
                     #:on-mouse-leave  [mouse-leave #f]
                     #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (planet-jupiter #:position        [pos (position 0 0 23)]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture jupiter-bg]
                        #:radius          [r 11.19]
                        #:opacity         [opac 1.0]
                        #:rings-list      [r-list '()]
                        #:moons-list      [m-list '()]
                        #:animations-list [animations-list (do-many (x-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (planet-saturn #:position        [pos (position 0 0 21)]
                       #:rotation        [rota (rotation 0.0 0.0 0.0)]
                       #:scale           [sca (scale 1.0 1.0 1.0)]
                       #:color           [col (color 255 255 255)]
                       #:texture         [texture saturn-bg]
                       #:radius          [r 9.4]
                       #:opacity         [opac 1.0]
                       #:rings-list      [r-list (list (basic-ring #:rotation (rotation 45 90 0)
                                                                   #:texture saturnring-bg
                                                                   #:radius 1.6
                                                                   #:thicknes 0.45)
                                                       (basic-ring #:rotation (rotation 45 90 0)
                                                                   #:texture saturnring-bg
                                                                   #:radius 2.6
                                                                   #:thicknes 0.45)
                                                       (basic-ring #:rotation (rotation 45 90 0)
                                                                   #:texture saturnring-bg
                                                                   #:radius 3.6
                                                                   #:thicknes 0.45))]
                       #:moons-list      [m-list '()]
                       #:animations-list [animations-list (do-many (x-rotation))]
                       #:on-mouse-enter  [mouse-enter #f]
                       #:on-mouse-leave  [mouse-leave #f]
                       #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (planet-uranus #:position        [pos (position 0 0 9)]
                       #:rotation        [rota (rotation 0.0 0.0 0.0)]
                       #:scale           [sca (scale 1.0 1.0 1.0)]
                       #:color           [col (color 255 255 255)]
                       #:texture         [texture uranus-bg]
                       #:radius          [r 4.04]
                       #:opacity         [opac 1.0]
                       #:rings-list      [r-list '()]
                       #:moons-list      [m-list '()]
                       #:animations-list [animations-list (do-many (x-rotation))]
                       #:on-mouse-enter  [mouse-enter #f]
                       #:on-mouse-leave  [mouse-leave #f]
                       #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

(define (planet-neptune #:position        [pos (position 0 0 9)]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture neptune-bg]
                        #:radius          [r 3.88]
                        #:opacity         [opac 1.0]
                        #:rings-list      [r-list '()]
                        #:moons-list      [m-list '()]
                        #:animations-list [animations-list (do-many (x-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click))

; ===== PLANETS TO SCALE =====
; RADIUS: earth = 1 unit
(define (planets-to-scale)
  (space-orbit
   #:fly-speed 1000
   #:universe (basic-universe #:star-depth 500
                              #:star-radius 400)
   #:star (star-sun #:position (position 0 0 -250)
                    #:animations-list '()
                    #:planets-list (list (planet-mercury  #:position (position (+ 109 .38) 0 0))
                                         (planet-venus    #:position (position (+ 109 (* 2 .38) .95) 0 0))
                                         (planet-earth    #:position (position (+ 109 (* 2 (+ .38 .95)) 1) 0 0)
                                                          #:moons-list (list
                                                                        (moon-moon #:position (position 0 (+ 1 .27) 0))))
                                         (planet-mars     #:position (position (+ 109 (* 2 (+ .38 .95 1)) .53) 0 0))
                                         (planet-jupiter  #:position (position (+ 109 (* 2 (+ .38 .95 1 .53)) 11.19) 0 0))
                                         (planet-saturn   #:position (position (+ 109 (* 2 (+ .38 .95 1 .53 11.19)) 9.4) 0 0))
                                         (planet-uranus   #:position (position (+ 109 (* 2 (+ .38 .95 1 .53 11.19 9.4)) 4.04) 0 0))
                                         (planet-neptune  #:position (position (+ 109 (* 2 (+ .38 .95 1 .53 11.19 9.4 4.04)) 3.88) 0 0))))))

; ===== SOLAR SYSTEM =====
;Planets 100x smaller
;Sun      10x bigger
(define (solar-system)
  (space-orbit
   #:fly-speed 1000
   #:universe (basic-universe #:star-depth 5000
                              #:star-radius 5000
                              #:star-size 2)
   #:star (star-sun #:position (position 0 0 -50)
                    #:radius 5.762
                    #:show-orbits? #t
                    #:planets-list (list (planet-mercury #:position (position 48 0 0)
                                                         #:radius 0.202)
                                         (planet-venus #:position (position 89.6 0 0)
                                                       #:radius 0.501)
                                         (planet-earth #:position (position 124 0 0)
                                                       #:radius 0.528
                                                       #:moons-list (list
                                                                       (moon-moon #:position (position 2 0 0)
                                                                                  #:radius 0.072)))
                                         (planet-mars #:position (position 188.8 0 0)
                                                      #:radius 0.281)
                                         (planet-jupiter #:position (position 644.8 0 0)
                                                         #:radius 5.915)
                                         (planet-saturn #:position (position 1182.27 0 0)
                                                        #:radius 4.973)
                                         (planet-uranus #:position (position 2378.67 0 0)
                                                        #:radius 2.173)
                                         (planet-neptune #:position (position 3725.87 0 0)
                                                         #:radius 2.013)))))

