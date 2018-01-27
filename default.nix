with import <nixpkgs> {};
with stdenv;

with import ./lib/lib.nix;
with import ./lib/sprocket;

let resources = runLocally "resources-1.12" {
      sphax = fetchurl {
        url = https://madoka.brage.info/baughn/Sphax64x_FTB_Revelation.zip;
        sha256 = "03jdl0y2z00gnvc18gw69jcx08qigf6fbj09ii21gikh1fg4imfi";
      };
    } ''
      mkdir -p $out/resourcepacks $out/shaderpacks
      #ln -s $seus $out/shaderpacks/SEUS-v11.0.zip
      #ln -s $faithful $out/resourcepacks/F32-1.10.2.zip
      ln -s $sphax $out/resourcepacks/Sphax.zip
    '';
in

rec {

  packs = {
    e18 = buildPack e18;
    e19 = buildPack e19;
  };

  e19 = {
    name = "e19";
    screenName = "e19";
    description = "Erisia #19: Carpe Novum";
    ram = "10000m";
    port = 25565;
    forge = {
      major = "1.12.2";
      minor = "14.23.1.2604";  # TODO: Should be able to get this from manifest.json
    };
    # These are copied to the client as well as the server.
    # Suggested use: Configs. Scripts. That sort of thing.
    # Higher entries override later ones.
    extraDirs = [
      ./base/erisia
      ./third_party/ruins-1.12
      ./base/revelation
    ];
    extraServerDirs = [
      ./base/server
    ];
    extraClientDirs = [
      resources
    ];
    # These are all the mods we'd like to include in this pack.
    manifests = [
      ./manifest/e19.nix
    ];
    blacklist = [
      "creeperhost-minetogether"  # Fuck that.
    ];
  };

  e18 = tppi2 // {
    name = "e18";
    description = "Erisia #18: Test Pack, Don't Ignore";
    screenName = "e18";
    ram = "10000m";
    port = 25565;
    manifests = [
      ./manifest/e18.nix
    ];
    extraDirs = [
      ./base/erisia
      ./base/tppi2
    ];
    # Not all mods are equally welcome.
    blacklist = [
      "mystcraft"
    ];
  };

  tppi2 = {
    ram = "6000m";
    forge = {
      major = "1.7.10";
      minor = "10.13.4.1614";
    };
    # These are copied to the client as well as the server.
    # Suggested use: Configs. Scripts. That sort of thing.
    # Higher entries override later ones.
    extraDirs = [
      ./base/tppi2
      # resources
      # (generateCustomOreGenConfig ./COGConfig)
    ];
    extraServerDirs = [
      ./base/server
    ];
    extraClientDirs = [
      # resources
    ];
    # These are all the mods we'd like to include in this pack.
    manifests = [
      ./manifest/TPPI2.nix
    ];
  };

  ServerPack = buildServerPack rec {
    inherit packs;
    hostname = "madoka.brage.info";
    urlBase = "https://madoka.brage.info/pack/";
  };

  # To use:
  # nix-build -A ServerPackLocal && (cd result && python -m SimpleHTTPServer)
  ServerPackLocal = buildServerPack rec {
    inherit packs;
    hostname = "localhost:8000";
    urlBase = "http://" + hostname + "/";
  };

  web = callPackage ./web {};
}
