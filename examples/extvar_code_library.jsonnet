local codefile = std.extVar('codefile');
local data = importstr 'file.txt';

{
  job: codefile.workflow.Job,
  shJob: codefile.workflow.ShJob,
  data: data,
}
