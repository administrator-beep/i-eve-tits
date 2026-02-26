EVE Static Data (SDE) — Ignored in Git
-----------------------------------

This directory contains EVE Online static-data files (JSON Lines format). They are large and are excluded from version control to keep the repository small.

Ignored files
- All `*.jsonl` and `*.json` files are ignored by `.gitignore`.

Compressing the data
- To create a ZIP (PowerShell):

```powershell
Compress-Archive -Path "*.jsonl" -DestinationPath ..\eve-static-data.zip
```

- To create a tar.gz (Windows 10+ with tar):

```powershell
tar -czf ..\eve-static-data.tar.gz *.jsonl
```

Restoring the data
- To extract a ZIP (PowerShell):

```powershell
Expand-Archive -Path ..\eve-static-data.zip -DestinationPath .
```

If you prefer to commit a compressed archive instead of individual files, add the archive's filename to the repo (and remove it from `.gitignore` if needed).
