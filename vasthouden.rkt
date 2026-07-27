#lang r7rs

;; ================================
;; Vasthouden ADT
;; ================================

(define-library (vasthouden)  
  (import (scheme base)
          (scheme write))
  (export maak-vasthouden classic-vasthouder bomb-vasthouder gravity-vasthouder)

  (begin
    (define (maak-vasthouden)
      (let ((inhoud #f)
            (toegestaan? #t))

        (define (stel-in! nieuwe-tetromino)
          (set! inhoud nieuwe-tetromino)
          (set! toegestaan? #f))
        
        (define (wissel-met! huidige)
          (let ((oude inhoud))
            (set! inhoud huidige)
            (set! toegestaan? #f)
            oude))

        (define (reset!)
          (set! toegestaan? #t))
        
        (define (reset-alles!)
          (set! inhoud #f)
          (set! toegestaan? #t))
        
        (lambda (msg . args)
          (case msg
            ('inhoud inhoud)
            ('toegestaan? toegestaan?)
            ('stel-in! (stel-in! (car args)))
            ('wissel-met! (wissel-met! (car args)))
            ('reset! (reset!))
            ('reset-alles! (reset-alles!))
            (else (display "Error in vasthouden, msg is: ") (display msg))))
        
        ))
    ))

(define classic-vasthouder (maak-vasthouden))
(define bomb-vasthouder (maak-vasthouden))
(define gravity-vasthouder (maak-vasthouden))