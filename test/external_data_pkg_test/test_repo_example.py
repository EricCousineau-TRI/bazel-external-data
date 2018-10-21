from os.path import isfile

filename = "external/repo_example/basic.bin"
assert isfile(filename)
with open(filename) as f:
    c = f.read()
    assert c == "Content for 'basic.bin'\n", c
