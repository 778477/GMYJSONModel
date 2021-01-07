Pod::Spec.new do |s|
  s.name         = "GMYJSONModel"
  s.version      = "1.0.0"
  s.summary      = "自动解析JSON"
  s.homepage     = "https://github.com/778477/GMYJSONModel"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author    = "miaoyou.gmy"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.12"
  s.source = {:git=>"git@github.com:778477/GMYJSONModel.git", :tag=>s.version}
  s.source_files  = "GMYJSONModel/*.{h,m}"
  s.exclude_files = "GMYJSONModel/GMYJSONModel/Info.plist"
  s.requires_arc = true
end
