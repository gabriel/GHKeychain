Pod::Spec.new do |spec|
  spec.name         = "GHKeychain"
  spec.version      = "1.2.6"
  spec.summary      = "Keychain library for Mac and iOS."
  spec.homepage     = "https://github.com/soffes/sskeychain"
  spec.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  spec.source       = { :git => "https://github.com/gabriel/GHKeychain.git", :tag => spec.version }
  spec.description  = "Framework for using the Keychain in Mac OS X and iOS."
  spec.source_files = "GHKeychain/*.{h,m}"
  spec.requires_arc = true
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.frameworks = "Security", "Foundation"
end
