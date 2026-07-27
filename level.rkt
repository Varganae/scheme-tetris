#lang r7rs
(import (scheme base)
        (scheme write))
(export maak-level classic-level bomb-level gravity-level)

(define (maak-level)
  (let ((level 0)
        (totaal-verwijderde-lijnen 0))
    
    (define (verhoog-verwijderde-lijnen! aantal)
      (set! totaal-verwijderde-lijnen (+ totaal-verwijderde-lijnen aantal))
      (set! level (quotient totaal-verwijderde-lijnen 10))) ;;;;;;


    (define (resterende-lijnen) (- 10 (modulo totaal-verwijderde-lijnen 10)))

    (define (reset-level!)
      (set! level 0)
      (set! totaal-verwijderde-lijnen 0))

    (lambda (msg . args)
      (case msg
        ('geef-level level)
        ('verhoog-verwijderde-lijnen! (verhoog-verwijderde-lijnen! (car args)))
        ('resterende-lijnen (resterende-lijnen))
        ('reset-level! (reset-level!))
        (else (display "Error in Level, msg is: ") (display msg))))))

(define classic-level (maak-level))
(define bomb-level (maak-level))
(define gravity-level (maak-level))