extends Node

func sci_no(val: float, sig_figs: int = 1) -> String:
	if val == 0.0: return "0"
	
	var vsign: int = sign(val)
	val = abs(val)
	
	var order: int = floor(log(val) / log(10))
	var coefficient: float = val / pow(10, order)
	return "%.*fe%d" % [sig_figs, coefficient, int(order) * vsign]
