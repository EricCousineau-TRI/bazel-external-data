from os.path import isfile

filename = "external/repo_example/test.txt"
assert isfile(filename)
with open(filename) as f:
    assert f.read() == "Hello world\n"
