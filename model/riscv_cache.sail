/*=======================================================================================*/
/*  RISCV Sail Model                                                                     */
/*                                                                                       */
/*  This Sail RISC-V architecture model, comprising all files and                        */
/*  directories except for the snapshots of the Lem and Sail libraries                   */
/*  in the prover_snapshots directory (which include copies of their                     */
/*  licences), is subject to the BSD two-clause licence below.                           */
/*                                                                                       */
/*  Copyright (c) 2017-2021                                                              */
/*    Prashanth Mundkur                                                                  */
/*    Rishiyur S. Nikhil and Bluespec, Inc.                                              */
/*    Jon French                                                                         */
/*    Brian Campbell                                                                     */
/*    Robert Norton-Wright                                                               */
/*    Alasdair Armstrong                                                                 */
/*    Thomas Bauereiss                                                                   */
/*    Shaked Flur                                                                        */
/*    Christopher Pulte                                                                  */
/*    Peter Sewell                                                                       */
/*    Alexander Richardson                                                               */
/*    Hesham Almatary                                                                    */
/*    Jessica Clarke                                                                     */
/*    Microsoft, for contributions by Robert Norton-Wright and Nathaniel Wesley Filardo  */
/*    Peter Rugg                                                                         */
/*    Aril Computer Corp., for contributions by Scott Johnson                            */
/*                                                                                       */
/*  All rights reserved.                                                                 */
/*                                                                                       */
/*  This software was developed by the above within the Rigorous                         */
/*  Engineering of Mainstream Systems (REMS) project, partly funded by                   */
/*  EPSRC grant EP/K008528/1, at the Universities of Cambridge and                       */
/*  Edinburgh.                                                                           */
/*                                                                                       */
/*  This software was developed by SRI International and the University of               */
/*  Cambridge Computer Laboratory (Department of Computer Science and                    */
/*  Technology) under DARPA/AFRL contract FA8650-18-C-7809 ("CIFV"), and                 */
/*  under DARPA contract HR0011-18-C-0016 ("ECATS") as part of the DARPA                 */
/*  SSITH research programme.                                                            */
/*                                                                                       */
/*  This project has received funding from the European Research Council                 */
/*  (ERC) under the European Union’s Horizon 2020 research and innovation                */
/*  programme (grant agreement 789108, ELVER).                                           */
/*                                                                                       */
/*                                                                                       */
/*  Redistribution and use in source and binary forms, with or without                   */
/*  modification, are permitted provided that the following conditions                   */
/*  are met:                                                                             */
/*  1. Redistributions of source code must retain the above copyright                    */
/*     notice, this list of conditions and the following disclaimer.                     */
/*  2. Redistributions in binary form must reproduce the above copyright                 */
/*     notice, this list of conditions and the following disclaimer in                   */
/*     the documentation and/or other materials provided with the                        */
/*     distribution.                                                                     */
/*                                                                                       */
/*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''                   */
/*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                    */
/*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                      */
/*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR                  */
/*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,                         */
/*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT                     */
/*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF                     */
/*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND                  */
/*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,                   */
/*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                   */
/*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF                   */
/*  SUCH DAMAGE.                                                                         */
/*=======================================================================================*/
/* */

function cache_init() -> unit = {
	//print("cache init!");
	// foreach (i from 0 to 100) {
	// 	print_mem("lfsr" ^ " -> " ^ BitStr(lfsr));
	// 	print_int("victim = ", get_victim());
	// 	lfsr_next();
	// };
	// print_int("victim = ", get_victim());
	l1i_cache_clean_invalidate();
	l1d_cache_clean_invalidate();
	l2_cache_clean_invalidate()
}

/* get cache set */
val get_set : forall ('sets_t : Int), 'sets_t > 0. 
	(xlenbits, atom('sets_t)) -> range(0, 'sets_t - 1)
function get_set(addr, sets) = {
	min(int_of_bits((addr >> idx_shift) & to_bits(sizeof(xlen), sets - 1)), sets - 1);
}
/* get cache set */

/* match tag */
function match_l1i_tag(addr: xlenbits) -> option(range(0, l1i_ways_t - 1)) = {
	let set = get_set(addr, l1i_sets);
	let tag = (addr >> idx_shift) | valid;
	foreach (i from 0 to (l1i_ways - 1)) {
		if tag == (l1i_cache[set][i] & ~(dirty)) then return Some(i)
	};
	return None()
}
function match_l1d_tag(addr: xlenbits) -> option(range(0, l1d_ways_t - 1)) = {
	let set = get_set(addr, l1d_sets);
	let tag = (addr >> idx_shift) | valid;
	foreach (i from 0 to (l1d_ways - 1)) {
		if tag == (l1d_cache[set][i] & ~(dirty)) then return Some(i)
	};
	return None()
}
function match_l2_tag(addr: xlenbits) -> option(range(0, l2_ways_t - 1)) = {
	let set = get_set(addr, l2_sets);
	let tag = (addr >> idx_shift) | valid;
	foreach (i from 0 to (l2_ways - 1)) {
		if tag == (l2_cache[set][i] & ~(dirty)) then return Some(i)
	};
	return None()
}
/* match tag */

/* get victim way */
val get_victim_way : forall ('ways_t : Int), 'ways_t > 0.
	(atom('ways_t)) -> range(0, 'ways_t - 1)
function get_victim_way(ways) = {
	acc : nat = 0; bit_val : nat = 1;
	bound = min(max(log2(ways) - 1, 0), 31);
	foreach(i from 0 to bound) {
		if bit_to_bool(lfsr[i])
		then acc = acc + bit_val;
		bit_val = bit_val * 2;
	};
	lfsr_next();
	min(acc, ways - 1)
}
/* get victim way */

function l2_cache_access(addr: xlenbits, store: bool) -> unit = {
	if store then l2_write_accesses = l2_write_accesses + 1 
	else l2_read_accesses = l2_read_accesses + 1;

	let set = get_set(addr, l2_sets);
	let way_hit = match_l2_tag(addr);
	match way_hit {
		Some(hit_way) => {
			if store then l2_cache[set][hit_way] = l2_cache[set][hit_way] | dirty;
			return ()
		},
		None() => {
			if store then write_misses = write_misses + 1
			else read_misses = read_misses + 1;
			
			if cache_log then {
				print("L2 cache: ");
				if store then print("write miss" ^ BitStr(addr))
				else print("read miss" ^ BitStr(addr))
			};
			
			victim_way = get_victim_way(l2_ways);
			victim : xlenbits = l2_cache[set][victim_way];
			if (victim & vadty) == vadty 
			then l2_writebacks = l2_writebacks + 1;

			let data: xlenbits = (addr >> idx_shift) | valid;
			if store then l2_cache[set][victim_way] = data | dirty;
			l2_cache[set][victim_way] = data
		}
	}
}

function l1i_cache_access(addr: xlenbits/*, store: bool*/) -> unit = {
	/*if store then l1i_write_accesses = l1i_write_accesses + 1 
	else */l1i_read_accesses = l1i_read_accesses + 1;

	let set = get_set(addr, l1i_sets);
	let way_hit = match_l1i_tag(addr);
	match way_hit {
		Some(hit_way) => {
			/* if store then l1i_cache[set][hit_way] = l1i_cache[set][hit_way] | dirty */
			return ()
		},
		None() => {
			/* if store then l1i_write_misses = l1i_write_misses + 1
			else */ l1i_read_misses = l1i_read_misses + 1;
			
			if cache_log then {
				print("L1I cache: ");
				/* if store then print("write miss" ^ BitStr(addr))
				else */print("read miss" ^ BitStr(addr))
			};
			
			victim_way = get_victim_way(l1i_ways);
			/*
			victim : xlenbits = l1i_cache[set][victim_way]
			if (victim & vadty) == vadty then {
				victim_addr = (victim & (~(vadty))) << idx_shift;
				l2_cache_access(victim_addr, true)
				l1i_writebacks = l1i_writebacks + 1
			};
			*/

			let data: xlenbits = (addr >> idx_shift) | valid;
			/* if store then l1i_cache[set][victim_way] = data | dirty */
			l1i_cache[set][victim_way] = data;
			l2_cache_access(addr, false)
		}
	}
}

function l1d_cache_access(addr: xlenbits, store: bool) -> unit = {
	if store then l1d_write_accesses = l1d_write_accesses + 1 
	else l1d_read_accesses = l1d_read_accesses + 1;

	let set = get_set(addr, l1d_sets);
	let way_hit = match_l1d_tag(addr);
	match way_hit {
		Some(hit_way) => {
			if store then l1d_cache[set][hit_way] = l1d_cache[set][hit_way] | dirty;
			return ()
		},
		None() => {
			if store then l1d_write_misses = l1d_write_misses + 1
			else l1d_read_misses = l1d_read_misses + 1;
			
			if cache_log then {
				print("L1D cache: ");
				if store then print("write miss" ^ BitStr(addr))
				else print("read miss" ^ BitStr(addr))
			};
			
			victim_way = get_victim_way(l1d_ways);
			victim : xlenbits = l1d_cache[set][victim_way];
			if (victim & vadty) == vadty then {
				victim_addr = (victim & (~(vadty))) << idx_shift;
				l2_cache_access(victim_addr, true);
				l1d_writebacks = l1d_writebacks + 1
			};

			let data: xlenbits = (addr >> idx_shift) | valid;
			if store then l1d_cache[set][victim_way] = data | dirty;
			l1d_cache[set][victim_way] = data;
			l2_cache_access(addr, false)
		}
	}
}

/*
val cache_access : (cache_name, xlenbits, bool) -> unit
function cache_access(cache: cache_name, addr: xlenbits, store: bool) = {
	if store then write_accesses = write_accesses + 1 
	else read_accesses = read_accesses + 1;

	let set : nat = match cache {
		L1I => get_set(addr, l1i_sets),
		L1D => get_set(addr, l1d_sets),
		L2  => get_set(addr, l2_sets)
	};
	let way_hit : nat = match cache {
		L1I => match_l1i_tag(addr),
		L1D => match_l1d_tag(addr),
		L2  => match_l2_tag(addr)
	};
	match way_hit {
		Some(hit_way) => {
			if store then {
				match cache {
					L1I => l1i_cache[set][hit_way] = l1i_cache[set][hit_way] | dirty,
					L1D => l1d_cache[set][hit_way] = l1d_cache[set][hit_way] | dirty,
					L2  => l2_cache[set][hit_way] = l2_cache[set][hit_way] | dirty
				}
			};
			return ()
		},
		None() => {
			if store then write_misses = write_misses + 1
			else read_misses = read_misses + 1;
			
			if log then {
				match cache {
					L1I => print("L1I cache: "),
					L1D => print("L1D cache: "),
					L2  => print("L2 cache: ")
				};
				if store then print("write miss" ^ BitStr(addr))
				else print("read miss" ^ BitStr(addr))
			};
			
			victim_way = match cache {
				L1I => get_victim_way(l1i_ways),
				L1D => get_victim_way(l1d_ways),
				L2  => get_victim_way(l2_ways)
			};
			victim : xlenbits = match cache {
				L1I => l1i_cache[set][victim_way],
				L1D => l1d_cache[set][victim_way],
				L2  => l2_cache[set][victim_way]
			};
			if (victim & vadty) == vadty then {
				victim_addr = (victim & (~(vadty))) << idx_shift;
				match cache {
					L1I => cache_access(L2, victim_addr, true),
					L1D => cache_access(L2, victim_addr, true),
					L2  => ()
				};
				writebacks = writebacks + 1
			};

			let data: xlenbits = (addr >> idx_shift) | valid;
			match cache {
				L1I => l1i_cache[set][victim_way] = data,
				L1D => l1d_cache[set][victim_way] = data,
				L2  => l2_cache[set][victim_way] = data
			};
			match cache {
				L1I => cache_access(L2, addr, false),
				L1D => cache_access(L2, addr, false),
				L2 => ()
			};

			if store 
			then {
				data = data | dirty;
				match cache {
					L1I => l1i_cache[set][victim_way] = data,
					L1D => l1d_cache[set][victim_way] = data,
					L2  => l2_cache[set][victim_way] = data
				}
			}
		}
	}
}
*/
