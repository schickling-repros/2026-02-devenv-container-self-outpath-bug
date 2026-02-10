# devenv container: `self.outPath` is a raw filesystem path, not a store path

Minimal reproduction for a bug where `devenv container run processes` (or `build`) fails because `self.outPath` resolves to a raw filesystem path instead of a Nix store path.

## Versions

- devenv: 2.0.0+3113123

## Reproduce

```bash
devenv container run processes
```

## Expected

Container builds and runs the process.

## Actual

Build fails during the `devenv-container-home` derivation with:

```
cp: cannot stat '/path/to/project': No such file or directory
```

The `mkHome` function in `containers.nix` does `cp -r ${self}` which interpolates `self.outPath`. Since `outPath` is a raw filesystem path (not a `/nix/store/...` path), it's inaccessible inside the Nix build sandbox.

## Root cause

In `devenv-nix-backend/bootstrap/resolve-lock.nix`, `rootSrc.outPath = src` receives `devenv_root` as a Nix string (serialized from Rust via `nix_args.rs`), not a Nix path. The source code has a comment acknowledging this ("hacker voice: I'm in" at line 15-16). When `containers.nix`'s `mkHome` uses `self` (which defaults from `copyToRoot`), it interpolates to a non-store path that doesn't exist in the sandbox.

## Issue

https://github.com/cachix/devenv/issues/2482
