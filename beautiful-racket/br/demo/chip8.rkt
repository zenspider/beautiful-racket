#lang br
;http://www.multigesture.net/articles/how-to-write-an-emulator-chip-8-interpreter/
; http://devernay.free.fr/hacks/chip8/C8TECH10.HTM
; http://mattmik.com/files/chip8/mastering/chip8.html

(define (explode-bytes val)
  (cond
    [(zero? val) (list 0)]
    [else
     (define-values (bytes residual)
       (for/fold ([bytes empty][residual val])
                 ([i (in-naturals)]
                  #:break (zero? residual))
         (define m (modulo residual 16))
         (values (cons m bytes) (arithmetic-shift residual -4))))
     bytes]))

(module+ test
  (require rackunit)
  (check-equal? (explode-bytes #x2B45) (list #x2 #xB #x4 #x5))
  (check-equal? (explode-bytes #xCD) (list #xC #xD))
  (check-equal? (explode-bytes #xA) (list #xA))
  (check-equal? (explode-bytes #x0) (list #x0)))

(define (glue-bytes bytes)
  (for/sum ([b (in-list (reverse bytes))]
            [i (in-naturals)])
           (* b (expt 16 i))))

(module+ test
  (check-equal? #x2B45 (glue-bytes (list #x2 #xB #x4 #x5)))
  (check-equal? #xCD (glue-bytes (list #xC #xD)))
  (check-equal? #xA (glue-bytes (list #xA)))
  (check-equal? #x0 (glue-bytes (list #x0))))

(define-syntax (define-memory-vector stx)
  (syntax-case stx ()
    [(_ ID [FIELD LENGTH SIZE] ...)
     (with-syntax ([(ID-FIELD-REF ...) (map (λ(field) (format-id stx "~a-~a-ref" #'ID field)) (syntax->list #'(FIELD ...)))]
                   [(ID-FIELD-SET! ...) (map (λ(field) (format-id stx "~a-~a-set!" #'ID field)) (syntax->list #'(FIELD ...)))]
                   [(FIELD-OFFSET ...) (reverse (cdr
                                                 (for/fold ([offsets '(0)])
                                                           ([len (in-list (syntax->list #'(LENGTH ...)))]
                                                            [size (in-list  (syntax->list #'(SIZE ...)))])
                                                   (cons (+ (syntax-local-eval #`(* #,len #,size)) (car offsets)) offsets))))])
       #'(begin
           (define ID (make-vector (+ (* LENGTH SIZE) ...)))
           (define (ID-FIELD-REF idx)
             (unless (< idx LENGTH)
               (raise-argument-error 'ID-FIELD-REF (format "index less than field length ~a" LENGTH) idx))
             (glue-bytes
              (for/list ([i (in-range SIZE)])
                        (vector-ref ID (+ FIELD-OFFSET i idx)))))
           ...
           (define (ID-FIELD-SET! idx val)
             (unless (< idx LENGTH)
               (raise-argument-error 'ID-FIELD-SET! (format "index less than field length ~a" LENGTH) idx))
             (unless (< val (expt 16 SIZE))
               (raise-argument-error 'ID-FIELD-SET! (format "value less than field size ~a" (expt 16 SIZE)) val))
             (for ([i (in-range SIZE)]
                   [b (in-list (explode-bytes val))])
                  (vector-set! ID (+ FIELD-OFFSET i idx) b))) ...))]))

(define-memory-vector chip 
  [opcode 1 2] ; two bytes
  [memory 4096 1] ; one byte per
  [V 16 1] ; one byte per
  [I 3 1] ; index register, 0x000 to 0xFFF
  [pc 3 1] ; program counter, 0x000 to 0xFFF
  [gfx (* 64 32) 1] ; pixels
  [delay_timer 1 1]
  [sound_timer 1 1]
  [stack 16 2] ; 2 bytes each
  [sp 1 1] ; stack pointer
  [key 16 1]) ; keys
