" NOTE: 这个文件可能会被载入多次, 暂时不知道怎么优化, 只能保持尽量短小精悍
hi link markdownError NONE

syntax match markdownCheckbox "^\s*\([-\*] \[[-.xX ]\]\|--\|++\) "
    \ contains=markdownCheckboxMarker,markdownCheckboxChecked,markdownCheckboxUnchecked,markdownCheckboxProgress
syntax match markdownCheckboxUnchecked "\(\[ \]\|--\)" contained
syntax match markdownCheckboxProgress "\(\[[-.]\]\|--\)" contained
syntax match markdownCheckboxChecked "\(\[[xX]\]\|++\)" contained
syntax match markdownCheckboxMarker "^\s*[-\*] " contained

silent! hi link markdownCheckboxUnchecked @text.todo.unchecked
silent! hi link markdownCheckboxProgress  @text.todo.checked
silent! hi link markdownCheckboxChecked   @text.todo.checked
hi link markdownCheckboxMarker markdownListMarker
