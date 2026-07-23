class_name NumberFormatter
extends RefCounted

# Format large numbers with abbreviations
static func format_number(value: float, decimal_places: int = 2) -> String:
	var abs_value = abs(value)
	var sign = "-" if value < 0 else ""
	
	# For small numbers, show exactly
	if abs_value < 1000:
		if abs_value == floor(abs_value):
			return sign + str(int(abs_value))
		else:
			return sign + ("%.2f" % abs_value)
	
	# Use abbreviations for larger numbers
	var suffixes = ["", "K", "M", "B", "T", "P", "E"]
	var tier = 0
	
	while abs_value >= 1000 and tier < suffixes.size() - 1:
		abs_value /= 1000.0
		tier += 1
	
	var format_str = "%." + str(decimal_places) + "f"
	return sign + (format_str % abs_value) + suffixes[tier]

# Format number with thousands separators
static func format_number_with_separators(value: float) -> String:
	var int_value = int(value)
	var str_value = str(int_value)
	var formatted = ""
	var count = 0
	
	# Add commas every 3 digits from right to left
	for i in range(str_value.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			formatted = "," + formatted
		formatted = str_value[i] + formatted
		count += 1
	
	return formatted

# Format time as MM:SS or HH:MM:SS
static func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60
	
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]

# Format percentage (0-1 range to 0-100%)
static func format_percentage(value: float, decimal_places: int = 1) -> String:
	var format_str = "%." + str(decimal_places) + "f%%"
	return format_str % (value * 100.0)

# Format currency/credits
static func format_credits(value: float) -> String:
	return format_number(value) + " Credits"