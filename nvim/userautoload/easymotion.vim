nmap s <plug>(easymotion-s)
nmap f <plug>(easymotion-s)
vmap s <Plug>(easymotion-s)
nmap <Space>s <Plug>(easymotion-sn)
nmap ,s <Plug>(easymotion-s2)

" ホームポジションに近いキーを使う
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
" 「;」 + 何かにマッピング
let g:EasyMotion_leader_key=','
" 1 ストローク選択を優先する
let g:EasyMotion_grouping=1

let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_space_jump_first = 1
" カラー設定変更
hi EasyMotionTarget ctermbg=none ctermfg=red
hi EasyMotionShade  ctermbg=none ctermfg=blue
