//
//  LPToolBarView.swift
//  AlertView
//
//  Created by zwb on 2016/11/4.
//  Copyright © 2016年 zwb. All rights reserved.
//

import UIKit

public class LPToolBarView: UIView {
    
    public var doneAction: (() -> Void)?
    public var cancelAction: (() -> Void)?
    
    public var title = "请选择" {
        didSet {
            titleLabel.text = title
        }
    }
   
    // 分割线
    private lazy var contentView: UIView = {
        let content = UIView()
        content.backgroundColor = UIColor.whiteColor()
        return content
    }()
    
    // 文本框
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        return label
    }()
    
    // 取消按钮
    private lazy var cancleBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", forState: .Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        return btn
    }()
    
    // 确定按钮
    private lazy var doneBtn: UIButton = {
        let donebtn = UIButton()
        donebtn.setTitle("确定", forState: .Normal)
        donebtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        return donebtn
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.lightTextColor()
        
        addSubview(contentView)
        contentView.addSubview(cancleBtn)
        contentView.addSubview(doneBtn)
        contentView.addSubview(titleLabel)
        
        doneBtn.addTarget(self, action: #selector(LPToolBarView.doneBtnOnClick), forControlEvents: .TouchUpInside)
        cancleBtn.addTarget(self, action: #selector(LPToolBarView.cancelBtnOnClick), forControlEvents: .TouchUpInside)
    }
    
    @objc private func doneBtnOnClick() {
        if let doneAction = self.doneAction {
            doneAction()
        }
    }
    
    @objc private func cancelBtnOnClick() {
        if let cancelAction = self.cancelAction {
            cancelAction()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin: CGFloat = 15.0
        let height = bounds.size.height
        let width = bounds.size.width
        
        let contentHeight = height - 2.0
        contentView.frame = CGRect(x: 0.0, y: 1.0, width: width, height: contentHeight)
        
        let btnWidth = contentHeight
        cancleBtn.frame = CGRect(x: margin, y: 0.0, width: btnWidth, height: btnWidth)
        doneBtn.frame = CGRect(x: width - btnWidth - margin, y: 0.0, width: btnWidth, height: btnWidth)
        
        let titleX = CGRectGetMaxX(cancleBtn.frame) + margin
        let titleW = width - titleX - btnWidth - margin
        titleLabel.frame = CGRect(x: titleX, y: 0.0, width: titleW, height: btnWidth)
    }
    
}
