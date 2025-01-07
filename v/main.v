module main

import os
import flag
import crypto.rand


fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('pwgen')
	fp.skip_executable()

	password_length := fp.int('length', 0, 0, 'Length of the password')
	numbers := fp.bool('numbers', 0, false, 'Include numbers in the password')
	symbols := fp.bool('symbols', 0, false, 'Include numbers in the password')

	additional_args := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		exit(1)
	}
	if additional_args.len > 0 {
		println('Extra arguments: $additional_args')
	}

	// I couldn't figure out how to require an argument with the flag parser.
	if password_length == 0 {
		eprintln('ERROR: the --length argument is required')
		exit(1)
	}

	mut allowed_chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
	if numbers {
		allowed_chars += '0123456789'
	}
	if symbols {
		allowed_chars += '!@#$%^&*()_+-=[]{}|;:\'",.<>?/\\'
	}

	random_bytes := rand.bytes(password_length) or {
		eprintln('ERROR: secure random bytes are not available on this platform.')
		eprintln(err)
		exit(1)
	}

	mut result_chars := []u8{len: password_length}
	alphabet_len := allowed_chars.len
	for i in 0 .. password_length {
		idx := random_bytes[i] % u8(alphabet_len)
		result_chars[i] = allowed_chars[idx]
	}

	if password_length < 16 {
		println('WARN: Password length is less than 16 characters. You should consider a longer password.')
	}

	println(result_chars.bytestr())
}
