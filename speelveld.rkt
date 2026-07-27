#lang r7rs

;; ================================
;; SPEELVELD ADT
;; ================================

(define-library (project speelveld)
  (import (scheme base)
          (scheme write)
          (project game-data)          
          (project constanten)          
          (project animatie)
          (project status)
          (project data))

  (export maak-speelveld)

  (begin
    (define (maak-speelveld)
      (define (geldige-coordinaat? x y)
        (if (or (< x 0) (>= x spel-breedte) (< y 0) (>= y spel-hoogte)) ; check als binnen het speelveld
            #f ; Buiten raster = ongeldig
            (let ((cel (vector-ref (vector-ref grid y) x)))
              ;(display " - Huidige waarde: ") (display cel) (display " : ") (display (not cel)) (newline)
              (not cel)))) ; #f = vrij vakje

      (define (binnen-bordures? tetromino dx dy)
        (let ((nieuwe-coordinaten (map (lambda (coord)
                                         (list (+ (car coord) dx) (+ (cadr coord) dy)))
                                       (tetromino 'geef-coordinaten)))) ; geeft de coordinaten weer na beweging
          (every (lambda (p)
                   (geldige-coordinaat? (car p) (cadr p))) nieuwe-coordinaten))) ; elke nieuwe coordinaat moet een geldige coordinaat zijn

      (define (zet-vast! tetromino)        
        (for-each (lambda (coord)
                    (let ((x (car coord))
                          (y (cadr coord)))
                      (when (geldige-coordinaat? x y)
                        (vector-set! (vector-ref grid y) x (tetromino 'geef-kleur)) ; grid wordt geset!
                        ;(display "Blok gezet op: ") (display x) (display ", ") (display y) (newline)
                        )))
                  (tetromino 'geef-coordinaten))
        )

      ;; ===================
      ;; LIJNDETECTIE
      ;; ===================
      (define (rij-vol? y)
        (every (lambda (x) (vector-ref (vector-ref grid y) x)) (iota spel-breedte)))

      (define (detecteer-volle-rijen)
        (filter rij-vol? (iota spel-hoogte)))     

      (define (verwijder-volle-rijen!)
        (let* ((volle-rijen (detecteer-volle-rijen+bom))
               (nieuwe-grid (make-vector spel-hoogte (make-vector spel-breedte #f))) ; Nieuwe lege grid
               (huidige-y (- spel-hoogte 1)) ; Start helemaal beneden van speelveld
               (doel-y (- spel-hoogte 1))) ; Rij waar we data naartoe kopiëren

          ;(display "Volle rijen: ") (display volle-rijen) (newline)
 
          ;; Recursie op raster van onder naar boveen
          (let loop ((oude-y huidige-y) (nieuwe-y doel-y))
            (if (< oude-y 0) ; helemaal boven
                (set-grid! nieuwe-grid) ; Update grid na verplaatsen
                (if (member oude-y volle-rijen) ; Is deze oude-y een volle rij?                
                    (loop (- oude-y 1) nieuwe-y) ; Dan sla je hem over → niet kopiëren → effectief verwijderd!
                    (begin ; niet vol 
                      (vector-set! nieuwe-grid nieuwe-y (vector-ref grid oude-y)) ; Kopieer de rij van het oude naar het nieuwe grid
                      (loop (- oude-y 1) (- nieuwe-y 1)))))
            ;(display "GRID NA VERWIJDERING:\n")
            (for-each (lambda (rij) (display rij) (newline)) (vector->list nieuwe-grid))
            )))
      ;  Ga naar de volgende rij erboven En verlaag de doelpositie (nieuwe-y)

      (define (verwijder-en-update-score!)
        (let* ((alle-verwijderde-rijen (detecteer-volle-rijen+bom))
               (volle-rijen (filter rij-vol? alle-verwijderde-rijen))               
               (bonus-rijen (filter (lambda (y) (not (rij-vol? y))) alle-verwijderde-rijen))
               (aantal (length volle-rijen))
               (basis-punten (case aantal
                               ((1) 1)
                               ((2) 3)
                               ((3) 6)
                               ((4) 12)
                               (else 0)))               
         
               ;; Bonuspunten voor bomlijnen (onvolledige)
               (bonus-punten (* (length bonus-rijen) 2)) ; bv. 2 punten per onvolledige lijn
               (totaal-punten (+ basis-punten bonus-punten)))          

          ;; Level verhogen op basis van échte volle lijnen
          (level 'verhoog-verwijderde-lijnen! aantal)
          (if (null? alle-verwijderde-rijen)
              (display "Geen rijen om te verwijderen.\n")
              (begin
                ;(display "Volle rijen: ") (display volle-rijen) (newline)
                ;(display "Bonuslijnen: ") (display bonus-rijen) (newline)
                ;(display "Highlightfase gestart.\\n")
                (animatie 'reset-highlight!)
                (animatie 'set-highlight-rijen! alle-verwijderde-rijen)
                (status 'set-status! 'highlight)
                ;; Score verhogen volgens beide systemen
                (score 'verander-score! totaal-punten)))))
      
      
      ;; ===================
      ;; BOMB TETRIS
      ;; ===================
      (define (explodeer-bom! coords)
        (for-each
         (lambda (coord)
           (let ((x (car coord))
                 (y (cadr coord)))
             (for-each
              (lambda (dx)
                (for-each
                 (lambda (dy)
                   (let ((nx (+ x dx))
                         (ny (+ y dy)))
                     (when (and (<= 0 nx) (< nx spel-breedte)
                                (<= 0 ny) (< ny spel-hoogte))
                       (vector-set! (vector-ref grid ny) nx #f))))
                 '(-2 -1 0 1 2))
                )
              '(-2 -1 0 1 2))
             ))
         coords))
      
      (define (bevat-coordinaten? coordinaten)
        (define (coördinaat-actief? x y)
          (and (<= 0 y) (< y spel-hoogte)
               (<= 0 x) (< x spel-breedte)
               (not (eq? (vector-ref (vector-ref grid y) x) #f))))
        
        (let loop ((coords coordinaten))
          (cond
            ((null? coords) #t)
            ((not (coördinaat-actief? (car (car coords)) (cadr (car coords)))) #f)
            (else (loop (cdr coords))))))

      (define (geldig-index? y)
        (and (>= y 0) (< y spel-hoogte)))
      (define (bomcel? cel)
        (equal? cel "white")) ; Enige vereiste is kleur = white

      (define (rij-bevat-bom? y)
        (let loop ((x 0))
          (cond ((>= x spel-breedte) #f)
                ((bomcel? (vector-ref (vector-ref grid y) x)) #t)
                (else (loop (+ x 1))))))
      
      (define (verwijder-duplicaten lst)
        (let loop ((rest lst) (acc '()))
          (cond
            ((null? rest) acc)
            ((member (car rest) acc) (loop (cdr rest) acc))
            (else (loop (cdr rest) (cons (car rest) acc))))))
      (define (detecteer-volle-rijen+bom)
        (let ((volle (filter rij-vol? (iota spel-hoogte))))
          (let loop ((rest volle) (extra '()))
            (if (null? rest)
                (verwijder-duplicaten (append volle extra))
                (let* ((y (car rest))
                       (boven (- y 1))
                       (onder (+ y 1))
                       (nieuw-extra
                        (if (rij-bevat-bom? y)
                            (filter geldig-index? (list boven onder))
                            '())))
                  (loop (cdr rest) (append extra nieuw-extra)))))))


      ;; ===================
      ;; GRAVITY TETRIS
      ;; ===================
      (define (vind-zwevende-blokken)
        (define zwevend '())
        (let loop-x ((x 0))
          (when (< x breedte)
            (let loop-y ((y (- hoogte 1)) (ondersteund? #t))
              (when (>= y 0)
                (let ((cel (vector-ref (vector-ref grid y) x)))
                  (cond
                    ((not cel)  ; leeg vakje
                     (loop-y (- y 1) #f))
                    (ondersteund?
                     (loop-y (- y 1) #t)) ; ondersteund, niks doen
                    (else ; blokje, maar niet ondersteund
                     (set! zwevend (cons (list x y) zwevend))
                     (loop-y (- y 1) #f))))))
            (loop-x (+ x 1))))
        (display "ZWEVENDE BLOKKEN GEVONDEN: ") (display zwevend) (newline)
        zwevend)

      (define (laat-vallen! blokken)
        (let loop ()
          (define nieuwe-positie '())
          (define iets-bewoog? #f)
          (for-each
           (lambda (blok)
             (let ((x (car blok))
                   (y (cadr blok)))
               (when (and (< (+ y 1) hoogte)
                          (vrij? x (+ y 1)))
                 (let ((kleur (vector-ref (vector-ref grid y) x)))
                   (vector-set! (vector-ref grid y) x #f)
                   (vector-set! (vector-ref grid (+ y 1)) x kleur))
                 (set! nieuwe-positie (cons (list x (+ y 1)) nieuwe-positie))
                 (set! iets-bewoog? #t))))
           blokken)
          (when iets-bewoog?
            (display "Er is iets bewogen!") (newline)
            (loop)))
        (verwijder-en-update-score!)
        ;; check if rij --> verander animatie + verwijder rij
        )

      
      (lambda (msg . args)
        (case msg
          ('laat-vallen! (laat-vallen! (car args) ))
          ('vind-zwevende-blokken (vind-zwevende-blokken ))          
          ('binnen-bordures? (apply binnen-bordures? args))
          ('zet-vast! (apply zet-vast! args))
          ('toon (display grid))
          ('detecteer-volle-rijen (detecteer-volle-rijen))
          ('verwijder-volle-rijen! (verwijder-volle-rijen!))
          ('verwijder-en-update-score! (verwijder-en-update-score!))
          
          ('explodeer-bom! (apply explodeer-bom! args))
          ('bevat-coordinaten? (apply bevat-coordinaten? args))

          
          (else (display "Error in speelveld, msg is: ") (display msg))
          )))
    ))
