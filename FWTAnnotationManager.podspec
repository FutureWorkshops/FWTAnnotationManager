Pod::Spec.new do |s|
  s.name         = 'FWTAnnotationManager'
  s.version      = '1.1.1'
  s.platform     = :ios
  s.summary      = 'Show annotations in order to display contextual help information.'
  s.license      =  'Apache License, Version 2.0'
  s.homepage     = 'https://github.com/FutureWorkshops/FWTAnnotationManager'
  s.author       = { 'Marco Meschini' => 'marco@futureworkshops.com' }
  s.source       = { :git => 'https://github.com/FutureWorkshops/FWTAnnotationManager.git', :tag => '1.1.1' }
  s.source_files = 'FWTAnnotationManager/FWTAnnotationManager/FWT*.{h,m}'
  s.frameworks   = 'UIKit'
end
