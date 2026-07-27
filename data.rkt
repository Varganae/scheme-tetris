#lang r7rs
(import (scheme base)
        (scheme write)
        (project status)
        (project vasthouden)
        (project voorvertoning)
        (project score)
        (project level)        
        )
(export vasthouder voorvertoning score level
        set-vasthouder! set-voorvertoning! set-score! set-level!)

(define vasthouder classic-vasthouder)
(define (set-vasthouder! x)
  (set! vasthouder x))

(define voorvertoning classic-voorvertoning)
(define (set-voorvertoning! x)
  (set! voorvertoning x))

(define score classic-score)
(define (set-score! x)
  (set! score x))

(define level classic-level)
(define (set-level! x)
  (set! level x))