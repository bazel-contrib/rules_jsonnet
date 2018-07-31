local my_test = std.extVar("MYTEST");
local my_jsonnet = std.extVar("MYJSONNET");

{
  my_test: my_test,
  my_jsonnet: my_jsonnet.code,
}
