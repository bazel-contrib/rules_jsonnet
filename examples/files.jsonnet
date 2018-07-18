local test = std.extVar("test");
local codefile = std.extVar("codefile");
local my_test = std.extVar("MYTEST");
local my_jsonnet = std.extVar("MYJSONNET");
local str = std.extVar("str's");
local mydefine = std.extVar("mydefine");
local complex = std.extVar("complex");

{
  str: str,
  mydefine: mydefine,
  file1: test,
  file2: codefile.weather,
  my_test: my_test,
  my_jsonnet: my_jsonnet.code,
  complex: complex.key1,
}
