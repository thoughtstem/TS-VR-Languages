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
         scale-object
         tilt

         basic-universe
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
         planets-to-scale
         stars-to-scale)

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

(define (scale-attribute? attr)
  (is-a? attr scale%))

(define (tilt x y z)
  (rotation x y z))

(define (randomize-position e)
  (define old-attrs (entity-attrs e))
  (define new-attrs (append (list (position (random-float -80 80)
                                            (random-float  20 60)
                                            (random-float -80 80)))
                            (filter-not position-attribute? old-attrs)))
  (update-attributes e new-attrs))

(define (randomize-xz-posn e)
  (define old-attrs (entity-attrs e))
  (define new-attrs (append (list (position (random-float -80 80)
                                            0
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

(define (change-position? e)
  (define attrs (entity-attrs e))
  (define pos-attr (filter position-attribute? attrs))
  (if (empty? pos-attr)
      #t
      (if (= (+ (first (map string->number (string-split (render (first pos-attr)))))
                (second (map string->number (string-split (render (first pos-attr)))))
                (third (map string->number (string-split (render (first pos-attr))))))
             0)
          #t
          #f)))

(define (scale-object s e)
  (define old-attrs (entity-attrs e))
  (define sca-attr (filter scale-attribute? old-attrs))
  (define sca-xyz (map string->number (string-split (render (first sca-attr)))))
  (define new-attrs (append (list (if (number? s)
                                      (scale
                                       (* s (first  sca-xyz))
                                       (* s (second sca-xyz))
                                       (* s (third  sca-xyz)))
                                      s))
                            (filter-not scale-attribute? old-attrs)))
  (update-attributes e new-attrs))
  

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

(define (make-orbit l xyz)
  (define n-list (map string->number l))
  (basic-ring #:tilt (cond
                       [(equal? "x" xyz) (rotation 90 0 0)]
                       [(equal? "y" xyz) (rotation 0 90 0)]
                       [(equal? "z" xyz) (rotation 0 0 90)])
              #:radius (get-distance (position (first n-list)
                                               (second n-list)
                                               (third n-list))
                                     (position 0 0 0))
              #:thicknes 0.05
              #:opacity 1.0
              #:color 'white))

  
(define (add-orbits a-list xyz)
  (define (filter-position-from obj)
    (filter position-attribute? (entity-attrs obj)))
  (define posn-attr-list (flatten (map filter-position-from a-list)))
  (define posn-str-list (map string-split (map render posn-attr-list)))
  (define xyz-list (make-list (length posn-str-list) xyz))
  (map make-orbit posn-str-list xyz-list))

; ==== SPACE ORBIT =====
(define/contract/doc (orbit-scene #:fly-speed       [speed 750]
                                  #:fly-mode?       [fly-mode #t]
                                  #:start-position  [start (position 0 1.6 0)]
                                  #:universe        [universe (basic-universe)]
                                  #:star            [star '()]
                                  ;#:planets         [planets '()]
                                  #:objects-list    [objects '()]
                                  . other-entities)
  ; === TODO: Fix contract
  (->i ()
       (#:fly-speed      [speed positive?]
        #:fly-mode?      [fly-mode boolean?]
        #:start-position [start position-attribute?]
        #:universe       [universe (listof entity?)]
        #:star           [star entity?]
        ;#:planets        [planets any/c]
        #:objects-list   [objects list?])
       #:rest           [more-objects any/c]
       [returns any/c])

  @{The top-level function for the 3d-orbit language.
         Can be run with no parameters to get a basic, default orbit.}
   
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

  

  (define object-model-list (filter (or/c obj-model?
                                          gltf-model?) objects))

  (define regular-objects-list (filter-not (or/c obj-model?
                                                 gltf-model?) objects))
  
  (define assets-manager
    (assets #:components-list
            (remove-duplicates (flatten (map model->assets-items object-model-list))
                               asset-eq?)))

  (define assetized-object-models (map assetize-model object-model-list))

  (define all-objects
    (append regular-objects-list
            assetized-object-models))
  
  (define modified-objects (append (map randomize-position (filter change-position?
                                                                   all-objects))
                                   (filter-not change-position? all-objects)))
  
  (vr-scene universe
            (basic-camera #:position start
                          #:fly? fly-mode
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
                    #:texture         [texture (first (shuffle (list (tint-img 'brown sun-tex)
                                                                     (tint-img 'red sun-tex)
                                                                     (tint-img 'darkred sun-tex)
                                                                     (tint-img 'lightred sun-tex)
                                                                     (tint-img 'orange sun-tex)
                                                                     (tint-img 'darkorange sun-tex)
                                                                     (tint-img 'lightorange sun-tex)
                                                                     (tint-img 'yellow sun-tex)
                                                                     (tint-img 'darkyellow sun-tex)
                                                                     (tint-img 'lightyellow sun-tex)
                                                                     (tint-img 'salmon sun-tex)
                                                                     (tint-img 'purple sun-tex)
                                                                     (tint-img 'white sun-tex)
                                                                     sun-tex)))]
                    #:radius          [r (random 8 15)]
                    #:opacity         [opac 1.0]
                    #:show-orbits?    [orbits? #f]
                    #:label           [l #f]
                    #:label-color     [lc 'white]
                    #:label-position  [lp (position 0 r 0)]
                    #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                    #:animations-list [animations-list (do-many (y-rotation))]
                    #:planets-list    [p-list '()]
                    #:on-mouse-enter  [mouse-enter #f]
                    #:on-mouse-leave  [mouse-leave #f]
                    #:on-mouse-click  [mouse-click #f]
                    #:objects-list [c-list '()])

  (define label
    (if l
        (list (basic-text #:scale ls
                          #:position lp
                          #:value l
                          #:color lc
                          #:baseline 'bottom))
        '()))

  (define modified-planets (append (map randomize-xz-posn (filter change-position?
                                                                  p-list))
                                   (filter-not change-position? p-list)))


   (define (add-radius e)
    (define old-attrs (entity-attrs e))
    (define pos-attr (filter position-attribute? old-attrs))
    (if (empty? pos-attr)
        (update-attributes e (append (list (position (+ (random-range 20 50) r)
                                                     0
                                                     (+ (random-range 20 50) r)))
                                     (filter-not position-attribute? old-attrs)))    
        
        (update-attributes e (append (list (position (+ (first (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (second (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (third (map string->number (string-split (render (first pos-attr))))) r)))
                                     (filter-not position-attribute? old-attrs)))    
        ))
  
  (define modified-objects
    (map add-radius c-list))
    
  
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
                #:components-list (append (if orbits?
                                              (if (empty? p-list)
                                                  '()
                                                  (add-orbits p-list "x"))
                                              '())
                                          modified-planets
                                          modified-objects
                                          label)))

(define (basic-ring  #:tilt     [tilt (rotation 0 0 0)]
                     #:radius   [rad (random-float 0.25 1.5 #:factor 100)]
                     #:thicknes [rt (random-float 0.015 0.05 #:factor 1000)]
                     #:opacity  [opa (random-float 0.25 1.0 #:factor 100)]
                     #:color    [c (random-color)]
                     #:texture  [texture #f])
  (basic-torus #:rotation       tilt
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
                      #:texture         [texture (first (shuffle (list mercury-tex
                                                                       venus-tex
                                                                       earth-tex
                                                                       earthnight-tex
                                                                       mars-tex
                                                                       jupiter-tex
                                                                       saturn-tex
                                                                       uranus-tex
                                                                       neptune-tex)))]
                      #:radius          [r (random 1 5)]
                      #:opacity         [opac 1.0]
                      #:rings-list      [r-list '()]
                      #:moons-list      [m-list '()]
                      #:label           [l #f]
                      #:label-color     [lc 'white]
                      #:label-position  [lp (position 0 r 0)]
                      #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                      #:show-orbits?    [orbits? #f]
                      #:animations-list [animations-list (do-many (x-rotation))]
                      #:on-mouse-enter  [mouse-enter #f]
                      #:on-mouse-leave  [mouse-leave #f]
                      #:on-mouse-click  [mouse-click #f]
                      #:objects-list    [c-list '()])

  (define (adjust-radius e)
    (define old-attrs (entity-attrs e))
    (define (filter-radius-from e)
      (filter radius-attribute? (entity-attrs e)))
    (define old-r (string->number (render (first (filter-radius-from e)))))
    (define new-attrs (append (list (radius (+ r  old-r)))
                              (filter-not radius-attribute? old-attrs)))
    (update-attributes e new-attrs))

  (define label
    (if l
        (list (basic-text #:scale ls
                          #:position lp
                          #:value l
                          #:color lc
                          #:baseline 'bottom))
        '()))

  (define modified-moons (append (map randomize-position (filter change-position?
                                                                 m-list))
                                 (filter-not change-position? m-list)))

   (define (add-radius e)
    (define old-attrs (entity-attrs e))
    (define pos-attr (filter position-attribute? old-attrs))
    (if (empty? pos-attr)
        (update-attributes e (append (list (position 0
                                                     (+ (random-range 5 10) r)
                                                     (+ (random-range 5 10) r)))
                                     (filter-not position-attribute? old-attrs)))    
        
        (update-attributes e (append (list (position (+ (first (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (second (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (third (map string->number (string-split (render (first pos-attr))))) r)))
                                     (filter-not position-attribute? old-attrs)))    
        ))
  
  (define modified-objects
    (map add-radius c-list))
    
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
                #:components-list (append modified-moons
                                          modified-objects
                                          (if (empty? r-list)
                                              '()
                                              (map adjust-radius r-list))
                                          (if orbits?
                                              (if (empty? m-list)
                                                  '()
                                                  (add-orbits m-list "y"))
                                              '())
                                          label)))

(define (basic-moon #:position        [pos (position 0 (random-range 7 12) (random-range 7 12))]
                    #:rotation        [rota (rotation 0.0 0.0 0.0)]
                    #:scale           [sca (scale 1.0 1.0 1.0)]
                    #:color           [col (color 255 255 255)]
                    #:texture         [texture moon-tex]
                    #:radius          [r (random-float 0.25 0.75 #:factor 100)]
                    #:opacity         [opac 1.0]
                    #:label           [l #f]
                    #:label-color     [lc 'white]
                    #:label-position  [lp (position 0 r 0)]
                    #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                    #:animations-list [animations-list (do-many (y-rotation))]
                    #:on-mouse-enter  [mouse-enter #f]
                    #:on-mouse-leave  [mouse-leave #f]
                    #:on-mouse-click  [mouse-click #f]
                    #:objects-list    [c-list '()])

  (define label
    (if l
        (list (basic-text #:scale ls
                          #:position lp
                          #:value l
                          #:color lc
                          #:baseline 'bottom))
        '()))

   (define (add-radius e)
    (define old-attrs (entity-attrs e))
    (define pos-attr (filter position-attribute? old-attrs))
    (if (empty? pos-attr)
        (update-attributes e (append (list (position (+ (random-range 1 3) r)
                                                     0
                                                     (+ (random-range 1 3) r)))
                                     (filter-not position-attribute? old-attrs)))    
        
        (update-attributes e (append (list (position (+ (first (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (second (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (third (map string->number (string-split (render (first pos-attr))))) r)))
                                     (filter-not position-attribute? old-attrs)))    
        ))
  
  (define modified-objects
    (map add-radius c-list))
  
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
                #:components-list (append modified-objects label)))

(define (basic-asteroid #:position        [pos (position 0 (random-range 7 12) (random-range 7 12))]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture (first (shuffle (list (tint-img 'brown asteroid-tex)
                                                                         (tint-img 'black asteroid-tex)
                                                                         (tint-img 'grey asteroid-tex)
                                                                         (tint-img 'white asteroid-tex)
                                                                         asteroid-tex)))]
                        #:radius          [r (random-float 0.1 0.3 #:factor 100)]
                        #:opacity         [opac 1.0]
                        #:label           [l #f]
                        #:label-color     [lc 'white]
                        #:label-position  [lp (position 0 r 0)]
                        #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                        #:animations-list [animations-list (do-many (y-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f]
                        #:objects-list    [c-list '()])

  (define label
    (if l
        (list (basic-text #:scale ls
                          #:position lp
                          #:value l
                          #:color lc
                          #:baseline 'bottom))
        '()))

  (define (add-radius e)
    (define old-attrs (entity-attrs e))
    (define pos-attr (filter position-attribute? old-attrs))
    (if (empty? pos-attr)
        (update-attributes e (append (list (position (+ (random-range 1 3) r)
                                                     0
                                                     (+ (random-range 1 3) r)))
                                     (filter-not position-attribute? old-attrs)))    
        
        (update-attributes e (append (list (position (+ (first (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (second (map string->number (string-split (render (first pos-attr))))) r)
                                                     (+ (third (map string->number (string-split (render (first pos-attr))))) r)))
                                     (filter-not position-attribute? old-attrs)))    
        ))
  
  (define modified-objects
    (map add-radius c-list))
  
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
                      #:components-list (append modified-objects label)))

; ====== SUN AND PLANETS ======
(define (star-sun #:position        [pos (position 0 0 -250)]
                  #:rotation        [rota (rotation 0.0 0.0 0.0)]
                  #:scale           [sca (scale 1.0 1.0 1.0)]
                  #:color           [col (color 255 255 255)]
                  #:texture         [texture sun-tex]
                  #:radius          [r 109]
                  #:opacity         [opac 1.0]
                  #:show-orbits?    [orbits? #f]
                  #:label           [l "Sun"]
                  #:label-color     [lc 'white]
                  #:label-position  [lp (position 0 r 0)]
                  #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                  #:animations-list [animations-list (do-many (y-rotation))]
                  #:planets-list    [p-list '()]
                  #:on-mouse-enter  [mouse-enter #f]
                  #:on-mouse-leave  [mouse-leave #f]
                  #:on-mouse-click  [mouse-click #f]
                  #:objects-list    [o-list '()])
  (basic-star #:position        pos
              #:rotation        rota
              #:scale           sca
              #:color           col
              #:texture         texture
              #:radius          r
              #:opacity         opac
              #:show-orbits?    orbits?
              #:label           l
              #:label-color     lc
              #:label-position  lp
              #:label-scale     ls
              #:animations-list animations-list
              #:planets-list    p-list
              #:on-mouse-enter  mouse-enter
              #:on-mouse-leave  mouse-leave
              #:on-mouse-click  mouse-click
              #:objects-list o-list))

(define (planet-mercury #:position        [pos (position 0 0 2)]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture mercury-tex]
                        #:radius          [r 0.38]
                        #:opacity         [opac 1.0]
                        #:rings-list      [r-list '()]
                        #:moons-list      [m-list '()]
                        #:label           [l "Mercury"]
                        #:label-color     [lc 'white]
                        #:label-position  [lp (position 0 r 0)]
                        #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                        #:animations-list [animations-list (do-many (x-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f]
                        #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (planet-venus #:position        [pos (position 0 0 3)]
                      #:rotation        [rota (rotation 0.0 0.0 0.0)]
                      #:scale           [sca (scale 1.0 1.0 1.0)]
                      #:color           [col (color 255 255 255)]
                      #:texture         [texture venus-tex]
                      #:radius          [r 0.95]
                      #:opacity         [opac 1.0]
                      #:rings-list      [r-list '()]
                      #:moons-list      [m-list '()]
                      #:label           [l "Venus"]
                      #:label-color     [lc 'white]
                      #:label-position  [lp (position 0 r 0)]
                      #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                      #:animations-list [animations-list (do-many (x-rotation))]
                      #:on-mouse-enter  [mouse-enter #f]
                      #:on-mouse-leave  [mouse-leave #f]
                      #:on-mouse-click  [mouse-click #f]
                      #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (planet-earth #:position        [pos (position 0 0 3)]
                      #:rotation        [rota (rotation 0.0 0.0 0.0)]
                      #:scale           [sca (scale 1.0 1.0 1.0)]
                      #:color           [col (color 255 255 255)]
                      #:texture         [texture earth-tex]
                      #:radius          [r 1]
                      #:opacity         [opac 1.0]
                      #:rings-list      [r-list '()]
                      #:moons-list      [m-list '()]
                      #:label           [l "Earth"]
                      #:label-color     [lc 'white]
                      #:label-position  [lp (position 0 r 0)]
                      #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                      #:animations-list [animations-list (do-many (x-rotation))]
                      #:on-mouse-enter  [mouse-enter #f]
                      #:on-mouse-leave  [mouse-leave #f]
                      #:on-mouse-click  [mouse-click #f]
                      #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (moon-moon #:position        [pos (position 0 0 2)]
                   #:rotation        [rota (rotation 0.0 0.0 0.0)]
                   #:scale           [sca (scale 1.0 1.0 1.0)]
                   #:color           [col (color 255 255 255)]
                   #:texture         [texture moon-tex]
                   #:radius          [r 0.27]
                   #:opacity         [opac 1.0]
                   #:label           [l "Moon"]
                   #:label-color     [lc 'white]
                   #:label-position  [lp (position 0 r 0)]
                   #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                   #:animations-list [animations-list (do-many (y-rotation))]
                   #:on-mouse-enter  [mouse-enter #f]
                   #:on-mouse-leave  [mouse-leave #f]
                   #:on-mouse-click  [mouse-click #f]
                   #:objects-list    [c '()])
  (basic-moon #:position        pos
              #:rotation        rota
              #:scale           sca
              #:color           col
              #:texture         texture
              #:radius          r
              #:opacity         opac
              #:label           l
              #:label-color     lc
              #:label-position  lp
              #:label-scale     ls
              #:animations-list animations-list
              #:on-mouse-enter  mouse-enter
              #:on-mouse-leave  mouse-leave
              #:on-mouse-click  mouse-click
              #:objects-list    c))

(define (planet-mars #:position        [pos (position 0 0 3)]
                     #:rotation        [rota (rotation 0.0 0.0 0.0)]
                     #:scale           [sca (scale 1.0 1.0 1.0)]
                     #:color           [col (color 255 255 255)]
                     #:texture         [texture mars-tex]
                     #:radius          [r 0.53]
                     #:opacity         [opac 1.0]
                     #:rings-list      [r-list '()]
                     #:moons-list      [m-list '()]
                     #:label           [l "Mars"]
                     #:label-color     [lc 'white]
                     #:label-position  [lp (position 0 r 0)]
                     #:label-scale     [ls (scale (* 2 r) (* 2 r) 10)]
                     #:animations-list [animations-list (do-many (x-rotation))]
                     #:on-mouse-enter  [mouse-enter #f]
                     #:on-mouse-leave  [mouse-leave #f]
                     #:on-mouse-click  [mouse-click #f]
                     #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (planet-jupiter #:position        [pos (position 0 0 23)]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture jupiter-tex]
                        #:radius          [r 11.19]
                        #:opacity         [opac 1.0]
                        #:rings-list      [r-list '()]
                        #:moons-list      [m-list '()]
                        #:label           [l "Jupiter"]
                        #:label-color     [lc 'white]
                        #:label-position  [lp (position 0 r 0)]
                        #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                        #:animations-list [animations-list (do-many (x-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f]
                        #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (planet-saturn #:position        [pos (position 0 0 21)]
                       #:rotation        [rota (rotation 0.0 0.0 0.0)]
                       #:scale           [sca (scale 1.0 1.0 1.0)]
                       #:color           [col (color 255 255 255)]
                       #:texture         [texture saturn-tex]
                       #:radius          [r 9.4]
                       #:opacity         [opac 1.0]
                       #:rings-list      [r-list (list (basic-ring #:tilt (rotation 45 90 0)
                                                                   #:texture saturnring-tex
                                                                   #:radius 1.6
                                                                   #:thicknes 0.45)
                                                       (basic-ring #:tilt (rotation 45 90 0)
                                                                   #:texture saturnring-tex
                                                                   #:radius 2.6
                                                                   #:thicknes 0.45)
                                                       (basic-ring #:tilt (rotation 45 90 0)
                                                                   #:texture saturnring-tex
                                                                   #:radius 3.6
                                                                   #:thicknes 0.45))]
                       #:moons-list      [m-list '()]
                       #:label           [l "Saturn"]
                       #:label-color     [lc 'white]
                       #:label-position  [lp (position 0 r 0)]
                       #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                       #:animations-list [animations-list (do-many (x-rotation))]
                       #:on-mouse-enter  [mouse-enter #f]
                       #:on-mouse-leave  [mouse-leave #f]
                       #:on-mouse-click  [mouse-click #f]
                       #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (planet-uranus #:position        [pos (position 0 0 9)]
                       #:rotation        [rota (rotation 0.0 0.0 0.0)]
                       #:scale           [sca (scale 1.0 1.0 1.0)]
                       #:color           [col (color 255 255 255)]
                       #:texture         [texture uranus-tex]
                       #:radius          [r 4.04]
                       #:opacity         [opac 1.0]
                       #:rings-list      [r-list '()]
                       #:moons-list      [m-list '()]
                       #:label           [l "Uranus"]
                       #:label-color     [lc 'white]
                       #:label-position  [lp (position 0 r 0)]
                       #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                       #:animations-list [animations-list (do-many (x-rotation))]
                       #:on-mouse-enter  [mouse-enter #f]
                       #:on-mouse-leave  [mouse-leave #f]
                       #:on-mouse-click  [mouse-click #f]
                       #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

(define (planet-neptune #:position        [pos (position 0 0 9)]
                        #:rotation        [rota (rotation 0.0 0.0 0.0)]
                        #:scale           [sca (scale 1.0 1.0 1.0)]
                        #:color           [col (color 255 255 255)]
                        #:texture         [texture neptune-tex]
                        #:radius          [r 3.88]
                        #:opacity         [opac 1.0]
                        #:rings-list      [r-list '()]
                        #:moons-list      [m-list '()]
                        #:label           [l "Neptune"]
                        #:label-color     [lc 'white]
                        #:label-position  [lp (position 0 r 0)]
                        #:label-scale     [ls (scale (* 2 r) (* 2 r) 1)]
                        #:animations-list [animations-list (do-many (x-rotation))]
                        #:on-mouse-enter  [mouse-enter #f]
                        #:on-mouse-leave  [mouse-leave #f]
                        #:on-mouse-click  [mouse-click #f]
                        #:objects-list    [o-list '()])
  (basic-planet #:position        pos
                #:rotation        rota
                #:scale           sca
                #:color           col
                #:texture         texture 
                #:radius          r
                #:opacity         opac
                #:rings-list      r-list
                #:moons-list      m-list
                #:label           l
                #:label-color     lc
                #:label-position  lp
                #:label-scale     ls
                #:animations-list animations-list
                #:on-mouse-enter  mouse-enter
                #:on-mouse-leave  mouse-leave
                #:on-mouse-click  mouse-click
                #:objects-list o-list))

; ===== PLANETS TO SCALE =====
; RADIUS: earth = 1 unit
(define (planets-to-scale)
  (orbit-scene
   #:fly-speed 1000
   #:universe (basic-universe #:star-depth 500
                              #:star-radius 400)
   #:star (star-sun #:position (position 0 0 -250)
                    #:animations-list '()
                    #:planets-list (list (planet-mercury  #:position (position (+ 109 .38) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         (planet-venus    #:position (position (+ 109 (* 2 .38) .95) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         (planet-earth    #:position (position (+ 109 (* 2 (+ .38 .95)) 1) 0 0)
                                                          #:animations-list (do-many (y-rotation))
                                                          #:moons-list (list
                                                                        (moon-moon #:position (position 0 (+ 1 (* 2 .27)) 0))))
                                         (planet-mars     #:position (position (+ 109 (* 2 (+ .38 .95 1)) .53) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         (planet-jupiter  #:position (position (+ 109 (* 2 (+ .38 .95 1 .53)) 11.19) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         (planet-saturn   #:position (position (+ 109 (* 2 (+ .38 .95 1 .53 11.19)) 9.4) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         (planet-uranus   #:position (position (+ 109 (* 2 (+ .38 .95 1 .53 11.19 9.4)) 4.04) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         (planet-neptune  #:position (position (+ 109 (* 2 (+ .38 .95 1 .53 11.19 9.4 4.04)) 3.88) 0 0)
                                                          #:animations-list (do-many (y-rotation)))
                                         ))))

; ===== SOLAR SYSTEM =====
;Planets 100x smaller
;Sun      10x bigger
(define (solar-system)
  (orbit-scene
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

(define (stars-to-scale)
  (orbit-scene
   #:start-position (position 250 50 275)
   #:universe (basic-universe #:star-depth 1200
                              #:star-radius 1200
                              #:star-size 2)
   #:objects-list (list (basic-star #:position (position 0 0 -250)
                                    #:radius .1
                                    #:texture sun-tex
                                    #:label "Sun")
                        ;proximacentauri 0.1542 -- nearest star to the sun
                        (basic-star #:position (position (+ .1 0.015) 0 -250)
                                    #:radius 0.015
                                    #:label "Proxima Centauri")
                        ;siriusa 1.711 -- brightest star in the sky
                        (basic-star #:position (position (+ .1 (* 2 0.015) .171) 0 -250)
                                    #:radius .171
                                    #:label "Sirius A")
                        ;pollux 8.8 -- closest giant star
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171)) .88) 0 -250)
                                    #:radius .88
                                    #:label "Pollux")
                        ;arcturus 25.4 -- brightest in the northern celestial hemisphere
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88)) 2.54) 0 -250)
                                    #:radius 2.54
                                    #:label "Arcturus")
                        ;aldebaran 44.13 -- 14th brightest star
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54)) 4.413) 0 -250)
                                    #:radius 4.413
                                    #:label "Aldebaran")
                        ;rigel 78.9 -- 7th brighstest star
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54 4.413)) 7.89) 0 -250)
                                    #:radius 7.89
                                    #:label "Rigel")
                        ;antares 740 -- 15th brightest star
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54 4.413 7.89)) 74) 0 -250)
                                    #:radius 74
                                    #:label "Antares")
                        ;betelgeuse 887 -- 11th brightest star
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54 4.413 7.89 74)) 88.7) 0 -250)
                                    #:radius 88.7
                                    #:label "Betelgeuse")
                        ;mucephei 1260 -- 100,000 times brighter than the Sun
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54 4.413 7.89 74 88.7)) 126) 0 -250)
                                    #:radius 126
                                    #:label "Mucephei")
                        ;vvcephei 1400 -- is an eclipsing binary star system
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54 4.413 7.89 74 88.7 126)) 140) 0 -250)
                                    #:radius 140
                                    #:label "VV Cephei")
                        ;uyscuti 1708 -- one of the largest known stars
                        (basic-star #:position (position (+ .1 (* 2 (+ 0.015 .171 .88 2.54 4.413 7.89 74 88.7 126 140)) 170.8) 0 -250)
                                    #:radius 170.8
                                    #:label "UY Scuti")
                        )))