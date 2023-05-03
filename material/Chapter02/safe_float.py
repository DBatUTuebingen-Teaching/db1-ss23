# convert string s to float (if that fails, return default float x instead)
def safe_float(s, x):
    try:
        f = float(s)
    except ValueError:
        f = x
    return f

m = max([ safe_float(y, -float("inf")) for y in ["1.0", "two", "3.0"] ])

print(m)
