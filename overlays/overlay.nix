(final: prev: {
  # gpu-screen-recorder = prev.callPackage ./gpu-screen-recorder { };
  # gpu-screen-recorder-ui = prev.callPackage ./gpu-screen-recorder/ui { };
  # gpu-screen-recorder-notification = prev.callPackage ./gpu-screen-recorder/notif { };
  inter = prev.callPackage ./inter { };
  klassy = prev.callPackage ./klassy { };
  moondeck-buddy = prev.callPackage ./moondeck-buddy { };
  plymouth = prev.plymouth.overrideAttrs (
    { src, ... }:
    {
      version = "24.004.60-unstable-2025-05-15";

      src = src.override {
        rev = "bc6c67dc1172a2041d275472f56948298ddde800";
        hash = "sha256-rR8ZoAoXlXpbgOAPrZwt65lykn0hbYJlRZJ/GFUobMo=";
      };
    }
  );
})
