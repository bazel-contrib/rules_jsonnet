local test = std.extVar("test");
local codefile = std.extVar("codefile");
local my_test = std.extVar("MYTEST");
local my_jsonnet = std.extVar("MYJSONNET");

{
  file1: test,
  file2: codefile.weather,
  my_test: my_test,
  my_jsonnet: my_jsonnet.code,
}
