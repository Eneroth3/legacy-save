require "extensions.rb"

# Eneroth Extensions
module Eneroth

# Eneroth Active Layer
module LegacySave

  path = __FILE__
  path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

  PLUGIN_ID = File.basename(path, ".*")
  PLUGIN_DIR = File.join(File.dirname(path), PLUGIN_ID)

  EXTENSION = SketchupExtension.new(
    "Eneroth Legacy Save",
    File.join(PLUGIN_DIR, "main")
  )
  EXTENSION.creator     = "Eneroth3"
  EXTENSION.description = "Quickly saves model to a legacy Sketchup format."
  EXTENSION.version     = "1.0.1"
  EXTENSION.copyright   = "2019, #{EXTENSION.creator}"
  Sketchup.register_extension(EXTENSION, true)

end
end
