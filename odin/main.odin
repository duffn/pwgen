package main

import "base:runtime"
import "core:crypto"
import "core:flags"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"

Options :: struct {
	length:   int `args:"required" usage:"Length of the password to generate"`,
	numbers:  bool `usage:"Include numbers in the password"`,
	symbols:  bool `usage:"Include symbols in the password"`,
	quantity: int `usage:"Number of passwords to generate"`,
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	ctx := runtime.default_context()
	ctx.random_generator = crypto.random_generator()

	opt: Options
	style: flags.Parsing_Style = .Unix
	flags.parse_or_exit(&opt, os.args, style)

	if !crypto.HAS_RAND_BYTES {
		fmt.println("ERROR: secure random bytes are not available on this platform.")
		os.exit(1)
	}

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
		fmt.println("WARN: Password length is 0 or less. A default length of 20 characters will be used.")
		password_length = 20
	} else if password_length > 1024 {
		fmt.println("WARN: Password length is greater than 1024 characters. A maximum of 1024 characters is allowed.")
		password_length = 1024
	}

	if opt.quantity <= 0 {
		opt.quantity = 1
	} else if opt.quantity > 100 {
		fmt.println("WARN: Password quantity is greater than 100. A maximum of 100 passwords will be generated.")
		opt.quantity = 100
	}

	alphabet_len := len(allowed_chars)
	result_passwords := make([]string, opt.quantity)
	defer delete(result_passwords)

	if password_length < 16 {
		fmt.println("WARN: Password length is less than 16 characters. You should consider a longer password.")
	}

	for _ in 0 ..< opt.quantity {
		random_bytes := make([]u8, password_length)
		defer delete(random_bytes)

		crypto.rand_bytes(random_bytes)

		result_chars := make([]u8, password_length)
		defer delete(result_chars)
		for j in 0 ..< password_length {
			idx := random_bytes[j] % u8(alphabet_len)
			result_chars[j] = allowed_chars[idx]
		}
		fmt.println(string(result_chars))
	}

	if opt.symbols || opt.numbers {
		delete(allowed_chars)
	}
}
