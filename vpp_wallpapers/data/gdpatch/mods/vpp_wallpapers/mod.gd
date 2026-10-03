extends Node

const MOD_WALLPAPER_PATH = "res://gdpatch/mods/vpp_wallpapers/wallpaper"


func _ready():
	print("=== Loading mod wallpapers ===")
	print("MOD_WALLPAPER_PATH: ", MOD_WALLPAPER_PATH)

	await get_tree().process_frame

	print("AppearanceManager wallpapers count: ", AppearanceManager.wallpapers.size())

	var dir := DirAccess.open(MOD_WALLPAPER_PATH)

	if dir == null:
		print("ERROR: Failed to open directory: ", MOD_WALLPAPER_PATH)
		print("DirAccess error code: ", DirAccess.get_open_error())
		return

	print("Directory opened successfully")
	dir.list_dir_begin()
	var file_count := 0
	var loaded_count := 0

	while true:
		var file_name := dir.get_next()

		if file_name == "":
			break

		file_count += 1
		print("Found #", file_count, ": ", file_name)

		if dir.current_is_dir():
			continue

		if file_name.to_lower().ends_with(".png"):
			var full_path := MOD_WALLPAPER_PATH.path_join(file_name)
			var absolute_path := ProjectSettings.globalize_path(full_path)

			var image: Image = null

			if FileAccess.file_exists(absolute_path):
				image = Image.load_from_file(absolute_path)

			if image == null:
				image = Image.load_from_file(full_path)

			if image == null and ResourceLoader.exists(full_path):
				var tex := load(full_path) as Texture2D
				if tex != null and tex.get_image() != null:
					image = tex.get_image()

			if image == null:
				print("  ERROR: Failed to load image")
				continue

			print("  Image loaded, size: ", image.get_size())

			var texture := ImageTexture.create_from_image(image)

			if texture == null:
				print("  ERROR: Failed to create texture")
				continue

			var stem := file_name.get_basename()
			var wallpaper := WallpaperDefinition.new()
			wallpaper.id = stem
			wallpaper.number = 9000 + loaded_count
			wallpaper.display_name = stem + ".jpeg"
			wallpaper.texture = texture
			wallpaper.starter = true

			AppearanceManager.wallpapers[stem] = wallpaper
			loaded_count += 1

			print("  ✓ Wallpaper '", stem, "' loaded")

	dir.list_dir_end()

	print("=== Summary ===")
	print("Total files found: ", file_count)
	print("Wallpapers loaded: ", loaded_count)
	print("AppearanceManager wallpapers count: ", AppearanceManager.wallpapers.size())

	if loaded_count > 0:
		print("Reapplying profile settings...")

		if SaveManager.active_slot != 0:
			AppearanceManager.apply_from_profile()

		AppearanceManager.appearance_changed.emit()
		print("appearance_changed signal emitted")

