"""String utility functions - realistic implementations to benchmark.

These are actual useful functions, not artificial benchmark stubs.
Simplified to work with current Mojo String API.
"""

from collections import List


fn concat_many_strings(count: Int) -> String:
    """Concatenate many strings - tests string builder performance."""
    var result = String("")
    for i in range(count):
        result += "item"
    return result


fn build_csv_line(fields: List[String]) -> String:
    """Build a CSV line from fields - realistic data processing."""
    var result = String("")
    for i in range(len(fields)):
        if i > 0:
            result += ","
        result += fields[i]
    return result


fn repeat_string(text: String, count: Int) -> String:
    """Repeat a string N times."""
    var result = String("")
    for _ in range(count):
        result += text
    return result


fn string_length_sum(strings: List[String]) -> Int:
    """Sum the lengths of multiple strings."""
    var total = 0
    for i in range(len(strings)):
        total += len(strings[i])
    return total


fn build_path(parts: List[String]) -> String:
    """Join path parts with slashes - realistic file path building."""
    var result = String("")
    for i in range(len(parts)):
        if i > 0:
            result += "/"
        result += parts[i]
    return result
