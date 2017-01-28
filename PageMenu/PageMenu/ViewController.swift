//
//  ViewController.swift
//  PageMenu
//
//  Created by zhongbin on 17/1/27.
//  Copyright © 2017年 personal. All rights reserved.
//

import UIKit

private let kTitleViewH : CGFloat = 40

class ViewController: UIViewController {
    
    fileprivate var titleArray : [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(pageTitleView)
        view.addSubview(pageContentView)
        
    }

    
    //懒加载 view
    fileprivate lazy var pageTitleView: PageTitleView = {
        let titleFrame = CGRect(x: 0, y:kStatusBarH + kNavigationBarH , width: kScreenW, height: kTitleViewH);
        var titles = ["推荐","游戏","娱乐","趣玩", "八卦"];
        self.titleArray = titles
        let titleView = PageTitleView(frame: titleFrame, titles: titles);
        titleView.delegate = self;
        return titleView;
    }()
    
    fileprivate lazy var pageContentView: PageContentView = { [weak self] in
        
        let contentViewFrame = CGRect(x: 0, y:kStatusBarH + kNavigationBarH + 44, width: kScreenW, height: kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH);
        
        var childVcs = [UIViewController]();
        
//        let count = self?.titleArray.count
        for _ in 0 ..< 5  {
            let childVC = UIViewController();
            childVC.view.backgroundColor = UIColor.randomColor();
            childVcs.append(childVC);
        }
        
        let pageContent = PageContentView(frame: contentViewFrame, childVcs: childVcs, parentVc: self)
        pageContent.delegate = self
        return pageContent
    }()
    
}


extension ViewController : PageTitleViewDelegate {

    func pageTitleView(pageTitleView: PageTitleView, tapIndex: Int) {
        
        pageContentView.setCurrentIndex(currentIndex: tapIndex)
        
    }

}

extension ViewController : PageContentViewDelegate {

    func pageContentView(pageContenView: PageContentView, progress: CGFloat, beforeIdnex: Int, targetIndex: Int) {
        pageTitleView.setTitleChangeWithProgress(progress: progress, beforeTitleIndex: beforeIdnex, targetTitleIndex: targetIndex)
    }
 
}






