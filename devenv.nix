{ pkgs, ... }:
{
  packages = [ pkgs.coreutils ];

  processes.hello.exec = "echo 'hello world' && sleep infinity";
}
