# 1. copy the previous version of the compiler to crystal-darwin
# 2. For the first run, comment any reference to llvm_bin from config/software/crystal.rb
bundle
brew uninstall llvm
brew uninstall crystal
bundle exec omnibus build crystal