#lang r7rs

;; ================================
;; GAME-DATA ADT
;; ================================

(import (scheme base)        
        (project constanten)
        )

(export some set-grid! grid geldige-coordinaten? filter iota every
        val-drempel bom-tijd set-bom-tijd! reset-bom-tijd! is-blokje? maak-leeg-grid hoogte breedte vrij?)

;; ===================
;; HULPFUNCTIES
;; ===================

(define (filter pred lst)
  (cond ((null? lst) '())
        ((pred (car lst)) (cons (car lst) (filter pred (cdr lst))))
        (else (filter pred (cdr lst)))))

(define (every pred lst) ;Controleert of pred waar is voor alle elementen in lst. (JS, all Python)
  (if (null? lst)
      #t
      (and (pred (car lst)) (every pred (cdr lst)))))

(define (iota n) ; '(0 1 2 3 ...) (C++)
  (let loop ((i 0) (acc '()))
    (if (= i n)
        (reverse acc)
        (loop (+ i 1) (cons i acc)))))


(define (some pred? lst) ;Geeft #t als minstens één element in lst voldoet aan pred?, anders #f.(JS)
  (cond
    ((null? lst) #f)
    ((pred? (car lst)) #t)
    (else (some pred? (cdr lst)))))


(define (geldige-coordinaten? lst)
  (and (list? lst) (every (lambda (p) (and (list? p) (= (length p) 2))) lst)))


;; ===================
;; ANDERE
;; ===================
(define grid
  (list->vector
   (map (lambda (_) (make-vector spel-breedte #f))
        (iota spel-hoogte))))

(define (maak-leeg-grid)
  (list->vector
   (map (lambda (_) (make-vector spel-breedte #f))
        (iota spel-hoogte))))

(define (set-grid! nieuwe-grid)
  (set! grid nieuwe-grid))

(define hoogte (vector-length grid))
(define breedte (vector-length (vector-ref grid 0)))
(define (vrij? x y)
  (and (< y hoogte)
       (not (vector-ref (vector-ref grid y) x))))

(define (is-blokje? vakje)
  (not (eq? vakje #f)))


(define (val-drempel level)
  (max 100 (/ 600 (+ 1 level)))  )

(define bom-tijd 0)
(define (set-bom-tijd! tijd)
  (set! bom-tijd (+ bom-tijd tijd)))
(define (reset-bom-tijd!)
  (set! bom-tijd 0))