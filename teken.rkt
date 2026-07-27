#lang r7rs

;; ================================
;; TEKEN ADT
;; ================================

(import (scheme base)
        (scheme write)
        (scheme cxr)
        (pp1 graphics)
        (project constanten)        
        (project game-data)       
        (project status)
        (project score)
        (project data))

(export teken-adt teken)

(define (teken-adt)
  (let* ((venster (make-window venster-breedte-px venster-hoogte-px "Tetris"))
         (spelwereld-laag ((venster 'new-layer!)))
         (spelwereld-tile (make-tile (* spel-breedte cel-breedte-px)
                                     (* spel-hoogte cel-hoogte-px)))
         
         (achtergrond-laag ((venster 'new-layer!)))
         (achtergrond-tile (make-tile venster-breedte-px venster-hoogte-px))
         (classic-tile (make-bitmap-tile "images/classic.png"))
         (bomb-tile (make-bitmap-tile "images/bomb.png"))
         (gravity-tile (make-bitmap-tile "images/gravity.png"))
         (score-tile (make-tile 500 500))
         
         (menu-laag ((venster 'new-layer!)))
         
         (menu-tile (make-bitmap-tile "images/menu.png"))
         

         
         (tetromino-laag ((venster 'new-layer!)))

         (highlight-laag ((venster 'new-layer!)))

         (vasthouden-tile (make-tile 100 200))

         (voorvertoning-tile (make-tile 150 20))
         
         (level-tile (make-tile venster-hoogte-px venster-hoogte-px))

         (timer-laag ((venster 'new-layer!)))
         (timer-tile (make-tile venster-hoogte-px venster-hoogte-px))

         (game-over-laag ((venster 'new-layer!)))
         (game-over-tile (make-tile venster-breedte-px venster-hoogte-px))
         )

    
    ;; ===================
    ;; CALLBACKS
    ;; ===================
    (define (set-spel-lus-functie! fun)
      ((venster 'set-update-callback!) fun))
        
    (define (set-toets-functie! fun)
      ((venster 'set-key-callback!) fun))

    (define (set-teken-functie! menu spel game-over bomb)
      ((venster 'set-draw-callback!)
       (lambda ()
         (case (status 'geef-status)
           ((menu) ((game-over-tile 'clear!))
                   ((tetromino-laag 'empty!))
                   (menu))
           
           ((spel) ((menu-laag 'empty!))
                   (spel))
                     
           ((game-over) (game-over))
           
           (else (display "Onbekende status"))))))

    
    ;; ===================
    ;; HOOFDMENU
    ;; ===================
    (define (teken-hoofdmenu!)
      ((menu-tile 'clear!))
      ((menu-laag 'add-drawable!) menu-tile)      
            ((menu-tile 'draw-text!)
         (number->string (classic-score 'geef-hoogste-score))
         10 320 285 "white")
      ((menu-tile 'draw-text!)
         (number->string (bomb-score 'geef-hoogste-score))
         10 320 307 "white")
      ((menu-tile 'draw-text!)
         (number->string (gravity-score 'geef-hoogste-score))
         10 320 330 "white")
      )
    
   
    ;; ===================
    ;; ALGEMEEN
    ;; ===================
    ((venster 'set-background!) "brown")
    
    ((spelwereld-tile 'draw-rectangle!) 0 0 (* spel-breedte cel-breedte-px) (* spel-hoogte cel-hoogte-px) "black")

    ; Achtergrond en spelwereld toevoegen aan venster
    ((achtergrond-laag 'add-drawable!) achtergrond-tile) 
    ((spelwereld-laag 'add-drawable!) spelwereld-tile)

    ; Spelwereld centreren
    ((spelwereld-tile 'set-x!) (/ (- venster-breedte-px (* spel-breedte cel-breedte-px)) 2))
    ((spelwereld-tile 'set-y!) (/ (- venster-hoogte-px (* spel-hoogte cel-hoogte-px)) 2))

    
    ;; ===================
    ;; SCORE
    ;; ===================        
    ((achtergrond-laag 'add-drawable!) score-tile)
    (define (teken-score!)     
      ((score-tile 'clear!)) 
      ((score-tile 'draw-text!)
       (number->string (score 'geef-score))
       10 445 170 "white")
      ((score-tile 'draw-text!)
       (number->string (score 'geef-hoogste-score))
       10 445 275 "white"))  

    
    ;; ===================
    ;; TETROMINO
    ;; ===================     
    (define (teken-tetromino! tetromino)
      ((tetromino-laag 'empty!))
      (let ((coordinaten (tetromino 'geef-coordinaten))
            (kleur (tetromino 'geef-kleur)))
        ;(display "DEBUG: teken-tetromino ontvangt coördinaten: ") (display coordinaten) (newline)
        (if (and (list? coordinaten) (geldige-coordinaten? coordinaten) )
            (begin
              (for-each (lambda (p)
                          (let ((tile (make-tile cel-breedte-px cel-hoogte-px)))
                            ((tile 'draw-rectangle!) 0 0 cel-breedte-px cel-hoogte-px kleur)
                            ((tile 'set-x!) (+(* (car p) cel-breedte-px) zijpaneel-breedte))
                            ((tile 'set-y!) (* (cadr p) cel-hoogte-px))
                            ((tetromino-laag 'add-drawable!) tile)))
                        coordinaten))
            (error "FOUT: teken-tetromino! heeft geen geldige coördinaten ontvangen!"))))


    ;; ===================
    ;; ANNIMATIE
    ;; ===================
    (define (teken-highlight-tile! x y kleur)
      (let ((tile (make-tile cel-breedte-px cel-hoogte-px)))
        ((tile 'draw-rectangle!) 0 0 cel-breedte-px cel-hoogte-px kleur)
        ((tile 'set-x!) x)
        ((tile 'set-y!) y)
        tile))

    (define (teken-highlight-rij! rij kleur)
      (for-each
       (lambda (kolom)
         (let ((tile (teken-highlight-tile! (+ zijpaneel-breedte (* kolom cel-breedte-px))
                                            (* rij cel-hoogte-px)
                                            kleur)))
           ((highlight-laag 'add-drawable!) tile)))
       (iota spel-breedte)))

    (define (teken-highlight-rijen! rijen kleur)
      (clear-highlight-laag!)
      (for-each (lambda (rij)
                  (teken-highlight-rij! rij kleur))
                rijen))

    (define (clear-highlight-laag!)
      ((highlight-laag 'empty!)))

    
    ;; ===================
    ;; SPEELVELD
    ;; ===================
    (define (teken-speelveld!)
      (for-each 
       (lambda (y)
         (for-each 
          (lambda (x)
            (let ((kleur (vector-ref (vector-ref grid y) x)))
              (when kleur ;; Enkel tekenen als er een kleur in de cel zit
                (let ((tile (make-tile cel-breedte-px cel-hoogte-px)))
                  ((tile 'draw-rectangle!) 0 0 cel-breedte-px cel-hoogte-px kleur)
                  ((tile 'set-x!) (+ zijpaneel-breedte (* x cel-breedte-px)))
                  ((tile 'set-y!) (* y cel-hoogte-px))
                  ((tetromino-laag 'add-drawable!) tile)))))
          (iota spel-breedte)))
       (iota spel-hoogte)))

    
    ;; ===================
    ;; VOORVERTONING
    ;; ===================  
    (define (teken-voorvertoning! voorvertoning)
      (let ((tetrominos (voorvertoning 'kijk)))
        ((tetromino-laag 'add-drawable!) voorvertoning-tile)        
        (for-each
         (lambda (t index) ;; Gebruik index om ze onder elkaar te plaatsen
           (let ((coordinaten (t 'geef-coordinaten))
                 (kleur (t 'geef-kleur))
                 (offset-x -15) ;; Zet ze rechts van het speelveld
                 (offset-y (+ 305 (* index 3 vvt-cel-hoogte-px))))  ;; Zet elk Tetromino iets lager
        
             (for-each 
              (lambda (p)
                (let ((tile (make-tile vvt-cel-breedte-px vvt-cel-hoogte-px)))
                  ((tile 'draw-rectangle!) 0 0 vvt-cel-breedte-px cel-hoogte-px kleur)
                  ((tile 'set-x!) (+ offset-x (* (car p) vvt-cel-breedte-px)))
                  ((tile 'set-y!) (+ offset-y (* (cadr p) vvt-cel-hoogte-px)))
                  ((tetromino-laag 'add-drawable!) tile)))
              coordinaten)))
         tetrominos (iota (length tetrominos))))) ;; iota maakt een indexlijst aan


    ;; ===================
    ;; VASTHOUDEN
    ;; ===================
    (define (teken-vasthouden! vasthouder)
      (let ((offset-x 30)
            (offset-y 145))
        ((tetromino-laag 'add-drawable!) vasthouden-tile)
        (let ((t (vasthouder 'inhoud)))
          (when t
            (let* ((kleur (t 'geef-kleur))
                   (type (t 'geef-type))
                   (data (assoc type tetromino-data))
                   (coord (caaddr data)))                
              ;; Teken de tetromino
              (for-each
               (lambda (p)
                 (let ((tile (make-tile vvt-cel-breedte-px vvt-cel-hoogte-px)))
                   ((tile 'draw-rectangle!) 0 0 vvt-cel-breedte-px cel-hoogte-px kleur)
                   ((tile 'set-x!) (+ offset-x (* (car p) vvt-cel-breedte-px)))
                   ((tile 'set-y!) (+ offset-y (* (cadr p) vvt-cel-hoogte-px)))
                   ((tetromino-laag 'add-drawable!) tile)))
               coord))))))

    
    ;; ===================
    ;; LEVEL TEKENEN
    ;; ===================   
    ((achtergrond-laag 'add-drawable!) level-tile)

    (define (teken-level! level)
      ((level-tile 'clear!)) 
      ((level-tile 'draw-text!)
       (number->string (level 'geef-level))
       10 445 360 "white")      
      ((level-tile 'draw-text!)
       (number->string (level 'resterende-lijnen))
       10 440 455 "white"))
    

    ;; ===================
    ;; TIMER TEKENEN
    ;; ===================
      
    ((timer-laag 'add-drawable!) timer-tile)
    
    (define (teken-timer!)          
      ((timer-tile 'clear!))
      ((timer-tile 'draw-text!) (number->string (- 20000 bom-tijd))
                                    20 410 1 "red")) ;440

    (define (delete-timer!)
      ((timer-tile 'clear!)))
    
    
    ;; ===================
    ;; GAME OVER TEKENEN
    ;; ===================
    ((game-over-laag 'add-drawable!) game-over-tile)
    (define (teken-game-over!)
      ((game-over-tile 'draw-rectangle!) 0 0 venster-breedte-px venster-hoogte-px "black")
      ((game-over-tile 'draw-text!) "GAME OVER"
                                    40 100 1 "red")
      ((game-over-tile 'draw-text!) "Druk op b om naar het hoofdmenu te gaan"
                                    10 115 60 "white"))

    ;; ===================
    ;; WERELD TEKENEN
    ;; ===================
    (define (teken-wereld! tetromino)
      ;(teken-timer!)
      (teken-score!)
      (teken-tetromino! tetromino)
      (teken-speelveld!)
      (teken-voorvertoning! voorvertoning)
      (teken-vasthouden! vasthouder)
      (teken-level! level))

    (define (teken-classic-modus!)
      ((spelwereld-laag 'empty!))
      ((spelwereld-laag 'add-drawable!) classic-tile)
      ((venster 'set-title!) "Classic Tetris"))
    (define (teken-bomb-modus!)
      ((spelwereld-laag 'empty!))
      ((spelwereld-laag 'add-drawable!) bomb-tile)
      ((venster 'set-title!) "Bomb Tetris"))
    (define (teken-gravity-modus!)
      ((spelwereld-laag 'empty!))
      ((spelwereld-laag 'add-drawable!) gravity-tile)
      ((venster 'set-title!) "Gravity Tetris"))
      

    (define (teken-modus!)
      (cond ((eq? (status 'geef-spelstatus) 'bomb-modus)
             ((spelwereld-laag 'add-drawable!) bomb-tile)
             ((venster 'set-title!) "Bomb Tetris"))
            
            ((eq? (status 'geef-spelstatus) 'classic-modus)
             ((spelwereld-laag 'add-drawable!) classic-tile)
             ((venster 'set-title!) "Classic Tetris"))
            
            ((eq? (status 'geef-spelstatus) 'gravity-modus)
             ((spelwereld-laag 'add-drawable!) gravity-tile)
             ((venster 'set-title!) "Gravity Tetris"))

            (else (display "error"))))



    (define (dispatch-teken msg . args)
      (case msg
        ('venster venster)
        ('set-spel-lus-functie! (set-spel-lus-functie! (car args)))
        ('set-toets-functie! (set-toets-functie! (car args)))
        ('set-teken-functie! (set-teken-functie! (car args) (cadr args) (caddr args) (cadddr args)))
        ('teken-hoofdmenu! (teken-hoofdmenu!))
        ('teken-score! (teken-score! ))
        ('teken-tetromino! (teken-tetromino! (car args)))
        
        ('teken-highlight-rijen! (teken-highlight-rijen! (car args) (cadr args) ))
        ('clear-highlight-laag! (clear-highlight-laag! ))

        ('teken-modus! (teken-modus!))
        ('teken-classic-modus! (teken-classic-modus!))
        ('teken-bomb-modus! (teken-bomb-modus!))
        ('teken-gravity-modus! (teken-gravity-modus!))
        ('teken-speelveld! (teken-speelveld!))
        ('teken-voorvertoning! (teken-voorvertoning! (car args)))
        ('teken-vasthouden! (teken-vasthouden! (car args)))
        ('teken-level! (teken-level! (car args)))

        ('teken-timer! (teken-timer!))
        ('delete-timer! (delete-timer!))
        
        ('teken-game-over! (teken-game-over!))
        ('teken-wereld! (teken-wereld! (car args) ))
        (else (display "Error in teken-adt, msg is: ") (display msg))))
    dispatch-teken))


(define teken (teken-adt))