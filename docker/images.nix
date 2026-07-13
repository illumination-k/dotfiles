# nixで直接ビルドするOCIイメージ（旧docker/Dockerfile.ciの置き換え）。
#   nix build .#docker-runtime  → devenv:latest      (slim runtime)
#   nix build .#docker-dev      → devenv-dev:latest  (K8s dev pod: sshd + herdr)
# streamLayeredImageはイメージtarをstdoutへ書くスクリプトを返すので、
# `./result | docker load` でロードする。
#
# 旧Dockerfileとの差分:
# - home-manager activationは実行せず、activationPackageのhome-files
#   （$HOME配下のdotfile群）をイメージビルド時に展開する。
#   PATHは従来どおり ~/result/home-path/bin を直接通す。
# - nix自体はイメージに含まれない（クロージャのみ）。
{ pkgs
, homeConfiguration
, username ? "illumination-k"
, uid ? 1000
, gid ? 1000
}:

let
  inherit (pkgs) dockerTools;

  activation = homeConfiguration.activationPackage;
  homeDir = "/home/${username}";
  binPath = "${homeDir}/result/home-path/bin";

  # herdr: pinしたnixpkgsにまだ存在しない場合は公式リリースの
  # 静的バイナリへフォールバックする（flake update後は自動でnixpkgs版になる）。
  herdr = pkgs.herdr or (
    let
      version = "0.7.1";
      arch = pkgs.stdenv.hostPlatform.parsed.cpu.name; # x86_64 / aarch64
      sha256s = {
        x86_64 = "b965acaffc2c22f54b6e6c64af7cf8e98a3f4ac2622630a0599c67a4b9d8a654";
        aarch64 = "3d757ac30c631e79dc45038c3ecc6423fe13a89f9cffa0f415aedd2c27f1576c";
      };
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = "herdr-bin";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-${arch}";
        sha256 = sha256s.${arch};
      };
      dontUnpack = true;
      installPhase = ''
        install -Dm755 $src $out/bin/herdr
      '';
    }
  );

  # FHS互換の動的リンカ:
  # このイメージは/nix/storeベースで/lib64等のFHSパスが無いため、Nix外の
  # プリビルドバイナリ（uv管理のPython、PyInstaller/pipx製CLI等）が
  # インタプリタ /lib64/ld-linux-*.so を見つけられず起動できない。
  # nix-ldのシムをFHSのインタプリタパスへ置き、NIX_LD/NIX_LD_LIBRARY_PATHで
  # 実体のglibcローダーとライブラリ群へ委譲する（NixOSのprograms.nix-ld相当）。
  fhsLdDir = if pkgs.stdenv.hostPlatform.isx86_64 then "lib64" else "lib";
  fhsLd = pkgs.runCommand "image-fhs-ld" { } ''
    mkdir -p $out/${fhsLdDir}
    ln -s ${pkgs.nix-ld}/libexec/nix-ld \
      "$out/${fhsLdDir}/$(basename ${pkgs.stdenv.cc.bintools.dynamicLinker})"
  '';
  nixLdLibraryPath = pkgs.lib.makeLibraryPath (with pkgs; [
    glibc
    zlib
    zstd
    openssl
    bzip2
    xz
    curl
    stdenv.cc.cc # libstdc++ / libgcc_s
  ]);

  # runtime用/etc（rootのみ。ログインユーザーはdev側で追加）
  baseEtc = pkgs.runCommand "image-etc-base" { } ''
    mkdir -p $out/etc
    cat > $out/etc/passwd <<EOF
    root:x:0:0:root:/root:/bin/sh
    EOF
    cat > $out/etc/group <<EOF
    root:x:0:
    EOF
    cat > $out/etc/shadow <<EOF
    root:!::0:::::
    EOF
    cat > $out/etc/nsswitch.conf <<EOF
    passwd: files
    group: files
    shadow: files
    hosts: files dns
    EOF
  '';

  # dev用/etc: ログインユーザーとsshd特権分離ユーザーを追加
  devEtc = pkgs.runCommand "image-etc-dev" { } ''
    mkdir -p $out/etc
    cat > $out/etc/passwd <<EOF
    root:x:0:0:root:/root:/bin/sh
    ${username}:x:${toString uid}:${toString gid}::${homeDir}:${binPath}/zsh
    sshd:x:499:499:sshd privsep:/var/empty:/sbin/nologin
    EOF
    cat > $out/etc/group <<EOF
    root:x:0:
    ${username}:x:${toString gid}:
    sshd:x:499:
    EOF
    cat > $out/etc/shadow <<EOF
    root:!::0:::::
    ${username}:*:::::::
    EOF
    cat > $out/etc/nsswitch.conf <<EOF
    passwd: files
    group: files
    shadow: files
    hosts: files dns
    EOF
  '';

  # dev pod用スクリプト・設定・herdr
  devTree = pkgs.runCommand "image-dev-tree" { } ''
    mkdir -p $out/usr/local/bin $out/etc/ssh
    install -m0755 ${./entrypoint-dev.sh} $out/usr/local/bin/entrypoint-dev.sh
    install -m0755 ${./dev-login.sh} $out/usr/local/bin/dev-login
    ln -s ${herdr}/bin/herdr $out/usr/local/bin/herdr
    install -m0644 ${./sshd_config} $out/etc/ssh/sshd_config
  '';

  # $HOMEの構築（fakeroot下で実行され、所有権がイメージレイヤーに記録される）:
  # - ~/result → activationPackage（PATHとdev-login/entrypointが参照）
  # - home-filesのdotfile群を$HOMEへ展開（activateの代替）。
  #   storeからコピーしたディレクトリは555なので書き込み可へ戻す。
  homeSetup = ''
    mkdir -p ./root ./tmp ./workspace "./home/${username}"
    chmod 1777 ./tmp
    ln -s ${activation} "./home/${username}/result"
    cp -a ${activation}/home-files/. "./home/${username}/"
    find "./home/${username}" -type d -exec chmod u+w '{}' +
    chown -hR ${toString uid}:${toString gid} "./home/${username}" ./workspace
  '';

  devSetup = ''
    mkdir -p ./var/empty ./data/ssh ./run
    chmod 0711 ./var/empty
  '';

  commonEnv = [
    "USER=${username}"
    "HOME=${homeDir}"
    "PATH=${binPath}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    "NIX_LD=${pkgs.stdenv.cc.bintools.dynamicLinker}"
    "NIX_LD_LIBRARY_PATH=${nixLdLibraryPath}"
  ];

in
{
  docker-runtime = dockerTools.streamLayeredImage {
    name = "devenv";
    tag = "latest";
    maxLayers = 120;
    contents = [
      dockerTools.binSh
      dockerTools.usrBinEnv
      dockerTools.caCertificates
      fhsLd
      baseEtc
    ];
    fakeRootCommands = homeSetup;
    config = {
      Env = commonEnv;
      WorkingDir = homeDir;
      Cmd = [ "${binPath}/zsh" "-l" ];
    };
  };

  docker-dev = dockerTools.streamLayeredImage {
    name = "devenv-dev";
    tag = "latest";
    maxLayers = 120;
    contents = [
      dockerTools.binSh
      dockerTools.usrBinEnv
      dockerTools.caCertificates
      fhsLd
      devEtc
      devTree
    ];
    fakeRootCommands = homeSetup + devSetup;
    config = {
      Env = commonEnv ++ [
        "DEV_USER=${username}"
        "TERM=xterm-256color"
      ];
      ExposedPorts."22/tcp" = { };
      Entrypoint = [ "/usr/local/bin/entrypoint-dev.sh" ];
      WorkingDir = homeDir;
    };
  };
}
