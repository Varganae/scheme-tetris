#lang r7rs

;; ================================
;; Tetromino ADT
;; ================================

(import (scheme base)
        (scheme cxr)
        (scheme write)
        (project constanten)
        (project game-data))

(export maak-tetromino)


(define (maak-tetromino type)
  (let* ((data (assoc type tetromino-data))
         (kleur (cadr data))
         (rotaties (caddr data))  ; lijst van 4 rotaties
         (state 0)  ; huidige rotatie
         (positie '(3 0)))  ; Startpositie in het midden bovenaan

    (define (geef-kleur) kleur)

    (define (geef-type) type)

    (define (geef-coordinaten)
      (let ((state-coordinaten (list-ref rotaties state)))
        (if (geldige-coordinaten? state-coordinaten)
            (map (lambda (p) (list (+ (car p) (car positie)) (+ (cadr p) (cadr positie))))
                 state-coordinaten)
            (error "FOUT: Ongeldige rotatie-coördinaten voor Tetromino!"))))

    (define (verplaats! dx dy)      
      (set! positie (list (+ (car positie) dx) (+ (cadr positie) dy))))

    (define (corrigeer-rotatie nieuwe-state)
      (let* ((nieuwe-coordinaten (map (lambda (p) ; zet de abstracte posities om in reele coordinaten
                                        (list (+ (car p) (car positie))
                                              (+ (cadr p) (cadr positie))))
                                      (list-ref rotaties nieuwe-state)))
             (min-x (apply min (map car nieuwe-coordinaten)))
             (max-x (apply max (map car nieuwe-coordinaten)))
             (min-y (apply min (map cadr nieuwe-coordinaten))) ; Check hoe hoog de Tetromino gaat
             (max-y (apply max (map cadr nieuwe-coordinaten))))

        ;; horizontale grenzen
        (cond
          ((< min-x 0) (verplaats! (- min-x) 0))  ;; Duw naar rechts als nodig
          ((> max-x (- spel-breedte 1)) (verplaats! (- (- spel-breedte 1) max-x) 0)))

        ;; Tetromino goed boven roteren
        (when (< min-y 0)
          (verplaats! 0 (- min-y)))  ; Duw Tetromino naar beneden zodat hij binnen speelruimte blijft

        ;; Tetromino niet onderaan draaien
        (when (> max-y (- spel-hoogte 1))
          (verplaats! 0 (- (- spel-hoogte 1) max-y)))))

    (define (roteer!)
      (let ((nieuwe-state (modulo (+ state 1) 4)))
        (set! state nieuwe-state)
        (corrigeer-rotatie nieuwe-state)))

    (define (laat-vallen!)
      "Laat de Tetromino direct vallen naar de eerst geldige positie."
      (let loop ()
        (if (some (lambda (p)
                    (let ((x (car p)) (y (cadr p)))
                      (or (>= y (- spel-hoogte 1)) ; Bereikt de bodem
                          (vector-ref (vector-ref grid (+ y 1)) x)))) ; Raakt ander blok
                  (geef-coordinaten))
            (verplaats! 0 0) ; Stop wanneer niet verder kan
            (begin
              (verplaats! 0 1) ; Blijf naar beneden bewegen
              (loop)))))
    
    (lambda (msg . args)
      (case msg
        ('geef-kleur (geef-kleur))
        ('geef-type (geef-type))
        ('geef-coordinaten (geef-coordinaten))
        ('roteer! (roteer!))
        ('verplaats! (apply verplaats! args))
        ('verplaats-links! (verplaats! -1 0))
        ('verplaats-rechts! (verplaats! 1 0))
        ('verplaats-omlaag! (verplaats! 0 1))
        ('laat-vallen! (laat-vallen!))
        (else (display "Error in maak-tetromino, msg is: ") (display msg))))))
