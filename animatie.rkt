#lang r7rs

;; ================================
;; Animatie ADT
;; ================================

(import (scheme base)
        (scheme write)
        )
(export maak-animatie animatie)

(define (maak-animatie)
  (let ((highlight-rijen '())
        (highlight-timer 0)
        (highlight-fase 0)
        (highlight-aan? #f)
        )

    (define (set-highlight-rijen! x)
      (set! highlight-rijen x))
    (define (set-highlight-timer! x)
      (set! highlight-timer x))

    (define (toggle-highlight-aan!)
      (set! highlight-aan? (not highlight-aan?)))

    (define (inc-highlight-fase!)
      (set! highlight-fase (+ highlight-fase 1)))   

    (define (reset-highlight!)
      (set! highlight-fase 0)
      (set! highlight-aan? #f)
      (set! highlight-timer 0))
    
    
    (lambda (msg . args)
      (case msg
        ('highlight-rijen highlight-rijen)
        ('highlight-timer highlight-timer)
        ('highlight-fase highlight-fase)
        ('highlight-aan? highlight-aan?)
        ('set-highlight-rijen! (set-highlight-rijen! (car args)))
        ('set-highlight-timer! (set-highlight-timer! (car args)))        
        ('toggle-highlight-aan! (toggle-highlight-aan!))
        ('inc-highlight-fase! (inc-highlight-fase!))        
        ('reset-highlight! (reset-highlight!))
        (else (display "Error in animatie, msg is: ") (display msg))))))

(define animatie (maak-animatie))