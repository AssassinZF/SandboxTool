//
//  ZFSandBoxTool.swift
//  SandBoxTool
//
//  Created by kris on 2018/1/2.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

import UIKit

let windowPading = 20

class ZFSandBoxTool: NSObject {
    
    static let sharedInstance = ZFSandBoxTool()
    private override init() {}
    
    lazy var viewController:SandBoxViewController = {
        let VC = SandBoxViewController()
        return VC
    }()
    
    var window:UIWindow?
    
    func enableSwipe() {
        print("尝试从右往左滑动")
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(ZFSandBoxTool.onSwipeDetected))
        swipe.numberOfTouchesRequired = 1;
        swipe.direction = UISwipeGestureRecognizerDirection.left
        let window = UIApplication.shared.windows.last
        window?.addGestureRecognizer(swipe)
    }
    
    @objc func onSwipeDetected() {
        showSandboxBrowser()
    }
    
    func showSandboxBrowser() {
        if window == nil {
            let frame = UIScreen.main.bounds
            window = UIWindow(frame: frame)
            window?.backgroundColor = UIColor.black
            window?.rootViewController = self.viewController
        }
        window?.isHidden = false
    }

}

class SandBoxCell: UITableViewCell {
    lazy var fileName:UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        let cellW = UIScreen.main.bounds.size.width - CGFloat(2*windowPading)
        
        self.fileName.frame = CGRect(x: 10, y: 30, width: cellW - 20, height: 15)
        self.addSubview(self.fileName)
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        lineView.frame = CGRect(x: 10, y: 47, width: cellW - 20, height: 1)
        self.addSubview(lineView)
    }
    
    func renderWithItem(item:FileItem) {
        fileName.text = item.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

enum ItemType:UInt{
    case ItemTypeUp
    case ItemTypeDirectory
    case ItemTypeFile
}

struct FileItem {
    var name = ""
    var path = ""
    var itemType = ItemType.ItemTypeUp
}
class SandBoxViewController:UIViewController{
    
    lazy var closeBtn:UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.backgroundColor = UIColor.black
        btn.setTitle("Close", for: UIControlState.normal)
        btn.addTarget(self, action: #selector(SandBoxViewController.clickClose), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    lazy var tableView:UITableView = {
       let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SandBoxCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var dirList:[FileItem] = []
    
    var rootPath = NSHomeDirectory()
    
    lazy var backView:UIView = {
        let backView = UIView(frame: CGRect.zero)
        backView.layer.borderWidth = 2
        backView.layer.borderColor = UIColor.black.cgColor
        backView.backgroundColor = UIColor.white
        return backView
    }()
    
    
    @objc func clickClose() {
        self.view.window?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFilePath(filePath: "")
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.backView)
        backView.addSubview(tableView)
        backView.addSubview(closeBtn)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let frame = UIScreen.main.bounds
        let rect = CGRect(x: CGFloat(windowPading), y: 64.0, width: frame.size.width - 2*CGFloat(windowPading), height: frame.size.height - 2*64.0)
        backView.frame = rect;
        
        let view_w:CGFloat = rect.size.width
        let closeW:CGFloat = 60.0
        let closeH:CGFloat = 26.0
        closeBtn.frame = CGRect(x: view_w-closeW-4, y: 4, width: closeW, height: closeH)
        
        tableView.frame = CGRect(x: 0, y: closeH, width: view_w, height: rect.size.height - closeH)
    }
    
    func loadFilePath(filePath:String) {
        var files:[FileItem] = []
        let fm = FileManager.default
        var tagerPath = filePath
        if tagerPath.isEmpty || tagerPath == rootPath {
            tagerPath = rootPath
        }else{
            let fileItem = FileItem(name: "🔙 ..", path: filePath, itemType: ItemType.ItemTypeUp)
            files.append(fileItem)
        }
        
        var paths = [String]()
        
        do {
            try paths = fm.contentsOfDirectory(atPath: tagerPath)
        } catch {
            print("tagerpath error")
        }
        for path in paths {
            let pathString:NSString = path as NSString
            if pathString.lastPathComponent.hasPrefix(".") {
                continue
            }
            let fullPath = tagerPath + "/" + path
            
            var directory: ObjCBool = ObjCBool(false)
            fm.fileExists(atPath: fullPath, isDirectory: &directory)
            
            var fileItem = FileItem()
            fileItem.path = fullPath
            if directory.boolValue{
                fileItem.itemType = ItemType.ItemTypeDirectory
                fileItem.name = "📂" + path
            }else{
                fileItem.itemType = ItemType.ItemTypeFile
                fileItem.name = "📃" + path
            }
            
            files.append(fileItem)
            
        }
        dirList = files
        tableView.reloadData()
    }
}

extension SandBoxViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dirList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SandBoxCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SandBoxCell
        cell.renderWithItem(item: dirList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = dirList[indexPath.row]
        switch item.itemType {
        case .ItemTypeUp:
            var path  = item.path as NSString
            loadFilePath(filePath: path.deletingLastPathComponent)
        case .ItemTypeFile:
            print("file type")
            sharePath(path: item.path)
        case .ItemTypeDirectory:
            loadFilePath(filePath: item.path)
        }
    }
    
    func sharePath(path:String) {
        let url = NSURL(fileURLWithPath: path)
        let shareUrls = [url]
    
        let acti = UIActivityViewController(activityItems: shareUrls, applicationActivities:nil)
        let types = [UIActivityType.postToTwitter,UIActivityType.postToWeibo,UIActivityType.postToFacebook,UIActivityType.postToTencentWeibo,UIActivityType.message,UIActivityType.postToVimeo,UIActivityType.assignToContact,UIActivityType.addToReadingList,UIActivityType.postToFlickr,UIActivityType.saveToCameraRoll,UIActivityType.print]
        acti.excludedActivityTypes = types
        self.present(acti, animated: true, completion: nil)
    }
}
