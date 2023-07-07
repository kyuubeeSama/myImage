source 'https://gitee.com/mirrors/CocoaPods-Specs.git'
platform :ios, '13.0'
target 'myimage' do
  pod 'MJRefresh'
  pod 'FMDB'
  pod 'SDWebImage'
  pod 'MBProgressHUD'
  pod 'AFNetworking'
  pod 'Masonry'
  pod 'FLAnimatedImage'
  pod 'MJExtension'
  # 抽屉
  pod 'CWLateralSlide'
  pod 'ReactiveObjC'
  # xpath
  pod 'hpple'
  # 离屏渲染
  #  pod 'Texture'

  pod 'LYEmptyView'
  
  pod 'GKPhotoBrowser'

  pod 'JXCategoryView'
  use_frameworks!
  pod 'FluentDarkModeKit'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
