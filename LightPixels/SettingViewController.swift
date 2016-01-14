//
//  SettingViewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/11.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    var saveToAlbumStatus: Bool = true
    var uploadStatus: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        self.view.addSubview(self.settingTableView)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return NSLocalizedString("save", comment: "")
        } else {
            return NSLocalizedString("clear", comment: "")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "SettingCell")
        
        let realm = try! Realm()
        if (indexPath.section == 0) {
            let onOffControl = UISwitch()
            if (indexPath.row == 0) {
                
                if (realm.objects(Setting).count != 0) {
                    let album = realm.objects(Setting)[0].album
                    onOffControl.on = album
                } else {
                    onOffControl.on = true
                }
                self.saveToAlbumStatus = onOffControl.on
                
                cell.textLabel?.text = NSLocalizedString("to_album_auto", comment: "")
                onOffControl.addTarget(self, action: "onSwitchAlbum:", forControlEvents: UIControlEvents.ValueChanged)
                
                cell.accessoryView = UIView(frame: onOffControl.frame)
                cell.accessoryView?.addSubview(onOffControl)
            } else if (indexPath.row == 1) {
                let onOffControl2 = UISwitch()
                if (realm.objects(Setting).count != 0) {
                    let upload = realm.objects(Setting)[0].upload
                    onOffControl2.on = upload
                } else {
                    onOffControl2.on = true
                }
                self.uploadStatus = onOffControl2.on
                
                cell.textLabel?.text = NSLocalizedString("upload_auto", comment: "")
                onOffControl2.addTarget(self, action: "onSwitchUpload:", forControlEvents: UIControlEvents.ValueChanged)
                
                cell.accessoryView = UIView(frame: onOffControl2.frame)
                cell.accessoryView?.addSubview(onOffControl2)
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel?.text = NSLocalizedString("clear_cache", comment: "")
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if ((indexPath.section == 1) && (indexPath.row == 0)) {
            let realm = try! Realm()
            
            try! realm.write {
                realm.deleteAll()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func onSwitchAlbum(sender: UISwitch) {
        let realm = try! Realm()
        let setting = Setting()
        let temp = realm.objects(Setting)[0]
        
        try! realm.write {
            if (realm.objects(Setting).count == 0) {
                realm.add(setting)
            }
            temp.album = !self.saveToAlbumStatus
        }
    }
    
    func onSwitchUpload(sender: UISwitch) {
        let realm = try! Realm()
        let setting = Setting()
        let temp = realm.objects(Setting)[0]
        
        try! realm.write {
            if (realm.objects(Setting).count == 0) {
                realm.add(setting)
            }
            temp.upload = !self.uploadStatus
        }
    }
    
    
}