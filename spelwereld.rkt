#lang r7rs

;; ================================
;; SPELWERELD ADT
;; ================================

(import (scheme base)
        (scheme write)
        (project teken)              
        (project speelveld)        
        (project level)
        (project status)
        (project game-data)
        (project animatie)
        (project data)
        (project vasthouden)
        (project voorvertoning)
        (project score)
        
        )

(export maak-spelwereld speelveld genereer-nieuwe-tetromino spelwereld)
(#%require (only racket random))

;; ================================
;; INITIALISATIES
;; ================================
(define tijd 0)
(define classic-tetromino #f)
(define bomb-tetromino #f)
(define gravity-tetromino #f)

(define actieve-bom #f)

(define flits-interval 20)
(define max-fases 4)

(define tetromino #f)
  
(define (get-tetromino) tetromino)

(define classic-speelveld (maak-speelveld))
(define bomb-speelveld (maak-speelveld))
(define gravity-speelveld (maak-speelveld))
(define speelveld
  (cond
    ((eq? (status 'geef-spelstatus) 'bomb-modus) bomb-speelveld)
    ((eq? (status 'geef-spelstatus) 'gravity-modus) gravity-speelveld)
    (else classic-speelveld)))


;; ================================
;; Setter-functie voor huidige Tetromino
;; ================================
(define (set-tetromino! nieuwe-tetromino)
  (set! tetromino nieuwe-tetromino))

(define (wissel-tetromino!)  
  (when (vasthouder 'toegestaan?)
    (let ((huidige tetromino)
          (nieuwe (vasthouder 'wissel-met! tetromino)))
      (set-tetromino! nieuwe))))


;; ================================
;; Tetromino genereren
;; ================================
(define (genereer-nieuwe-tetromino wereld)
  (cond ((eq? (status 'geef-status) 'game-over) (teken 'teken-game-over!))
        
        ((eq? (status 'geef-spelstatus) 'classic-modus)
         (begin
           (set-tetromino! (voorvertoning 'haal-volgende-tetromino #f))
           (vasthouder 'reset!)
           (when (not (wereld 'binnen-bordures? tetromino 0 0))
             (status 'set-status! 'game-over)
             (display "Game Over!") (newline))))
        
        ((eq? (status 'geef-spelstatus) 'bomb-modus)
         (set-tetromino! (voorvertoning 'haal-volgende-tetromino #f))
         (vasthouder 'reset!)
         (when (eq? (tetromino 'geef-type) 'B)
           (when (eq? (tetromino 'geef-type) 'B)
             (if actieve-bom
                 ;; Er is al een bom → vervang door normale tetromino
                 (set-tetromino! (voorvertoning 'haal-volgende-tetromino #f))
                 ;; Er is nog geen bom → registreer als actieve bom
                 (begin
                   (set! actieve-bom tetromino)
                   (reset-bom-tijd!))))
           )
         (when (not (wereld 'binnen-bordures? tetromino 0 0))
           (status 'set-status! 'game-over)
           (display "GAME OVER") (newline)) )

        ((eq? (status 'geef-spelstatus) 'gravity-modus)
         (begin
           (set-tetromino! (voorvertoning 'haal-volgende-tetromino #f))
           (vasthouder 'reset!)
           (when (not (wereld 'binnen-bordures? tetromino 0 0))
             (status 'set-status! 'game-over)
             (display "Game Over!") (newline))))
        
        (else (display "error genereertetromino"))))


;; ================================
;; SPEL LOGICA
;; ================================
(define (check-status!)
  (status 'set-status! (status 'geef-status)))
;; CLASSIC SPEL LUS
(define (classic-spel-lus-functie delta-tijd wereld)
  (teken 'teken-classic-modus!)
  (check-status!)

  ; animatie
  (when (eq? (status 'geef-status) 'highlight)
    (animatie 'set-highlight-timer! (+ (animatie 'highlight-timer) delta-tijd)) ;;;;;;
    (when (>= (animatie 'highlight-timer) flits-interval)
      (animatie 'set-highlight-timer! 0)
      
      (if (animatie 'highlight-aan?)
          (teken 'clear-highlight-laag!)
          (teken 'teken-highlight-rijen! (animatie 'highlight-rijen) "white"))
      
      (animatie 'toggle-highlight-aan!)
      (animatie 'inc-highlight-fase!)
      
      (when (>= (animatie 'highlight-fase) max-fases)
        (teken 'clear-highlight-laag!)
        (speelveld 'verwijder-volle-rijen!)        
        (status 'set-status! 'spel)) ))
  
  (when
      (eq? (status 'geef-spelstatus) 'classic-modus)
    ;(status 'set-transitie-status! (status 'geef-status))
    (teken 'teken-speelveld!)
    (teken 'teken-wereld! tetromino)

    (set! tijd (+ delta-tijd tijd)) 
    
    (let ((drempel (val-drempel (level 'geef-level))))
      (if (> tijd drempel)
          (begin
            (if (wereld 'binnen-bordures? tetromino 0 1)
                (begin
                  (tetromino 'verplaats-omlaag!)
                  (teken 'teken-wereld! tetromino)
                  )
                (begin ;; Tetromino is geland
                  (wereld 'zet-vast! tetromino)
                  (wereld 'verwijder-en-update-score!)
                  (genereer-nieuwe-tetromino wereld)                 
                  
                  ))
            (set! tijd 0))))))


;; BOMB SPEL LUS
(define (bomb-spel-lus-functie delta-tijd wereld)
  (teken 'teken-bomb-modus!)
  (check-status!)
  
  ;; ANIMATIE
  (when (eq? (status 'geef-status) 'highlight)
    (animatie 'set-highlight-timer! (+ (animatie 'highlight-timer) delta-tijd))
    (when (>= (animatie 'highlight-timer) flits-interval)
      (animatie 'set-highlight-timer! 0)      
      (if (animatie 'highlight-aan?)
          (teken 'clear-highlight-laag!)
          (teken 'teken-highlight-rijen! (animatie 'highlight-rijen) "white"))      
      (animatie 'toggle-highlight-aan!)
      (animatie 'inc-highlight-fase!)      
      (when (>= (animatie 'highlight-fase) max-fases)
        (teken 'clear-highlight-laag!)
        (speelveld 'verwijder-volle-rijen!)
        (status 'set-status! 'spel)) ))
  
  ;; BOMB
  (when (eq? (status 'geef-spelstatus) 'bomb-modus)    
    (teken 'teken-speelveld!)
    (teken 'teken-wereld! tetromino)
    ; Tijd bijhouden voor tetromino-verplaatsing
    (set! tijd (+ tijd delta-tijd))

    ;; BOM TIMER EN EXPLOSIE
    (when actieve-bom
      (teken 'teken-timer! bom-tijd)
      (set-bom-tijd! delta-tijd)
      ; Als bom niet meer in het grid zit (bv. door lijnverwijdering), reset bom
      (when (not (wereld 'bevat-coordinaten? (actieve-bom 'geef-coordinaten)))
        (set! actieve-bom #f)
        (reset-bom-tijd!)
        )
      ;; Als 20 seconden verstreken zijn, laat de bom ontploffen
      (when (> bom-tijd 20000) ; 20000 ms = 20 sec
        (wereld 'explodeer-bom! (actieve-bom 'geef-coordinaten))
        (set! actieve-bom #f)
        (reset-bom-tijd!)
        (teken 'delete-timer!)))    

    ;; TETROMINO VERWERKING
    (let ((drempel (val-drempel (level 'geef-level))))
      (when (> tijd drempel)
        (if (wereld 'binnen-bordures? tetromino 0 1)
            ;; Tetromino kan nog zakken
            (begin
              (tetromino 'verplaats-omlaag!)
              (teken 'teken-wereld! tetromino))
            ;; Tetromino is geland
            (begin
              (wereld 'zet-vast! tetromino)
              ;; Als het een bom is, activeer hem
              (when (eq? (tetromino 'geef-type) 'B)
                (set! actieve-bom tetromino)
                (reset-bom-tijd!))

              (wereld 'verwijder-en-update-score!)
              (genereer-nieuwe-tetromino wereld)
              ))
        ;; Reset tijd na verplaatsing
        (set! tijd 0)))))

;; GRAVITY SPEL LUS
(define (gravity-spel-lus-functie delta-tijd wereld)
  (teken 'teken-gravity-modus!)
  (check-status!)
  ; animatie
  (when (eq? (status 'geef-status) 'highlight)
    (animatie 'set-highlight-timer! (+ (animatie 'highlight-timer) delta-tijd))
    (when (>= (animatie 'highlight-timer) flits-interval)
      (animatie 'set-highlight-timer! 0)
      (if (animatie 'highlight-aan?)
          (teken 'clear-highlight-laag!)
          (teken 'teken-highlight-rijen! (animatie 'highlight-rijen) "white"))
      (animatie 'toggle-highlight-aan!)
      (animatie 'inc-highlight-fase!)
      (when (>= (animatie 'highlight-fase) max-fases)
        (teken 'clear-highlight-laag!)
        (speelveld 'verwijder-volle-rijen!)
        (status 'set-status! 'spel))))

  ;; GRAVITY-MODUS ACTIEF
  (when (eq? (status 'geef-spelstatus) 'gravity-modus)
    (teken 'teken-speelveld!)
    (teken 'teken-wereld! tetromino)
    (set! tijd (+ delta-tijd tijd))
    (let ((drempel (val-drempel (level 'geef-level))))
      (if (> tijd drempel)
          (begin
            (if (wereld 'binnen-bordures? tetromino 0 1)
                ;; Tetromino kan verder vallen
                (begin
                  (tetromino 'verplaats-omlaag!)
                  (teken 'teken-wereld! tetromino))
                ;; Tetromino is geland
                (begin
                  (wereld 'zet-vast! tetromino)
                  (wereld 'verwijder-en-update-score!)

                  ;; zwaartekracht verwerken
                  (display "--- ZWAARTEKRACHT START ---") (newline)

                  (let gravity-loop ()
                    (let ((zwevend (speelveld 'vind-zwevende-blokken)))
                      (display "Zwaartekracht check - Zwevend: ") (display zwevend) (newline)

                      (when (not (null? zwevend))
                        (speelveld 'laat-vallen! zwevend)                        
                        
                        (when (speelveld 'verwijder-volle-rijen!)
                          (gravity-loop)))))

                  (genereer-nieuwe-tetromino wereld)))
            (set! tijd 0))))))


;; ================================
;; TOETSENBORD INPUT
;; ================================
(define (spel-toets-functie stat toets wereld)
  (when (eq? stat 'pressed)
    (cond

      ;; === MENU-STATUS ===
      ((eq? (status 'geef-status) 'menu)
       (spelwereld 'reset-spel!)
       (cond
         ((or (eq? toets 'enter) (eq? toets #\return))
          (spelwereld 'reset-spel!)
          (set-vasthouder! classic-vasthouder)
          (set-voorvertoning! classic-voorvertoning)
          (set-level! classic-level)
          (set-score! classic-score)
          (voorvertoning 'set-typen! '(I J L O S T Z))
          (status 'set-status! 'spel)
          (status 'set-spelstatus! 'classic-modus)
          (genereer-nieuwe-tetromino wereld)
          (teken 'teken-speelveld!)
          (teken 'set-spel-lus-functie! (lambda (dt) (classic-spel-lus-functie dt wereld))))
   
         ((eq? toets #\z)
          (set-vasthouder! bomb-vasthouder)
          (set-voorvertoning! bomb-voorvertoning)
          (set-level! bomb-level)
          (set-score! bomb-score)
          (voorvertoning 'set-typen! '(I J L O S T Z B))
          (status 'set-status! 'spel)
          (status 'set-spelstatus! 'bomb-modus)
          (genereer-nieuwe-tetromino wereld)
          (teken 'teken-speelveld!)
          (teken 'set-spel-lus-functie! (lambda (dt) (bomb-spel-lus-functie dt wereld))))

         ((eq? toets #\g)
          (set-vasthouder! gravity-vasthouder)
          (set-voorvertoning! gravity-voorvertoning)
          (set-level! gravity-level)
          (set-score! gravity-score)
          (voorvertoning 'set-typen! '(I J L O S T Z))
          (status 'set-status! 'spel)
          (status 'set-spelstatus! 'gravity-modus)
          (genereer-nieuwe-tetromino wereld)
          (teken 'teken-speelveld!)
          (teken 'set-spel-lus-functie! (lambda (dt) (gravity-spel-lus-functie dt wereld))))

         ))


      ;; === GAME-OVER STATUS ===
      ((eq? (status 'geef-status) 'game-over)
       (when (eq? toets #\b)
         (spelwereld 'reset-spel!)
         ;spelstatus hier ook resetten
         (display "game over")))


      ;; === SPELLOOP-STATUS ===
      ((or (eq? (status 'geef-spelstatus) 'classic-modus)
           (eq? (status 'geef-spelstatus) 'bomb-modus)
           (eq? (status 'geef-spelstatus) 'gravity-modus))
       (cond
         ((eq? toets 'left)
          (if (wereld 'binnen-bordures? tetromino -1 0)
              (tetromino 'verplaats-links!)))
         ((eq? toets 'right)
          (if (wereld 'binnen-bordures? tetromino 1 0)
              (tetromino 'verplaats-rechts!)))
         ((eq? toets 'down)
          (if (wereld 'binnen-bordures? tetromino 0 1)
              (tetromino 'verplaats-omlaag!)))
         ((or (eq? toets #\r) (eq? toets #\x))
          (tetromino 'roteer!))
         ((eq? toets #\space)
          (tetromino 'laat-vallen!))
         ((or (eq? toets #\h) (eq? toets 'shift))
          (if (vasthouder 'inhoud)
              (wissel-tetromino!)
              (begin
                (vasthouder 'stel-in! tetromino)
                (set-tetromino! (voorvertoning 'haal-volgende-tetromino #f))))))
       ))))


;; ================================
;; START FUNCTIE
;; ================================
(define (start! wereld)
  (teken 'set-toets-functie! (lambda (s t) (spel-toets-functie s t wereld)))  
  (teken 'set-teken-functie!
         (lambda () (teken 'teken-hoofdmenu!))
         (lambda () (teken 'teken-wereld! tetromino))
         (lambda () (teken 'teken-game-over!))
         (lambda () (teken 'teken-modus!)))
  )

(define (reset-spel!)
  
  (check-status!)
  (score 'reset-score!)    
  (vasthouder 'reset-alles!)
  (level 'reset-level!)
  ;(classic-level 'reset-level!)
  (status 'set-status! 'menu)
  (set-grid! (maak-leeg-grid))
  (set! tetromino (voorvertoning 'haal-volgende-tetromino #f))
    
  ;; Heractiveer hoofdmenuweergave
  (teken 'set-teken-functie!
         (lambda () (teken 'teken-hoofdmenu!))
         (lambda () (teken 'teken-wereld! tetromino))

         (lambda () (teken 'teken-game-over!))
         (lambda () (teken 'teken-modus!)))
    
  (teken 'set-spel-lus-functie!
         (lambda (dt) (display "restarting")))
  )


;; ================================
;; DISPATCHER
;; ================================
(define (maak-spelwereld wereld)
  (lambda (msg)
    (case msg
      ('start! (start! wereld))
      ('reset-spel! (reset-spel!))
      (else (display "Error in spelwereld, msg is: ") (display msg)))))


;; =============
(define spelwereld (maak-spelwereld speelveld))
