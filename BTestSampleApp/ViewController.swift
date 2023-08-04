//
//  ViewController.swift
//  BTestSampleApp
//
//  Created by 박진성 on 2023/08/03.
//

import UIKit
import FirebaseRemoteConfig

class ViewController: UIViewController {

    var remoteConfig : RemoteConfig?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0
        
        remoteConfig?.configSettings = setting
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotice()
    }

}

extension ViewController {
    func getNotice() {
        guard let remoteConfig = remoteConfig else {return}
        
        remoteConfig.fetch { [weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("ERROR: Config not fetched")
            }
            
            guard let self = self else {return}
            
            if !self.isNoticeHidden(remoteConfig) {
                let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
                
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve
                
                let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n") //파이어베이스에서 줄바꿈 문자가 들어오면 두번 역슬래시 문자가 들어오기 때문에 변환해서 값 받기
                let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                
                noticeVC.noticeContents = (title : title, detail : detail, date : date)
                self.present(noticeVC, animated: true, completion: nil)
            }
        }
    }
    
    func isNoticeHidden(_ remotConfig : RemoteConfig) -> Bool {
        return remotConfig["isHidden"].boolValue
    }
}
