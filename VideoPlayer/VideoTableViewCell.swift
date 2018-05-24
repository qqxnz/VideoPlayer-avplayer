//
//  VideoTableViewCell.swift
//  VideoPlayer
//
//  Created by lvfm on 2018/4/18.
//  Copyright © 2018年 lvfm. All rights reserved.
//

import UIKit
import SnapKit

class VideoTableViewCell: UITableViewCell {

    var img:UIImageView = UIImageView()
    
    var videoUrl:String = ""
    
    typealias CellCallback = ()->()
    
    var callBack:CellCallback?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(self.img)
        
        self.img.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(self)
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imgdidClicked))
        tap.numberOfTapsRequired = 1
        self.img.addGestureRecognizer(tap)
        self.img.isUserInteractionEnabled =  true
    }
    
    @objc func imgdidClicked(){
        print("图片点击")
        
        if(callBack != nil){
            self.callBack!()
        }

        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
