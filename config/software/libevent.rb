name "libevent"
default_version "2.0.22"

source url: "https://github.com/libevent/libevent/archive/release-#{version}-stable.tar.gz",
       md5: "8913ef56ec329f2c046007bd634c7201"

relative_path "libevent-release-#{version}-stable"
env = with_standard_compiler_flags(with_embedded_path)

build do
  command "./autogen.sh"
  command "./configure" \
          " --disable-dependency-tracking" \
          " --disable-shared" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make  "install"
end
