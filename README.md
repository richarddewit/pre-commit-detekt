# pre-commit-detekt

_pre-commit-detekt_ is a [pre-commit](https://pre-commit.com/) hook for [detekt](https://github.com/detekt/detekt).
**_pre-commit-detekt_ does not require pre-installation of detekt-cli.**

## Quick start

Append the following to your `.pre-commit-config.yaml`:

```yaml
# .pre-commit-config.yaml
repos:
  # ....
  - repo: https://github.com/quwac/pre-commit-detekt
    rev: v1.22.0  # Set detekt version >= v1.22.0. See https://github.com/detekt/detekt/tags
    hooks:
      - id: detekt-docker
```

## Configuration

pre-commit-detekt supports all the options of detekt. You can pass them as arguments to the hook.

```yaml
# .pre-commit-config.yaml
repos:
  # ....
  - repo: https://github.com/quwac/pre-commit-detekt
    rev: v1.22.0
    hooks:
      - id: detekt-docker
        args: [
          --all-rules,
          --auto-correct,
          --config,
          config/detekt.yml,  # Make detekt.yml in `./config` directory.
          --plugins,
          detekt-plugins/detekt-formatting-1.22.0.jar,  # Download detekt-formatting-1.22.0.jar in `./detekt-plugins` directory.
          --report,
          html:detekt.html
        ]
```

You can also run pre-commit-detekt in your host environment.
Replace the `id` from `detekt-docker` with `detekt`.
`detekt` requires Java installation.

```yaml
# .pre-commit-config.yaml
repos:
  # ....
  - repo: https://github.com/quwac/pre-commit-detekt
    rev: v1.22.0
    hooks:
      - id: detekt  # 👈 HERE!
        args: [
          --all-rules,
          --auto-correct,
          --config,
          config/detekt.yml,
          --plugins,
          detekt-plugins/detekt-formatting-1.22.0.jar,
          --report,
          html:detekt.html
        ]
```
