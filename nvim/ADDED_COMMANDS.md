# Added Commands

Короткая подсказка по последним добавлениям для навигации, Rust, фронта и git.

| Клавиши | Что делает |
| --- | --- |
| `Пробел cL` | Показать LSP-клиенты текущего буфера |
| `Пробел cF` | Показать formatter'ы текущего буфера |
| `]m` | Следующая функция или метод |
| `[m` | Предыдущая функция или метод |
| `]T` | Следующий тип: struct, enum, trait, interface и похожие объявления |
| `[T` | Предыдущий тип: struct, enum, trait, interface и похожие объявления |
| `]h` | Следующее git-изменение в файле |
| `[h` | Предыдущее git-изменение в файле |
| `Пробел gp` | Показать git hunk |
| `Пробел gs` | Stage текущий git hunk |
| `Пробел gr` | Откатить текущий git hunk |
| `Пробел gb` | Git blame текущей строки |

## Snippets

Svelte: `comp`, `props`, `state`, `derived`, `effect`, `if`, `each`, `eacht`,
`onclick`, `class`, `bind`, `style`, `btn`, `form`.

JS/TS/JSX/TSX: `desc`, `test`, `testa`, `expect`, `fetchj`, `try`, `pwt`.

Rust: `test`, `atest`, `mainr`, `derive`, `impl`, `match`.

## Notes

Treesitter включается сам при открытии файла и даёт более точную подсветку для
Go, Rust, Svelte, TS, HTML, CSS и остальных настроенных языков.

Rust использует `rust-analyzer` для переходов, подсказок и диагностики. При
сохранении `.rs` запускается форматирование через LSP, обычно это `rustfmt` из
установленного Rust toolchain.

Gitsigns включается только внутри git-репозитория. В новых проектах сначала нужен
обычный `git init`.
