;; extends
((comment) @injection.content
 (#match? @injection.content "`[^`]+`")
 (#set! injection.language markdown))
