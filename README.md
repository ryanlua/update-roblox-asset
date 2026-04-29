# Update Roblox Asset

GitHub Action for updating assets on Roblox.

## Usage

```yaml
- uses: ryanlua/update-roblox-asset@v1
  with:
    api-key: ${{ secrets.OPEN_CLOUD_API_KEY }}
    asset-id: 13947506401
    file: model.rbxm
```

## Inputs

| Input          | Required | Description                                                   |
| -------------- | -------- | ------------------------------------------------------------- |
| `api-key`      | Yes      | Open Cloud API key with `asset:read` and `asset:write` scopes |
| `asset-id`     | Yes      | ID of the asset to update                                     |
| `file`         | Yes      | Path to `.rbxm` or `.rbxmx` asset file                        |
| `display-name` | No       | New display name for the asset                                |
| `description`  | No       | New description for the asset                                 |

## Outputs

| Output         | Description           |
| -------------- | --------------------- |
| `operation-id` | ID of asset operation |
