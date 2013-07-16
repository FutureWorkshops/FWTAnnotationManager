Pod::Spec.new do |s|
  s.name         = "FWTAnnotationManager"
  s.version      = "1.2.2"
  s.summary      = "FWTAnnotationManager makes easy to manage custom annotations for each screen of your app."
  s.homepage     = "https://github.com/FutureWorkshops/FWTAnnotationManager"
  s.license      = { :type => 'Apache License Version 2.0', :file => 'LICENSE' }
  s.author       = { 'Marco Meschini' => 'marco@futureworkshops.com' }
  s.source       = { :git => "https://github.com/FutureWorkshops/FWTAnnotationManager.git", :tag => "1.2.2" }
  s.platform     = :ios
  s.source_files = 'FWTAnnotationManager/FWTAnnotationManager'
  s.framework    = 'QuartzCore'
  s.dependency 'FWTPopover', '~> 1.3.0'
end
