local k8s = std.extVar("k8s");
local complex = std.extVar("complex");
local mydefine = std.extVar("mydefine");
local non_stamp = std.extVar("non_stamp");

{
  file1: "test",
  mydefine: mydefine,
  non_stamp: non_stamp,
  k8s: k8s,
  complex: complex.nested,
}
