package main

import "core:crypto"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"

Options :: struct {
	length:  int `args:"required" usage:"Length of the password to generate"`,
	numbers: bool `usage:"Include numbers in the password"`,
	symbols: bool `usage:"Include symbols in the password"`,
}

main :: proc() {
	context.random_generator = crypto.random_generator()

	opt: Options
	style: flags.Parsing_Style = .Unix
	flags.parse_or_exit(&opt, os.args, style)

	if ODIN_DEBUG {
		fmt.printfln("%#v", opt)
	}

	allowed_chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	if opt.numbers {
		allowed_chars = strings.concatenate({allowed_chars, "0123456789"})
	}
	if opt.symbols {
		allowed_chars = strings.concatenate({allowed_chars, "!@#$%^&*()-_=+[]{};:'\",.<>?/"})
	}

	password_length := opt.length
	if password_length <= 0 {
		password_length = 20
	} else if password_length > 1024 {
		password_length = 1024
	}

	random_bytes := make([]u8, password_length)
	defer delete(random_bytes)
	if crypto.HAS_RAND_BYTES {
		crypto.rand_bytes(random_bytes)
	} else {
		fmt.println("ERROR: secure random bytes are not available on this platform.")
		os.exit(1)
	}

	alphabet_len := len(allowed_chars)
	result_chars := make([]u8, password_length)
	defer delete(result_chars)

	for i in 0 ..< password_length {
		idx := random_bytes[i] % u8(alphabet_len)
		result_chars[i] = allowed_chars[idx]
	}

	if password_length < 16 {
		fmt.println(
			"WARN: Password length is less than 16 characters. You should consider a longer password.",
		)
	}
	fmt.println(string(result_chars))

	if opt.symbols || opt.numbers {
		delete(allowed_chars)
	}
}
