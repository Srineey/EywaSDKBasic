
Pod::Spec.new do |s|
  s.name             = 'EywaSDKBasic'
  s.version          = '0.1.16'
  s.summary          = 'Eywa SDK.'
 
  s.description      = <<-DESC
Eywa SDK Basic
                       DESC
 
  s.homepage         = 'https://github.com/Srineey/EywaSDKBasic/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Srineey' => 'srineey@gmail.com' }
  s.source           = { :git => 'https://github.com/Srineey/EywaSDKBasic.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'
  s.source_files = 'EywaSDK/*.{swift,h}', 'EywaSDK/Reachability/*.swift'


 
end