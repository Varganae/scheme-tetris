#lang r7rs

;; ================================
;; Status ADT
;; ================================

(import (scheme base)
        (scheme write))
(export maak-status status)

(define (maak-status)
  (let ((status 'menu)  ; mogelijke waarden: 'menu, 'spel, 'game-over, 'highlight
        (spelstatus 'classicmodus)  ; mogelijke waarden: 'classic, 'gravity, 'bomb        
        )
    
    (define (set-status! nieuw)
    (set! status nieuw))    
       
    (define (set-spelstatus! nieuw)
    (set! spelstatus nieuw))

        
  (lambda (msg . args)
    (case msg
      ('geef-status status)
      ('geef-spelstatus spelstatus)            
      ('set-status! (set-status! (car args)))
      ('set-spelstatus! (set-spelstatus! (car args)))     
      (else (display "Error in status, msg is: ") (display msg))))))

(define status (maak-status))