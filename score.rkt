#lang r7rs

;; ================================
;; Score ADT
;; ================================

(import (scheme base)
        (scheme write))
(export maak-score classic-score bomb-score gravity-score)

(define (maak-score)
  (let ((score 0)
        (hoogste-score 0)) ;de initiele waarde van de score (zal veranderen)
  
    (define (geef-hoogste-score)
      (if (< score hoogste-score)          
          hoogste-score
          (begin
            (set! hoogste-score score)
            hoogste-score)))

    (define (reset-score!) ; zet de score opnieuw op 0
      (set! score 0))
  
    (define (verander-score! x)
      (set! score (+ score x)))
  
    ; Dispatcher
    (lambda (msg . args)
      (case msg
        ('geef-score score)
        ('geef-hoogste-score (geef-hoogste-score))
        ('reset-score! (reset-score!))
        ('verander-score! (verander-score! (car args)))
        (else (display "Error in score, msg is: ") (display msg))))))

(define classic-score (maak-score))
(define bomb-score (maak-score))
(define gravity-score (maak-score))