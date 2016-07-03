CRYSTAL_VERSION = "0.18.6"
FIRST_RUN = ENV["FIRST_RUN"]

name "crystal"
default_version CRYSTAL_VERSION

source git: "https://github.com/crystal-lang/crystal"

dependency "pcre"
dependency "bdw-gc"
dependency "llvm_bin" unless FIRST_RUN
dependency "libevent"

env = with_standard_compiler_flags(with_embedded_path(
  "LIBRARY_PATH" => "#{install_dir}/embedded/lib"
))
env["CFLAGS"] << " -fPIC"

unless FIRST_RUN
  llvm_bin = Omnibus::Software.load(project, "llvm_bin")
end

output_bin = "#{install_dir}/embedded/bin/crystal"

if FIRST_RUN
  env["PATH"] = "#{project_dir}/deps:#{env["PATH"]}"
else
  env["PATH"] = "#{llvm_bin.project_dir}/bin:#{project_dir}/deps:#{env["PATH"]}"
end

if mac_os_x?
  env["CRYSTAL_PATH"] = "/private/var/cache/omnibus/src/crystal/src"
else
  env["CRYSTAL_PATH"] = "#{project_dir}/src"
end

build do
  command "git checkout #{CRYSTAL_VERSION}", cwd: project_dir

  mkdir "#{project_dir}/deps"
  command "make deps", env: env
  command "mkdir .build", env: env
  command "echo #{Dir.pwd}", env: env
  command "cp #{Dir.pwd}/crystal-#{ohai['os']}-#{ohai['kernel']['machine']} .build/crystal", env: env
  command "bin/crystal build src/compiler/crystal.cr --release -o #{output_bin} -D without_openssl -D without_zlib", env: env

  block do
    raise "Could not build crystal" unless File.exists?(output_bin)

    if mac_os_x?
      otool_libs = `otool -L #{output_bin}`
      if otool_libs.include?("/usr/local/lib")
        raise "Found local libraries linked to the generated compiler:\n#{otool_libs}"
      end
    end
  end

  sync "#{project_dir}/src", "#{install_dir}/src"
  sync "#{project_dir}/etc", "#{install_dir}/etc"
  sync "#{project_dir}/samples", "#{install_dir}/samples"
  mkdir "#{install_dir}/bin"

  erb source: "crystal.erb",
      dest: "#{install_dir}/bin/crystal",
      mode: 0755,
      vars: { install_dir: install_dir }
end
