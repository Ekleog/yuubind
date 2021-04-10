rec {
  pkgsSrc = builtins.fetchTarball {
    # The following is for nixos-unstable on 2020-12-13
    url = "https://github.com/NixOS/nixpkgs/archive/e9158eca70ae59e73fae23be5d13d3fa0cfc78b4.tar.gz";
    sha256 = "0cnmvnvin9ixzl98fmlm3g17l6w95gifqfb3rfxs55c0wj2ddy53";
  };
  naerskSrc = builtins.fetchTarball {
    # TODO: go back to an upstream version once https://github.com/nmattia/naersk/pull/136 lands
    url = "https://github.com/nmattia/naersk/archive/b1ebc5f1b4c3cbacb554d1d2d05d547a4951247d.tar.gz";
    sha256 = "01z4kj5b9anf01bb99q21xcr8kpfxq3hhpc9gkrv9khni6qpdpmk";
  };
  rustOverlaySrc = builtins.fetchTarball {
    # The following is the latest version as of 2020-12-13
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/8c007b60731c07dd7a052cce508de3bb1ae849b4.tar.gz";
    sha256 = "1zybp62zz0h077zm2zmqs2wcg3whg6jqaah9hcl1gv4x8af4zhs6";
  };
  rustOverlay = import rustOverlaySrc;
  pkgs = import pkgsSrc {
    overlays = [
      rustOverlay
      (self: super: {
        kannader = import ./. {};
      })
    ];
  };
  rustNightlyChannelRaw = pkgs.rustChannelOf {
    date = "2021-03-25";
    channel = "nightly";
    sha256 = "0pd74f1wc5mf8psrq3mr3xdzwynqil7wizaqq8s7kqfgxx4c4l7w";
  };
  naerskRaw = pkgs.callPackage naerskSrc {
    rustc = rustNightlyChannelRaw.rust;
    cargo = rustNightlyChannelRaw.cargo;
  };
  rustNightlyChannel = rustNightlyChannelRaw // {
    rust = rustNightlyChannelRaw.rust.override {
      targets = ["wasm32-wasi"];
    };
    # TODO: remove override when https://github.com/rust-lang/cargo/pull/9030
    # lands
    cargo = naerskRaw.buildPackage {
      pname = "cargo";
      version = "dev";
      src = builtins.fetchTarball {
        url = "https://github.com/rust-lang/cargo/archive/cae7be8a17d50d69ed80a9bc3bf3c5a052f2a568.tar.gz";
        sha256 = "1bh5fjrr245wsj0ib7c7yqp83d7brxbygya9fxjgmvkqra3vlgbj";
      };
      buildInputs = with pkgs; [ openssl pkg-config ];
      copySources = ["crates"];
    };
  };
  #rustBetaChannel = pkgs.rustChannelOf {
  #  date = "2018-04-20";
  #  channel = "beta";
  #};
  #rustStableChannel = pkgs.rustChannelOf {
  #  date = "2020-03-12";
  #  channel = "stable";
  #  sha256 = "0pddwpkpwnihw37r8s92wamls8v0mgya67g9m8h6p5zwgh4il1z6";
  #};
  naersk = pkgs.callPackage naerskSrc {
    rustc = rustNightlyChannel.rust;
    cargo = rustNightlyChannel.cargo;
  };
}
