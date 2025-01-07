" NOTE: 这个文件可能会被载入多次, 暂时不知道怎么优化, 只能保持尽量短小精悍
hi link markdownError NONE

syntax match markdownCheckbox "^\s*\([-\*] \[[-.?xX ]\]\|--\|++\) "
    \ contains=markdownCheckboxMarker,markdownCheckboxChecked,markdownCheckboxUnchecked,markdownCheckboxProgress
syntax match markdownCheckboxUnchecked "\(\[ \]\|--\)" contained
syntax match markdownCheckboxProgress "\(\[[-.?]\]\|--\)" contained
syntax match markdownCheckboxChecked "\(\[[xX]\]\|++\)" contained
syntax match markdownCheckboxMarker "^\s*[-\*] " contained

silent! hi link markdownCheckboxUnchecked Comment
silent! hi link markdownCheckboxProgress  Changed
silent! hi link markdownCheckboxChecked   Added
hi link markdownCheckboxMarker Tag
