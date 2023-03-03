/* auto config */
/* common */
val log2 : int -> int
function log2(n) =
  if n <= 1 then 0 else 1 + log2(tdiv_int(n, 2))
let linesz : int(linesz_t) = sizeof(linesz_t)
let idx_shift : nat = max(0, log2(linesz))
/* l1 */
let l1i_sets : int(l1i_sets_t) = sizeof(l1i_sets_t)
let l1i_ways : int(l1i_ways_t) = sizeof(l1i_ways_t)
/* l2 */
let l1d_sets : int(l1d_sets_t) = sizeof(l1d_sets_t)
let l1d_ways : int(l1d_ways_t) = sizeof(l1d_ways_t)
/* l3 */
let l2_sets : int(l2_sets_t) = sizeof(l2_sets_t)
let l2_ways : int(l2_ways_t) = sizeof(l2_ways_t)

/* cache info */
let valid : xlenbits = to_bits(sizeof(xlen), 1) << 63
let dirty : xlenbits = to_bits(sizeof(xlen), 1) << 62
let vadty : xlenbits = valid | dirty
register read_accesses : int = 0
register read_misses : int = 0
register write_accesses : int = 0
register write_misses : int = 0
register writebacks : int = 0
/* l1i */
register l1i_read_accesses : int = 0
register l1i_read_misses : int = 0
/* register l1i_write_accesses : int = 0 */
/* register l1i_write_misses : int = 0 */
/* register l1i_writebacks : int = 0 */
/* l1d */
register l1d_read_accesses : int = 0
register l1d_read_misses : int = 0
register l1d_write_accesses : int = 0
register l1d_write_misses : int = 0
register l1d_writebacks : int = 0
/* l2 */
register l2_read_accesses : int = 0
register l2_read_misses : int = 0
register l2_write_accesses : int = 0
register l2_write_misses : int = 0
register l2_writebacks : int = 0
/* lfsr */
register lfsr : bits(32) = to_bits(sizeof(32), 1)

/* cache entry */
register l1i_cache : vector(l1i_sets_t, dec, vector(l1i_ways_t, dec, xlenbits))
register l1d_cache : vector(l1d_sets_t, dec, vector(l1d_ways_t, dec, xlenbits))
register l2_cache : vector(l2_sets_t, dec, vector(l2_ways_t, dec, xlenbits))

/* function */
function lfsr_next() -> unit = {
		lfsr = (lfsr >> 1) ^ ((~(lfsr & 0x00000001) + 1) & 0xd0000001)
}

/* cache_clean_invalidate */
function l1i_cache_clean_invalidate() -> unit = {
  foreach (i from 0 to (l1i_sets - 1)) {
		foreach (j from 0 to (l1i_ways - 1)) {
			l1i_cache[i][j] = ~(vadty)
		}
	}
}
function l1d_cache_clean_invalidate() -> unit = {
  foreach (i from 0 to (l1d_sets - 1)) {
		foreach (j from 0 to (l1d_ways - 1)) {
			l1d_cache[i][j] = ~(vadty)
		}
	}
}
function l2_cache_clean_invalidate() -> unit = {
  foreach (i from 0 to (l2_sets - 1)) {
		foreach (j from 0 to (l2_ways - 1)) {
			l2_cache[i][j] = ~(vadty)
		}
	}
}
/* cache_clean_invalidate */

function int_of_bits(xs: xlenbits) -> nat = {
	acc : nat = 0; bound = sizeof(xlen) - 1;
	foreach(i from 0 to bound) {
		acc = acc * 2;
		if bit_to_bool(xs[(bound - i)])
		then acc = acc + 1
	};
	acc
}

function print_cache_stats() -> unit = {
	read_accesses = l1i_read_accesses + l1d_read_accesses;
	write_accesses = /*l1i_write_accesses + */l1d_write_accesses;
	read_misses = l1i_read_misses + l1d_read_misses;
	write_misses = /*l1i_write_misses + */l1d_write_misses;
	writebacks = /*l1i_writebacks + */l1d_writebacks;
	print("\n---------Cache Info--------- ");
	print_int("Read Accesses:         ", read_accesses);
	print_int("Write Accesses:        ", write_accesses);
	print_int("Read Misses:           ", read_misses);
	print_int("Write Misses:          ", write_misses);
	print_int("Writebacks:            ", writebacks);
	miss = read_misses + write_misses; access = read_accesses + write_accesses;
	miss_rate = dec_str(tdiv_int(100 * miss, access));
	miss_rate_dot = dec_str(tdiv_int(1000 * ((100 * miss) % access), access));
	print("Miss Rate:             " ^ miss_rate ^ "." ^ miss_rate_dot ^ "%");
}

function print_l1_cache_stats() -> unit = {
	/* L1I */
	print("---------L1 Instruction Cache Info---------");
	print_int("Read Accesses:         ", l1i_read_accesses);
	/*print_int("Write Accesses:        ", l1i_write_accesses);*/
	print_int("Read Misses:           ", l1i_read_misses);
	/*print_int("Write Misses:          ", l1i_write_misses);*/
	/*print_int("Writebacks:            ", l1i_writebacks);*/
	l1i_miss = l1i_read_misses/* + l1i_write_misses*/;
	l1i_access = l1i_read_accesses/* + l1i_write_accesses*/;
	l1i_miss_rate = dec_str(tdiv_int(100 * l1i_miss, l1i_access));
	l1i_miss_rate_dot = dec_str(tdiv_int(1000 * ((100 * l1i_miss) % l1i_access), l1i_access));
	print("Miss Rate:             " ^ l1i_miss_rate ^ "." ^ l1i_miss_rate_dot ^ "%");
	/* L1D */
	print("---------L1 Data Cache Info---------");
	print_int("Read Accesses:         ", l1d_read_accesses);
	print_int("Write Accesses:        ", l1d_write_accesses);
	print_int("Read Misses:           ", l1d_read_misses);
	print_int("Write Misses:          ", l1d_write_misses);
	print_int("Writebacks:            ", l1d_writebacks);
	l1d_miss = l1d_read_misses + l1d_write_misses;
	l1d_access = l1d_read_accesses + l1d_write_accesses;
	l1d_miss_rate = dec_str(tdiv_int(100 * l1d_miss, l1d_access));
	l1d_miss_rate_dot = dec_str(tdiv_int(1000 * ((100 * l1d_miss) % l1d_access), l1d_access));
	print("Miss Rate:             " ^ l1d_miss_rate ^ "." ^ l1d_miss_rate_dot ^ "%");
}

function print_l2_cache_stats() -> unit = {
	print("---------L2 Cache Info---------");
	print_int("Read Accesses:         ", l2_read_accesses);
	print_int("Write Accesses:        ", l2_write_accesses);
	/*print_int("Read Misses:           ", l2_read_misses);*/
	/*print_int("Write Misses:          ", l2_write_misses);*/
	print_int("Writebacks:            ", l2_writebacks);
	/*
	l2_miss = l2_read_misses + l2_write_misses;
	l2_access = l2_read_accesses + l2_write_accesses;
	l2_miss_rate = dec_str(tdiv_int(100 * l2_miss, l2_access));
	l2_miss_rate_dot = dec_str(tdiv_int(1000 * ((100 * l2_miss) % l2_access), l2_access));
	print("Miss Rate:             " ^ l2_miss_rate ^ "." ^ l2_miss_rate_dot ^ "%");
	*/
}
