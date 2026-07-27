#lang r7rs

;; ================================
;; CONSTANTEN ADT
;; ================================

(define-library ()
  (import (scheme base)
          )

  (export cel-breedte-px
          cel-hoogte-px
          vvt-cel-breedte-px
          vvt-cel-hoogte-px          
          spel-breedte
          spel-hoogte
          zijpaneel-breedte
          venster-breedte-px
          venster-hoogte-px
          tetromino-data
          linkerbordure
          rechterbordure
          )

  (begin
    ;; ===================
    ;; SPELWERELD
    ;; ===================
    (define cel-breedte-px 30)
    (define cel-hoogte-px 30)

    (define vvt-cel-breedte-px 15)
    (define vvt-cel-hoogte-px 15)

    (define spel-breedte 10)
    (define spel-hoogte 20)
    

    ; Extra ruimte aan zijkanten voor decoratie, scorebord, ...
    (define zijpaneel-breedte 100)

    (define venster-breedte-px (+ (* cel-breedte-px spel-breedte) (* 2 zijpaneel-breedte))) ; Extra ruimte links en rechts
    (define venster-hoogte-px (* cel-hoogte-px spel-hoogte))

    ;; ===================
    ;; BORDURES
    ;; ===================
    (define linkerbordure (/ (- venster-breedte-px (* spel-breedte cel-breedte-px)) 
                             (* 2 cel-breedte-px)))  ;; Bereken offset in raster-coördinaten
    (define rechterbordure (+ linkerbordure spel-breedte))  ;; Rechtergrens is offset + breedte
    

    ;; ===================
    ;; TETROMINO
    ;; ===================
    (define tetromino-data
      '((I "cyan"   (((0 0) (1 0) (2 0) (3 0))
                     ((1 -1) (1 0) (1 1) (1 2))
                     ((0 0) (1 0) (2 0) (3 0))
                     ((2 -1) (2 0) (2 1) (2 2))))
        
        (O "yellow" (((0 0) (1 0) (0 1) (1 1))
                     ((0 0) (1 0) (0 1) (1 1))
                     ((0 0) (1 0) (0 1) (1 1))
                     ((0 0) (1 0) (0 1) (1 1))))
        
        (T "purple" (((0 0) (1 0) (2 0) (1 1))
                     ((1 0) (1 -1) (1 1) (2 0))
                     ((0 0) (1 0) (2 0) (1 -1))
                     ((1 0) (1 -1) (1 1) (0 0))))

        (L "orange" (((0 1) (1 1) (2 1) (2 0))
                     ((0 0) (1 0) (1 1) (1 2))
                     ((0 1) (0 2) (1 1) (2 1))
                     ((1 0) (1 1) (1 2) (2 2))))

        (B "white" ( ((0 0) (1 0))
                    ((0 0) (1 0))
                    ((0 0) (1 0))
                    ((0 0) (1 0)) ))
        
        (J "blue"   (((0 0) (0 1) (1 1) (2 1))
                     ((1 0) (1 1) (1 2) (0 2))
                     ((0 1) (1 1) (2 1) (2 2))
                     ((1 0) (2 0) (1 1) (1 2))))
        
        (S "green"  (((1 0) (2 0) (0 1) (1 1))
                     ((0 0) (0 1) (1 1) (1 2))
                     ((1 1) (2 1) (0 2) (1 2))
                     ((1 0) (1 1) (2 1) (2 2))))
       
        (Z "red"    (((0 0) (1 0) (1 1) (2 1))
                     ((1 0) (1 1) (0 1) (0 2))
                     ((0 1) (1 1) (1 2) (2 2))
                     ((2 0) (2 1) (1 1) (1 2))))

        
        ))
    ))

;(display "Vensterbreedte: ") (display venster-breedte-px) (newline)
;(display "Spelwereldbreedte: ") (display (* spel-breedte cel-breedte-px)) (newline)
;(display "Linkerbordure: ") (display linkerbordure) (newline)
;(display "Rechterbordure: ") (display rechterbordure) (newline)