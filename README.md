# love-gamejolt-api

This is the lua script I've used to upload high-scores to GameJolt in the past. 
It isn't very featureful, since all I needed was to upload a high-score. Hopefully
it will help you get started using the GameJolt API through LOVE2D!

## Example

```lua
local gj = GameJolt(game_id, private_key)

gj.connect_user(username, token)
gj.add_score("100 points", 100)
```

Check out the [example app]!

[0]: https://github.com/variousauthors/love-gamejolt-api-example
