# BufMRU - Most Recently Used Buffer Manager for Vim

BufMRU is a lightweight Vim plugin that manages recently used buffers and automatically closes the oldest ones to maintain a specified maximum number of open buffers. This helps keep your buffer list manageable without needing to close each buffer manually.

## Features

- Automatically close the oldest buffers when you exceed a user-defined limit.
- Customize the maximum number of open buffers.
- Beautiful, readable buffer tags in the statusline with unique formatting.
- Lightline integration to display the buffer name with a distinct prefix.

## Installation

### Using vim-plug

Add the following line to your `.vimrc`:

```vim
Plug 'jerryyin/vim-bufmru'
```
Then, install the plugin `:PlugInstall`

## Usage
BufMRU automatically keeps the most recently used buffers open, closing the oldest buffers when the limit (g:bufmru_nb_to_keep) is exceeded.

### Configuration
Set the maximum number of buffers to keep open:

```vim
let g:bufmru_nb_to_keep = 25  " Default is 25
```
This example will keep 25 buffers open. When a new buffer is opened and the limit is exceeded, the oldest buffer is closed automatically.

### Lightline Integration
BufMRU supports displaying buffer names with unique formatting in Lightline. To enable Lightline integration, include the following in your .vimrc:

```vim
Copy code
let g:lightline = {
      \ 'active': { 'left': [ [ 'mode', 'paste' ], [ 'bufmru' ] ] },
      \ 'component_function': { 'bufmru': 'bufmru#lightline#buffer_tag' },
      \ }
```
The buffer names will display in the format 5✦ filename where 5 is the buffer number.

### Functions
`BufMRUAutoClose()`

This function is triggered automatically when you enter a new buffer. It ensures that the number of open buffers does not exceed `g:bufmru_nb_to_keep`.
