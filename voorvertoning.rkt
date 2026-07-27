#lang r7rs

;; ================================
;; Voorvertoning ADT
;; ================================

(define-library (project voorvertoning)
  (import (scheme base)
          (scheme write)
          (project tetromino)
          )
  
  (export maak-voorvertoning classic-voorvertoning bomb-voorvertoning gravity-voorvertoning)
  
  (begin
    (#%require (only racket random))
    
    (define (maak-voorvertoning)
      (let* ((typen '(I J L O S T Z))
             (bomb-typen '(I J L O S T Z B))                         
             )
        (define (random-typen)
          (list-ref typen (random (length typen))))
        
        (define (set-typen! lst)
          (set! typen lst))


        (define volgende-tetrominos
          (map (lambda (_) (maak-tetromino (random-typen)))
               '(1 2 3)))
                
        
        (define (haal-volgende-tetromino vanuit-wisselen?)
          (let ((eerste (car volgende-tetrominos)))
            (if (not vanuit-wisselen?)
                (set! volgende-tetrominos
                      (append (cdr volgende-tetrominos) 
                              (list (maak-tetromino (random-typen))))))
            eerste))    

        (define (kijk) volgende-tetrominos)

        (lambda (msg . args)
          (case msg
            ('typen typen)
            ('set-typen! (set-typen! (car args)))
            ('haal-volgende-tetromino (apply haal-volgende-tetromino args))
            ('kijk (kijk))
            (else (display "Error in voorvertoning, msg is: ") (display msg))))))))

(define classic-voorvertoning (maak-voorvertoning))
(define bomb-voorvertoning (maak-voorvertoning))
(define gravity-voorvertoning (maak-voorvertoning))