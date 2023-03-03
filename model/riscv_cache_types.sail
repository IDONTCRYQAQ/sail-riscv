/* cache type */
enum cache_name = {L1I, L1D, L2}	
enum cache_policy_t = {LRU, FIFO, RANDOM}
enum cache_log_t = {O, LV1, LV2}
/* common cache config */
let cache_policy = LRU
type linesz_t : Int = 64/* byte */
let cache_log : bool = true
let cache_log_type : cache_log_t = LV2

/* cache config */
/* l1i cache config */
type l1i_sets_t : Int = 256
type l1i_ways_t : Int = 2
/* l1d cache config */
type l1d_sets_t : Int = 128
type l1d_ways_t : Int = 4
/* l2 cache config */
type l2_sets_t : Int = 2048
type l2_ways_t : Int = 16
