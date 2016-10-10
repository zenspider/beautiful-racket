#lang at-exp racket
(require pict/code)
(codeblock-pict
    #:keep-lang-line? #f
    @string-append|{
                   #lang br/demo/jsonic
{
"string": @$(string-append "foo" "bar")$@,
"array": @$(range 5)$@,
"object": @$(hash "k1" "valstring" (format "~a" 42) (hash "k1" (range 10) "k2" 42))$@
// "bar" :
}|)