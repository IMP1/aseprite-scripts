--[[
Remove Padding v0.1.0
  Made by Huw Taylor

This script removes padding in between tiles in a tile-sheet.
This was useful for me when dealing with spritesheets that had padding added in between tiles.

Version History:
  * v0.1.0 [2023-07-18] : Initial development
]]--

local sprite = app.sprite

if not sprite then
    app.alert("There is no sprite to edit")
    return
end

-- Dialog prompt to get dimensions for an individual sprite
local d = Dialog("Split Tiles to Layers")
d:label({ id="help", label="", text="Set the padding values to remove:" })
 :number({ id="tile_width", label="Tile Width:", text="16", focus=true })
 :number({ id="tile_height", label="Tile Height:", text="16" })
 :number({ id="tile_padding_x", label="Tile Horizontal Padding:", text="1" })
 :number({ id="tile_padding_y", label="Tile Vertical Padding:", text="1" })
 :number({ id="initial_margin_x", label="Initial Horizontal Margin:", text="0" })
 :number({ id="initial_margin_y", label="Initial Vertical Margin:", text="0" })
 :button({ id="ok", text="&OK", focus=true })
 :button({ text="&Cancel" })
 :show()

local data = d.data
if not data.ok then 
    return 
end

--[[
    Padding Remover Class
    @param {Sprite} sprite The sprite sheet to split
    @param {Number} tile_width The width in pixels for an individual tile
    @param {Number} tile_height The height in pixels for an individual tile
    @param {Number} tile_padding_x The height in pixels between each tile horizontally
    @param {Number} tile_padding_y The height in pixels between each tile vertically
    @param {Number} initial_margin_x The width in pixels before the first tile
    @param {Number} initial_margin_y The height in pixels before the first tile
    @return {Table} MarginRemover instance
]]--
function PaddingRemover(sprite, tile_width, tile_height, tile_padding_x, tile_padding_y, initial_margin_x, initial_margin_y)
    local self = {}
    self.sprite = sprite
    self.tile_width = tile_width
    self.tile_height = tile_height
    self.tile_padding_x = tile_padding_x
    self.tile_padding_y = tile_padding_y
    self.initial_margin_x = initial_margin_x
    self.initial_margin_y = initial_margin_y
    local tiles_wide = math.floor((self.sprite.width - self.initial_margin_x) / (self.tile_width + self.tile_padding_x))
    local tiles_high = math.floor((self.sprite.height - self.initial_margin_y) / (self.tile_height + self.tile_padding_y))

    --[[
        Iterate over each tile in the sheet and removes the margins in between
    ]]--
    self.removePadding = function()
        local new_sprite = Sprite(tiles_wide * self.tile_width, tiles_high * self.tile_height)
        local old_image = Image(self.sprite)
        local vertical_flat_image = Image(self.sprite.width, tiles_high * self.tile_height)

        for j = 0, tiles_high - 1 do
            local y = self.initial_margin_y + j * (self.tile_padding_y + self.tile_height)
            local tile_rect = Rectangle(0, y, old_image.width, self.tile_height)
            local tile = Image(old_image, tile_rect)
            vertical_flat_image:drawImage(tile, Point(0, j * tile_height))
        end

        local horizontal_flat_image = Image(tiles_wide * self.tile_width, tiles_high * self.tile_height)
        for i = 0, tiles_wide - 1 do
            local x = self.initial_margin_x + i * (self.tile_padding_x + self.tile_width)
            local tile_rect = Rectangle(x, 0, self.tile_width, vertical_flat_image.height)
            local tile = Image(vertical_flat_image, tile_rect)
            horizontal_flat_image:drawImage(tile, Point(i * tile_width, 0))
        end

        new_sprite.cels[1].image = horizontal_flat_image
    end

    return self
end

-- Initializes the paddingRemover for removing the padding
local paddingRemover = PaddingRemover(sprite, data.tile_width, data.tile_height, data.tile_padding_x, data.tile_padding_y, data.initial_margin_x, data.initial_margin_y)

-- Call method to remove padding from the iage as one transaction,
-- allow a single undo
app.transaction(function()
    paddingRemover.removePadding()
end)
