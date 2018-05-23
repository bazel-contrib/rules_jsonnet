local k8s = std.extVar("k8s");
local complex = std.extVar("complex");

{
  file1: "test",
  k8s: k8s,
  complex: complex.nested,
}
