#!/bin/bash

# Ubuntu をインストールした際に最初に実行するスクリプト（個人用）
# 主にウェブ開発用
# Author Takahiro (GitHubID Takahiro55555)

# 以下のようなエラーが出る場合
# /bin/bash^M: bad interpreter: そのようなファイルやディレクトリはありません (No such file or directory)
# 当ファイルと同じディレクトリで以下のコマンドを実行
# $ sed -i 's/\r//'  InitialSetup.sh
# 参考 http://totech.hateblo.jp/entry/2014/03/19/174129

sudo apt update
sudo apt -y upgrade

# pipのインストール
# apt install python-pip python3-pip
sudo apt -y install python3-pip

# venvのインストール
sudo apt -y install python3-venv

# nginxのインストール
sudo apt -y install nginx

# PostgreSQLのインストール
sudo apt -y install postgresql
sudo apt -y install python-psycopg2
sudo apt -y install libpq-dev

# treeのインストール
sudo apt -y install tree

# Let’s Encrypt の下準備
# 設定参考 https://officeyuai.com/ubuntu18-04/ubuntu-18-04%E3%81%A7lets-encrypt%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%97%E3%81%A6apache%E3%82%92%E4%BF%9D%E8%AD%B7%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/
yes | sudo add-apt-repository ppa:certbot/certbot
sudo apt -y install python-certbot-apache

# タイムゾーンを東京に設定
sudo timedatectl set-timezone Asia/Tokyo

###################### 以下vimの設定 ######################
# 引用元 https://qiita.com/iwaseasahi/items/0b2da68269397906c14c

echo "Setting up .vimrc..."

cat << EOF > ~/.vimrc
" 行番号を表示
set number
" ファイルを上書きする前にバックアップを作ることを無効化
set nowritebackup
" ファイルを上書きする前にバックアップを作ることを無効化
set nobackup
" vim の矩形選択で文字が無くても右へ進める
set virtualedit=block
" 挿入モードでバックスペースで削除できるようにする
set backspace=indent,eol,start
" 全角文字専用の設定
set ambiwidth=double
" wildmenuオプションを有効(vimバーからファイルを選択できる)
set wildmenu

"----------------------------------------
" 検索
"----------------------------------------
" 検索するときに大文字小文字を区別しない
set ignorecase
" 小文字で検索すると大文字と小文字を無視して検索
set smartcase
" 検索がファイル末尾まで進んだら、ファイル先頭から再び検索
set wrapscan
" インクリメンタル検索 (検索ワードの最初の文字を入力した時点で検索が開始)
set incsearch
" 検索結果をハイライト表示
set hlsearch

"----------------------------------------
" 表示設定
"----------------------------------------
" エラーメッセージの表示時にビープを鳴らさない
set noerrorbells
" Windowsでパスの区切り文字をスラッシュで扱う
set shellslash
" 対応する括弧やブレースを表示
set showmatch matchtime=1
" インデント方法の変更
set cinoptions+=:0
" メッセージ表示欄を2行確保
set cmdheight=2
" ステータス行を常に表示
set laststatus=2
" ウィンドウの右下にまだ実行していない入力中のコマンドを表示
set showcmd
" 省略されずに表示
set display=lastline
" タブ文字を CTRL-I で表示し、行末に $ で表示する
set list
" 行末のスペースを可視化
set listchars=tab:^\ ,trail:~
" コマンドラインの履歴を10000件保存する
set history=10000
" コメントの色を水色
hi Comment ctermfg=3
" 入力モードでTabキー押下時に半角スペースを挿入
set expandtab
" インデント幅
set shiftwidth=2
" タブキー押下時に挿入される文字幅を指定
set softtabstop=2
" ファイル内にあるタブ文字の表示幅
set tabstop=2
" ツールバーを非表示にする
set guioptions-=T
" yでコピーした時にクリップボードに入る
set guioptions+=a
" メニューバーを非表示にする
set guioptions-=m
" 右スクロールバーを非表示
set guioptions+=R
" 対応する括弧を強調表示
set showmatch
" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent
" スワップファイルを作成しない
set noswapfile
" 検索にマッチした行以外を折りたたむ(フォールドする)機能
set nofoldenable
" タイトルを表示
set title
" 行番号の表示
set number
" ヤンクでクリップボードにコピー
set clipboard=unnamed,autoselect
" Escの2回押しでハイライト消去
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
" シンタックスハイライト
syntax on
" すべての数を10進数として扱う
set nrformats=
" 行をまたいで移動
set whichwrap=b,s,h,l,<,>,[,],~
" バッファスクロール
set mouse=a

" auto reload .vimrc
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

" auto comment off
augroup auto_comment_off
  autocmd!
  autocmd BufEnter * setlocal formatoptions-=r
  autocmd BufEnter * setlocal formatoptions-=o
augroup END

" HTML/XML閉じタグ自動補完
augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
augroup END

" 編集箇所のカーソルを記憶
if has("autocmd")
  augroup redhat
    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=78
    " When editing a file, always jump to the last cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
  augroup END
endif
EOF

if [ $? ]; then
    echo "R : Successful .vimrc set up!!!"
else
    echo "E : .vimrc setup error"
fi