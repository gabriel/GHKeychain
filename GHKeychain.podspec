Pod::Spec.new do |spec|
  spec.name         = 'GHKeychain'
  spec.version      = '1.2.3'
  spec.summary      = 'Simple Cocoa wrapper for the keychain that works on Mac and iOS.'
  spec.homepage     = 'https://github.com/soffes/sskeychain'
  spec.author       = { 'Gabriel Handford' => 'gabrielh@gmail.com' }
  spec.source       = { :git => 'https://github.com/gabriel/GHKeychain.git', :tag => spec.version }
  spec.description  = 'GHKeychain is a simple utility class for making the system keychain less sucky.'
  spec.source_files = 'GHKeychain/*.{h,m}'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.frameworks = 'Security', 'Foundation'
end
