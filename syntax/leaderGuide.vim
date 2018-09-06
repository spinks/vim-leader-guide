if exists("b:current_syntax")
    finish
endif
let b:current_syntax = "leaderguide"

syn region LeaderGuideKeys start="\["hs=e+1 end="\]\s"he=s-1
      \ contained

syn region LeaderGuideBrackets start="\(^\|\s\+\)\[" end="\]\s\+"
      \ contains=LeaderGuideKeys keepend

if g:leaderGuide_display_plus_menus == 1
  syn region LeaderGuideMenu start="+" end="\s"
        \ contained 
  
  syn region LeaderGuideDesc start="^" end="$"
        \ contains=LeaderGuideBrackets, LeaderGuideMenu keepend
  
  hi def link LeaderGuideMenu Title
else
  syn region LeaderGuideDesc start="^" end="$"
        \ contains=LeaderGuideBrackets keepend
endif

hi def link LeaderGuideDesc Identifier
hi def link LeaderGuideKeys Type
hi def link LeaderGuideBrackets Delimiter
