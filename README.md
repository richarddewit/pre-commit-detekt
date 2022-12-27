# pre-commit-detekt

Runs [detekt](https://github.com/detekt/detekt) on modified .kt/.kts files

# Quick start

Append the following to your `.pre-commit-config.yaml`:

```yaml
# .pre-commit-config.yaml
repos:
  # ....
  - repo: https://github.com/quwac/pre-commit-detekt
    rev: v1.22.0  # detekt version
    hooks:
      - id: detekt
```

# Configuration

pre-commit-detekt supports all the options of detekt. You can pass them as arguments to the hook.

```yaml
# .pre-commit-config.yaml
repos:
  # ....
  - repo: https://github.com/quwac/pre-commit-detekt
    rev: v1.22.0
    hooks:
      - id: detekt
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

You can also run pre-commit-detekt in a Docker container environment.
Replace the `id` from `detekt` with `detekt-docker`.

```yaml
# .pre-commit-config.yaml
repos:
  # ....
  - repo: https://github.com/quwac/pre-commit-detekt
    rev: v1.22.0
    hooks:
      - id: detekt-docker  # 👈 HERE!
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
