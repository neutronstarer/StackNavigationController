Pod::Spec.new do |spec|
    spec.name     = 'StackNavigationController'
    spec.version  = '1.0.0'
    spec.license  = 'MIT'
    spec.summary  = 'stack navigation controller for ios'
    spec.homepage = 'https://github.com/neutronstarer/StackNavigationController'
    spec.author   = { 'neutronstarer' => 'neutronstarer@gmail.com' }
    spec.source   = { :git => 'https://github.com/neutronstarer/StackNavigationController.git',:tag => "#{spec.version}" }
    spec.description = 'stack navigation controller for ios.'
    spec.requires_arc = true
    spec.source_files = 'StackNavigationController/*.{h,m}'
    spec.ios.frameworks = 'UIKit'
    spec.ios.deployment_target = '8.0'
end
