local k8s = std.extVar("k8s");
local complex = std.extVar("complex");
local my_json = std.extVar("my_json");
local mydefine = std.extVar("mydefine");
local non_stamp = std.extVar("non_stamp");

{
  file1: "test",
  mydefine: mydefine,
  non_stamp: non_stamp,
  k8s: k8s,
  complex: complex.nested,
  my_json: my_json,
}
