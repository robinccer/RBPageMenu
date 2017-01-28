//
//  PageTitleView.swift
//  PageMenu
//
//  Created by zhongbin on 17/1/27.
//  Copyright © 2017年 personal. All rights reserved.
//

import UIKit

private let kSrolllineH : CGFloat = 2
private let kNormalColor : (CGFloat,CGFloat,CGFloat) = (85,85,85);
private let kSelectColor : (CGFloat,CGFloat,CGFloat) = (255,128,0);

protocol PageTitleViewDelegate : class {
    func pageTitleView(pageTitleView: PageTitleView, tapIndex: Int)
}

class PageTitleView: UIView {
    
    fileprivate var currentIndex : Int = 0
    fileprivate var titles : [String]
    fileprivate var margin : CGFloat = 0
    
    fileprivate var titleLabels : [UILabel] = [UILabel]()
    
    weak var delegate : PageTitleViewDelegate?
    

    lazy var scrollView : UIScrollView = {
    
        let sco = UIScrollView()
        sco.showsHorizontalScrollIndicator = false
        sco.bounces = false
        sco.scrollsToTop = false
        return sco
        
    }()
    
    lazy var scrollViewline : UIView = {
        
        let line = UIView()
        line.backgroundColor = UIColor.blue
        return line
        
    }()
    
    
    //重载构造函数, 不对外提供默认的构造函数
    init(frame: CGRect, titles: [String]) {
        
        self.titles = titles;
        super.init(frame: frame)
        setUpUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpUI () {
    
        scrollView.frame = bounds;
        addSubview(scrollView)
        
        setUpTitleLabels()
        setUpScrollLine()
        
    }
    
    fileprivate func setUpTitleLabels (){
    
        let labelW : CGFloat = frame.width / (CGFloat)(titles.count)
        let labelH : CGFloat = frame.height - kSrolllineH
        let labelY : CGFloat = 0
        
        for (index, title) in titles.enumerated() {
            let label = UILabel()
            
            label.frame = CGRect(x: (CGFloat)(index) * labelW, y: labelY, width: labelW, height: labelH)
            label.text = title;
            label.textAlignment = .center
            label.tag = index
            label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
            label.font = UIFont.systemFont(ofSize: 16)
            scrollView.addSubview(label)
            titleLabels.append(label)
            
            if index == 0 {
                label.textColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2)
            }
            
            //添加 label 的点击事件
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelClick(gesture:)))
            label.addGestureRecognizer(tap)
            
        }
    }
    
    fileprivate func setUpScrollLine (){
    
        //添加底部的分割线
        let bottomLine = UIImageView(frame: CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0.5))
        bottomLine.backgroundColor = UIColor.lightGray
        scrollView.addSubview(bottomLine)
        
        //添加选中效果的线
        guard let firstLabel = titleLabels.first else {
            return
        }
        
        let templabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        templabel.text = firstLabel.text;
        templabel.sizeToFit()
        
        margin = firstLabel.frame.width / 2 - templabel.frame.width / 2
        
        scrollViewline.frame = CGRect(x: firstLabel.frame.width / 2 - templabel.frame.width / 2 , y: frame.height - kSrolllineH, width: templabel.frame.width, height: kSrolllineH)
        scrollView.addSubview(scrollViewline)

    }
    
    
}

extension PageTitleView {

    @objc fileprivate func labelClick (gesture: UITapGestureRecognizer ){
    
        let currentlabel = gesture.view as! UILabel
        let beforelabel = titleLabels[currentIndex]
        
        if currentIndex == currentlabel.tag {
            return
        }
        
        beforelabel.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
        currentlabel.textColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2)
  
        currentIndex = currentlabel.tag
        
        delegate?.pageTitleView(pageTitleView: self, tapIndex: currentIndex)
    }

    
}

//对外暴露一个接口, 和外界交互

extension PageTitleView {

    func setTitleChangeWithProgress(progress: CGFloat, beforeTitleIndex: Int, targetTitleIndex: Int) -> () {
        
        let beforeTitle = titleLabels[beforeTitleIndex]
        let targetTitle = titleLabels[targetTitleIndex]
        
        let templabel = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        templabel.text = beforeTitle.text;
        templabel.sizeToFit()

        let moveX = (targetTitle.frame.origin.x - beforeTitle.frame.origin.x) * progress
        
        let isLimit : Bool = moveX == targetTitle.frame.origin.x - beforeTitle.frame.origin.x
        
        if !isLimit {
            
            if moveX > 0  {
                
                scrollViewline.frame.size.width = templabel.frame.size.width + (templabel.frame.size.width + self.margin * 2) * progress * 2
                //判定下划线是否跳跃
                if progress < 0.5 {
                    
                    scrollViewline.frame.size.width = templabel.frame.size.width + (templabel.frame.size.width + self.margin * 2) * progress * 2
                    scrollViewline.frame.origin.x = beforeTitle.frame.origin.x + margin
                }else{
                    scrollViewline.frame.size.width = templabel.frame.size.width + (templabel.frame.size.width + self.margin * 2) - (templabel.frame.size.width + self.margin * 2) * (progress * 2 - 1)
                    scrollViewline.frame.origin.x = beforeTitle.frame.origin.x + margin + (templabel.frame.size.width + self.margin * 2) * (progress * 2 - 1)
                }
                
            }else{
            
                if progress < 0.5 {
                    
                    scrollViewline.frame.size.width = templabel.frame.size.width + (templabel.frame.size.width + self.margin * 2) * progress * 2
                    scrollViewline.frame.origin.x = targetTitle.frame.origin.x + margin - (templabel.frame.size.width + self.margin * 2) * (progress * 2 - 1)
                    
                }else{
                    
                    scrollViewline.frame.size.width = templabel.frame.size.width + (templabel.frame.size.width + self.margin * 2) - (templabel.frame.size.width + self.margin * 2) * (progress * 2 - 1)
                    scrollViewline.frame.origin.x = targetTitle.frame.origin.x + margin
                }
            
            
            }
        }
        
        currentIndex = targetTitleIndex
        
        let colorRang = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1,kSelectColor.2 - kNormalColor.2);
        
        beforeTitle.textColor = UIColor(r: kSelectColor.0 - colorRang.0 * progress, g: kSelectColor.1 - colorRang.1 * progress, b: kSelectColor.2 - colorRang.2 * progress);
        targetTitle.textColor = UIColor(r: kNormalColor.0 + colorRang.0 * progress, g: kNormalColor.1 + colorRang.1 * progress, b:  kNormalColor.2 + colorRang.2 * progress);

    }

}





