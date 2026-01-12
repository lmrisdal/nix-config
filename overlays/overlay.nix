(final: prev: {
  # moondeck-buddy = prev.callPackage ./moondeck-buddy { };
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
  jovian-greeter = final.callPackage ./jovian-greeter { };
})
