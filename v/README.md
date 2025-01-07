# V

https://vlang.io/

## Run

```
❯ v run main.v --length=64 --numbers --symbols
"(ZFNqJX|;Dnl7x:h5s#euslp1J\kyE)quzj6pV?w}fyu$-@BzX{xiNq,hw9JrW&
```

## Build

```
❯ v -o pwgen main.v
❯ ./pwgen --length=64 --numbers --symbols
;i@U2f:8jPX9AA/RGOND!:hG&:!x1Nnibis_\<lg#32W<*Ox_9L4Rg)LkBq^)SUE
```

## Language Notes

- The compiler seems helpful.

```
❯ v run main.v
main.v:32:10: error: cannot cast []u8 to string, use `result_chars.bytestr()` or `result_chars.str()` instead.
   30 |     }
   31 |
   32 |     println(string(result_chars))
      |             ~~~~~~~~~~~~~~~~~~~~
   33 |
   34 | }
```

- I could not get the LSP working in neovim, so just reading the language source most of the time.
