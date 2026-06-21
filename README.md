# configuration.nix

thanks https://github.com/JaKooLit

| name      | type     | lang        | alternative |
|-----------|----------|-------------|-------------|
| Rio       | terminal | Rust        | Kitty       |
| Sherlock  | launcher | Rust        | Vicinae     |
| Ashell    | Top bar  | Rust        | Bar-rs      |
| Nemo      | Files    | C           | Dolphin     |
| Zed       | IDE      | Rust        | ---         |

## Take a look:

https://github.com/vicinaehq/vicinae

https://github.com/Skxxtz/sherlock

## Useful commands

```shell
sudo nix-collect-garbage -d
```

```shell
sudo nixos-rebuild switch --impure --flake /etc/nixos
```

```shell
sudo nixos-rebuild dry-build --show-trace --impure --flake /etc/nixos
```

```shell
nixos-generate-config
```
