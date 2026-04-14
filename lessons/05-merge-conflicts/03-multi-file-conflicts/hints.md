## Hint 1

In the **Files** panel you should see four files with `UU` status. Start with `libs/common/src/common.py` since it is the shared library that other files depend on. Select it and press `<enter>` to enter the conflict view.

## Hint 2

For each file, use `b` to pick both sides of each conflict section. Navigate between conflict sections with `<up>`/`<down>`. After resolving all sections in a file, press `<esc>` and stage the file with `<space>`. Then move to the next `UU` file.

## Hint 3

Work through the files in this order: `libs/common/src/common.py`, then `services/api/src/main.py`, then `services/worker/src/main.py`, then `infra/helm/values.yaml`. For each one, enter the conflict view with `<enter>`, resolve with `b` (both), `<esc>` back, and stage with `<space>`.

## Hint 4

After all four files are resolved and staged (no more `UU` entries in the Files panel), complete the merge. Press `c` to create the merge commit, accept the default merge message with `<enter>`. Verify with `./train.sh verify 5/3`.
