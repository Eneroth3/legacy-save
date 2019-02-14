module Eneroth
module LegacySave

  # Get SketchUp version string of a saved file.
  #
  # @param path [String]
  #
  # @raise [IOError]
  #
  # @return [String]
  def self.version(path)
    v = File.binread(path, 64).tr("\x00", "")[/{([\d.]+)}/n, 1]

    v || raise(IOError, "Can't determine SU version for '#{path}'. Is file a model?")
  end

  # Get version parameter for Sketchup::Model#save from version string.
  #
  # @param version [String]
  #
  # @return [Object]
  def self.version_param(version)
    major_version = version.to_i

    major_version += 2000 if major_version > 8

    # Assume the constants Sketchup::Model::VERSION_XXXX, where XXXX is the
    # major version number, will be made available for all future versions too.
    Sketchup::Model.const_get("VERSION_#{major_version}")
  end

  # Save the model in the version it was previously saved to, or open save
  # panel.
  #
  # @return [Void]
  def self.legacy_save
    path = Sketchup.active_model.path

    if path.empty?
      Sketchup.send_action("saveDocument:")
      return
    end

    version = version(path)
    if version.to_i == Sketchup.version.to_i
      Sketchup.active_model.save(path)
    else
      version_id = version_param(version)
      Sketchup.active_model.save(path, version_id)
    end
  rescue StandardError => e
    UI.messagebox("Save Error\n\n#{e.message}")
  end

  # Add menu item at custom position in menu.
  #
  # The custom position is only used in SketchUp for Windows version 2016 and
  # above. In other versions the menu item will be placed at the end of the
  # menu. Please note that this is an undocumented SketchUp API behavior that
  # may be subject to change.
  #
  # @param menu [UI::Menu]
  # @param name [String]
  # @param position [Integer, nil]
  #
  # @return [Integer] identifier of menu item.
  def self.add_menu_item(menu, name, position = nil, &block)
    if position && Sketchup.version.to_i >= 16
      menu.add_item(name, position, &block)
    else
      menu.add_item(name, &block)
    end
  end

  # Get index to place Save in Legacy Format entry at.
  #
  # @return [Integer]
  def self.menu_index
    # Entry should be placed in File menu after all native save related entries,
    # but before revert.
    #
    # Win:
    #   New
    #   Open...
    #   ---
    #   Save
    #   Save As...
    #   Save A Copy As...
    #   Save As Template...
    #   <-- Here
    #
    # Mac:
    #   New
    #   Open...
    #   Open Recent
    #   ---
    #   Close
    #   Save
    #   Save As...
    #   Save A Copy As...
    #   Save As Template...
    #   <-- Here
    position = Sketchup.platform == :platform_win ?  7 : 9

    # Move one step down if Eneroth Open Newer Version is present, as its entry
    # is located further up in the Open section.
    # Note that this is not a general solution that accounts for any other
    # extension, only Eneroth open Newer Version.
    if defined?(Eneroth::OpenNewerVersion) && Eneroth::OpenNewerVersion::EXTENSION.loaded?
      position += 1
    end

    position += 1 if Sketchup.version.to_i > 18

    position
  end

  unless @loaded
    @loaded = true

    menu = UI.menu("File")
    add_menu_item(menu, "Save in Legacy Format", menu_index) { legacy_save }
  end

end
end
