extends Node

func sci_no(val: float, sig_figs: int = 1) -> String:
	if val == 0.0: return "0"
	
	var vsign := "+" if val > 1 else "-"
	val = abs(val)
	
	var order: int = floor(log(val) / log(10))
	var coefficient: float = val / pow(10, order)
	return "%.*fe%s%d" % [sig_figs, coefficient, vsign, abs(order)]
