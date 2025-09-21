walker Hello {
  can run with `root entry {
    print("hi");
  }
}
with entry { root spawn Hello(); }

